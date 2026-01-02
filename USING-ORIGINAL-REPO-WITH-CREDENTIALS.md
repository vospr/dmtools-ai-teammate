# Using Original IstiN/dmtools Repository with Your Own Credentials

**Date:** January 2, 2026  
**Goal:** Use the constantly updated `IstiN/dmtools` repository's workflows and tools while maintaining your own credentials (`dmtools.env`) without forking/re-syncing.

---

## Problem Statement

- ✅ **Original repo (`IstiN/dmtools`):** Constantly updated with new features, MCPs, and improvements
- ✅ **Your credentials:** Stored in `dmtools.env` (Jira, Gemini, etc.)
- ❌ **Current approach:** Forking requires constant re-syncing
- ✅ **Desired:** Use original repo's workflows/tools with your credentials automatically

---

## Analysis: How dmtools Loads Credentials

### Current Behavior

**`dmtools.sh` automatically loads `dmtools.env` from these locations (in priority order):**

1. Current working directory: `.env`, `dmtools.env`, `dmtools-local.env`
2. Script directory: `$SCRIPT_DIR/.env`, `$SCRIPT_DIR/dmtools.env`, `$SCRIPT_DIR/dmtools-local.env`

**Original workflow (`ai-teammate.yml`) uses:**
- GitHub Secrets (`${{ secrets.JIRA_EMAIL }}`, etc.)
- GitHub Variables (`${{ vars.JIRA_BASE_PATH }}`, etc.)
- Environment variables set in workflow `env:` section

**Your setup uses:**
- `dmtools.env` file (loaded automatically by `dmtools.sh`)

---

## Solution Approaches

### Approach 1: Checkout Original Repo + Inject dmtools.env (Recommended)

**Concept:** Checkout `IstiN/dmtools`, create `dmtools.env` from your GitHub Secrets, run workflow.

**Pros:**
- ✅ Always uses latest original repo
- ✅ No forking needed
- ✅ Credentials stored securely in GitHub Secrets
- ✅ Works with any workflow from original repo

**Cons:**
- ⚠️ Need to maintain mapping between `dmtools.env` and GitHub Secrets
- ⚠️ Agent config files need to be in your repo or passed as input

**Implementation:**

```yaml
name: AI Teammate (Using Original Repo)

on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Path to agent config (relative to original repo)'
        required: true
        default: 'agents/learning_questions.json'
      encoded_config:
        description: 'Encoded or JSON Agent Config'
        required: false

permissions:
  contents: read
  actions: read

jobs:
  ai-teammate:
    runs-on: ubuntu-latest
    steps:
      # Step 1: Checkout ORIGINAL repository
      - name: Checkout Original Repository
        uses: actions/checkout@v4
        with:
          repository: IstiN/dmtools
          ref: main
          path: original-repo
      
      # Step 2: Checkout YOUR repository (for agent configs if needed)
      - name: Checkout Your Repository
        uses: actions/checkout@v4
        with:
          path: your-repo
          sparse-checkout: |
            agents/
            .github/workflows/
      
      # Step 3: Setup Java
      - name: Setup Java Environment
        uses: ./.github/actions/setup-java-only
        with:
          cache-key-suffix: '-cursor'
        working-directory: original-repo
      
      # Step 4: Install Cursor CLI
      - name: Install Cursor CLI
        run: |
          curl https://cursor.com/install -fsS | bash
          echo "$HOME/.local/bin" >> $GITHUB_PATH
      
      # Step 5: Install DMTools CLI (from original repo)
      - name: Install DMTools CLI
        working-directory: original-repo
        run: |
          curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
          echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
      
      # Step 6: Create dmtools.env from GitHub Secrets
      - name: Create dmtools.env from Secrets
        working-directory: original-repo
        run: |
          cat > dmtools.env << EOF
          # Jira Configuration
          JIRA_EMAIL=${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN=${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH=${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE=${{ vars.JIRA_AUTH_TYPE }}
          
          # Confluence Configuration
          CONFLUENCE_EMAIL=${{ secrets.JIRA_EMAIL }}
          CONFLUENCE_API_TOKEN=${{ secrets.JIRA_API_TOKEN }}
          CONFLUENCE_BASE_PATH=${{ vars.CONFLUENCE_BASE_PATH }}
          CONFLUENCE_DEFAULT_SPACE=${{ vars.CONFLUENCE_DEFAULT_SPACE }}
          CONFLUENCE_GRAPHQL_PATH=${{ vars.CONFLUENCE_GRAPHQL_PATH }}
          
          # AI Service Configuration
          GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}
          DEFAULT_LLM=gemini
          GEMINI_DEFAULT_MODEL=${{ vars.GEMINI_DEFAULT_MODEL || 'gemini-2.0-flash-exp' }}
          
          # Figma Configuration
          FIGMA_TOKEN=${{ secrets.FIGMA_TOKEN }}
          FIGMA_BASE_PATH=${{ vars.FIGMA_BASE_PATH }}
          
          # GitHub Authentication
          PAT_TOKEN=${{ secrets.PAT_TOKEN }}
          GH_TOKEN=${{ secrets.PAT_TOKEN }}
          
          # DMTools Integration Settings
          DMTOOLS_INTEGRATIONS=jira,confluence,figma,ai,cli,file
          
          # Cursor Configuration
          CURSOR_API_KEY=${{ secrets.CURSOR_API_KEY }}
          MODEL=sonnet-4.5
          AGENT_DISABLE_WATCHDOG=1
          EOF
          
          # Secure the file
          chmod 600 dmtools.env
          echo "✅ Created dmtools.env with your credentials"
          echo "File location: $(pwd)/dmtools.env"
      
      # Step 7: Copy agent config if from your repo
      - name: Copy Agent Config (if needed)
        run: |
          CONFIG_FILE="${{ inputs.config_file }}"
          if [ -f "your-repo/$CONFIG_FILE" ]; then
            echo "Using agent config from your repository"
            cp "your-repo/$CONFIG_FILE" "original-repo/$CONFIG_FILE"
          elif [ -f "original-repo/$CONFIG_FILE" ]; then
            echo "Using agent config from original repository"
          else
            echo "❌ Agent config not found: $CONFIG_FILE"
            exit 1
          fi
      
      # Step 8: Run AI Teammate
      - name: Run AI Teammate
        working-directory: original-repo
        env:
          PATH: "/home/runner/.local/bin:/home/runner/.dmtools/bin:/bin:/usr/bin:$PATH"
          ENCODED_CONFIG: ${{ inputs.encoded_config }}
        run: |
          CONFIG_FILE="${{ inputs.config_file }}"
          echo "Using configuration: $CONFIG_FILE"
          
          if [ -n "${ENCODED_CONFIG}" ]; then
            echo "Encoded config provided"
            dmtools run "$CONFIG_FILE" "${ENCODED_CONFIG}"
          else
            echo "No encoded config, using defaults from config file"
            dmtools run "$CONFIG_FILE"
          fi
```

---

### Approach 2: Reusable Workflow from Original Repo

**Concept:** Original repo exposes a reusable workflow, you call it with your secrets.

**Pros:**
- ✅ Clean separation of concerns
- ✅ Original repo controls workflow logic
- ✅ You only provide credentials

**Cons:**
- ⚠️ Requires original repo to expose reusable workflow
- ⚠️ Less flexibility if you need customizations

**Implementation (if original repo supports it):**

```yaml
# In your repository: .github/workflows/use-original-ai-teammate.yml
name: Use Original AI Teammate

on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Path to agent config'
        required: true
      encoded_config:
        description: 'Encoded or JSON Agent Config'
        required: false

jobs:
  call-original-workflow:
    uses: IstiN/dmtools/.github/workflows/ai-teammate.yml@main
    secrets:
      JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
      JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
      GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
      # ... other secrets
    with:
      config_file: ${{ inputs.config_file }}
      encoded_config: ${{ inputs.encoded_config }}
```

**Note:** This requires the original repo to expose `ai-teammate.yml` as a reusable workflow.

---

### Approach 3: Clone Original Repo + Inject dmtools.env (Alternative)

**Concept:** Clone original repo during workflow, inject your `dmtools.env`, use their tools.

**Pros:**
- ✅ Always uses latest original repo
- ✅ Can use any file from original repo
- ✅ Simple credential injection

**Cons:**
- ⚠️ Need to clone on every run (slower)
- ⚠️ More complex path management

**Implementation:**

```yaml
- name: Clone Original Repository
  run: |
    git clone https://github.com/IstiN/dmtools.git original-repo
    cd original-repo
    git checkout main

- name: Inject Your Credentials
  working-directory: original-repo
  run: |
    # Create dmtools.env from secrets (same as Approach 1)
    cat > dmtools.env << EOF
    # ... credentials from secrets ...
    EOF
    chmod 600 dmtools.env
```

---

### Approach 4: Use Original Workflow with Environment Variable Override

**Concept:** Use original workflow as-is, but override environment variables from your secrets.

**Pros:**
- ✅ Minimal changes to original workflow
- ✅ Works if original workflow accepts env vars

**Cons:**
- ⚠️ Original workflow must support env var overrides
- ⚠️ May not work if workflow hardcodes values

**Implementation:**

```yaml
- name: Run Original Workflow Step
  env:
    # Override with your secrets
    JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
    JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
    # ... other overrides
  run: |
    # Original workflow commands
```

---

## Recommended Solution: Approach 1 (Enhanced)

**Best of both worlds:**
1. Checkout original repo for tools/workflows
2. Create `dmtools.env` from your GitHub Secrets
3. Support agent configs from your repo or original repo
4. Always uses latest original repo code

---

## Implementation Steps

### Step 1: Create Workflow in Your Repository

**File:** `.github/workflows/ai-teammate-original.yml`

**Key features:**
- Checks out `IstiN/dmtools` repository
- Creates `dmtools.env` from your GitHub Secrets
- Supports agent configs from your repo or original repo
- Uses original repo's installation methods

### Step 2: Map Your dmtools.env to GitHub Secrets

**Current `dmtools.env` structure:**
```
JIRA_EMAIL=...
JIRA_API_TOKEN=...
JIRA_BASE_PATH=...
GEMINI_API_KEY=...
```

**GitHub Secrets needed:**
- `JIRA_EMAIL` → `secrets.JIRA_EMAIL`
- `JIRA_API_TOKEN` → `secrets.JIRA_API_TOKEN`
- `GEMINI_API_KEY` → `secrets.GEMINI_API_KEY`
- etc.

**GitHub Variables needed:**
- `JIRA_BASE_PATH` → `vars.JIRA_BASE_PATH`
- `JIRA_AUTH_TYPE` → `vars.JIRA_AUTH_TYPE`
- etc.

### Step 3: Update Jira Automation

**Current webhook:**
```json
{
  "ref": "main",
  "inputs": {
    "config_file": "agents/learning_questions.json"
  }
}
```

**New webhook (same format):**
- No changes needed if using same input format
- Or update to use original repo's agent config path

### Step 4: Test Workflow

1. **Manual trigger:** Test workflow manually in GitHub Actions
2. **Verify:** Check that original repo is checked out
3. **Verify:** Check that `dmtools.env` is created correctly
4. **Verify:** Check that `dmtools run` works with your credentials
5. **Test:** Trigger from Jira automation

---

## Complete Workflow Example

```yaml
name: AI Teammate (Using Original Repo)

on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Path to agent config (relative to original repo or your repo)'
        required: true
        default: 'agents/learning_questions.json'
      encoded_config:
        description: 'Base64-encoded JSON with dynamic params'
        required: false
      use_your_agent_config:
        description: 'Use agent config from your repo instead of original'
        required: false
        type: boolean
        default: false

permissions:
  contents: read
  actions: read

jobs:
  ai-teammate:
    runs-on: ubuntu-latest
    concurrency:
      group: ai-teammate-${{ inputs.config_file }}
      cancel-in-progress: false

    steps:
      # Step 1: Checkout ORIGINAL repository (IstiN/dmtools)
      - name: Checkout Original Repository
        uses: actions/checkout@v4
        with:
          repository: IstiN/dmtools
          ref: main
          path: original-repo
          token: ${{ secrets.GITHUB_TOKEN }}
      
      # Step 2: Checkout YOUR repository (for agent configs if needed)
      - name: Checkout Your Repository
        if: inputs.use_your_agent_config == true
        uses: actions/checkout@v4
        with:
          path: your-repo
          sparse-checkout: |
            agents/
      
      # Step 3: Setup Java (using original repo's action if available)
      - name: Setup Java Environment
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '23'
      
      # Step 4: Install Cursor CLI
      - name: Install Cursor CLI
        run: |
          echo "Installing Cursor CLI..."
          curl https://cursor.com/install -fsS | bash
          echo "$HOME/.local/bin" >> $GITHUB_PATH
          
          # Verify installation
          export PATH="$HOME/.local/bin:$PATH"
          if command -v cursor-agent >/dev/null 2>&1; then
            echo "✅ cursor-agent installed"
            cursor-agent --version || echo "Version check failed"
          else
            echo "❌ cursor-agent not found"
            exit 1
          fi
      
      # Step 5: Install DMTools CLI (from original repo's releases)
      - name: Install DMTools CLI
        working-directory: original-repo
        run: |
          echo "Installing DMTools CLI from original repository..."
          curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
          echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
          
          # Verify installation
          export PATH="$HOME/.dmtools/bin:$PATH"
          if command -v dmtools >/dev/null 2>&1; then
            echo "✅ dmtools installed"
            dmtools --version || echo "Version check failed"
          else
            echo "❌ dmtools not found"
            exit 1
          fi
      
      # Step 6: Create dmtools.env from GitHub Secrets
      - name: Create dmtools.env from Your Secrets
        working-directory: original-repo
        run: |
          echo "Creating dmtools.env from GitHub Secrets..."
          cat > dmtools.env << 'EOF'
          # Jira Configuration
          JIRA_EMAIL=${JIRA_EMAIL}
          JIRA_API_TOKEN=${JIRA_API_TOKEN}
          JIRA_BASE_PATH=${JIRA_BASE_PATH}
          JIRA_AUTH_TYPE=${JIRA_AUTH_TYPE}
          
          # Confluence Configuration
          CONFLUENCE_EMAIL=${CONFLUENCE_EMAIL}
          CONFLUENCE_API_TOKEN=${CONFLUENCE_API_TOKEN}
          CONFLUENCE_BASE_PATH=${CONFLUENCE_BASE_PATH}
          CONFLUENCE_DEFAULT_SPACE=${CONFLUENCE_DEFAULT_SPACE}
          CONFLUENCE_GRAPHQL_PATH=${CONFLUENCE_GRAPHQL_PATH}
          
          # AI Service Configuration
          GEMINI_API_KEY=${GEMINI_API_KEY}
          DEFAULT_LLM=gemini
          GEMINI_DEFAULT_MODEL=${GEMINI_DEFAULT_MODEL}
          
          # Figma Configuration
          FIGMA_TOKEN=${FIGMA_TOKEN}
          FIGMA_BASE_PATH=${FIGMA_BASE_PATH}
          
          # GitHub Authentication
          PAT_TOKEN=${PAT_TOKEN}
          GH_TOKEN=${PAT_TOKEN}
          
          # DMTools Integration Settings
          DMTOOLS_INTEGRATIONS=jira,confluence,figma,ai,cli,file
          
          # Cursor Configuration
          CURSOR_API_KEY=${CURSOR_API_KEY}
          MODEL=sonnet-4.5
          AGENT_DISABLE_WATCHDOG=1
          EOF
          
          # Substitute variables
          export JIRA_EMAIL="${{ secrets.JIRA_EMAIL }}"
          export JIRA_API_TOKEN="${{ secrets.JIRA_API_TOKEN }}"
          export JIRA_BASE_PATH="${{ vars.JIRA_BASE_PATH }}"
          export JIRA_AUTH_TYPE="${{ vars.JIRA_AUTH_TYPE }}"
          export CONFLUENCE_EMAIL="${{ secrets.JIRA_EMAIL }}"
          export CONFLUENCE_API_TOKEN="${{ secrets.JIRA_API_TOKEN }}"
          export CONFLUENCE_BASE_PATH="${{ vars.CONFLUENCE_BASE_PATH }}"
          export CONFLUENCE_DEFAULT_SPACE="${{ vars.CONFLUENCE_DEFAULT_SPACE }}"
          export CONFLUENCE_GRAPHQL_PATH="${{ vars.CONFLUENCE_GRAPHQL_PATH }}"
          export GEMINI_API_KEY="${{ secrets.GEMINI_API_KEY }}"
          export GEMINI_DEFAULT_MODEL="${{ vars.GEMINI_DEFAULT_MODEL || 'gemini-2.0-flash-exp' }}"
          export FIGMA_TOKEN="${{ secrets.FIGMA_TOKEN }}"
          export FIGMA_BASE_PATH="${{ vars.FIGMA_BASE_PATH }}"
          export PAT_TOKEN="${{ secrets.PAT_TOKEN }}"
          export CURSOR_API_KEY="${{ secrets.CURSOR_API_KEY }}"
          
          # Use envsubst if available, otherwise sed
          if command -v envsubst >/dev/null 2>&1; then
            envsubst < dmtools.env > dmtools.env.tmp
            mv dmtools.env.tmp dmtools.env
          else
            # Fallback to sed
            sed -i "s|\${JIRA_EMAIL}|$JIRA_EMAIL|g" dmtools.env
            sed -i "s|\${JIRA_API_TOKEN}|$JIRA_API_TOKEN|g" dmtools.env
            sed -i "s|\${JIRA_BASE_PATH}|$JIRA_BASE_PATH|g" dmtools.env
            sed -i "s|\${JIRA_AUTH_TYPE}|$JIRA_AUTH_TYPE|g" dmtools.env
            sed -i "s|\${CONFLUENCE_EMAIL}|$CONFLUENCE_EMAIL|g" dmtools.env
            sed -i "s|\${CONFLUENCE_API_TOKEN}|$CONFLUENCE_API_TOKEN|g" dmtools.env
            sed -i "s|\${CONFLUENCE_BASE_PATH}|$CONFLUENCE_BASE_PATH|g" dmtools.env
            sed -i "s|\${CONFLUENCE_DEFAULT_SPACE}|$CONFLUENCE_DEFAULT_SPACE|g" dmtools.env
            sed -i "s|\${CONFLUENCE_GRAPHQL_PATH}|$CONFLUENCE_GRAPHQL_PATH|g" dmtools.env
            sed -i "s|\${GEMINI_API_KEY}|$GEMINI_API_KEY|g" dmtools.env
            sed -i "s|\${GEMINI_DEFAULT_MODEL}|$GEMINI_DEFAULT_MODEL|g" dmtools.env
            sed -i "s|\${FIGMA_TOKEN}|$FIGMA_TOKEN|g" dmtools.env
            sed -i "s|\${FIGMA_BASE_PATH}|$FIGMA_BASE_PATH|g" dmtools.env
            sed -i "s|\${PAT_TOKEN}|$PAT_TOKEN|g" dmtools.env
            sed -i "s|\${CURSOR_API_KEY}|$CURSOR_API_KEY|g" dmtools.env
          fi
          
          # Secure the file
          chmod 600 dmtools.env
          echo "✅ Created dmtools.env with your credentials"
          echo "File location: $(pwd)/dmtools.env"
          echo "First few lines (masked):"
          head -n 3 dmtools.env | sed 's/=.*/=***/'
      
      # Step 7: Copy agent config from your repo if requested
      - name: Copy Agent Config from Your Repo
        if: inputs.use_your_agent_config == true
        run: |
          CONFIG_FILE="${{ inputs.config_file }}"
          echo "Copying agent config from your repository: $CONFIG_FILE"
          
          if [ -f "your-repo/$CONFIG_FILE" ]; then
            # Create directory structure if needed
            mkdir -p "original-repo/$(dirname "$CONFIG_FILE")"
            cp "your-repo/$CONFIG_FILE" "original-repo/$CONFIG_FILE"
            echo "✅ Copied agent config to original-repo/$CONFIG_FILE"
          else
            echo "❌ Agent config not found in your repo: your-repo/$CONFIG_FILE"
            exit 1
          fi
      
      # Step 8: Verify Agent Config Exists
      - name: Verify Agent Config
        working-directory: original-repo
        run: |
          CONFIG_FILE="${{ inputs.config_file }}"
          if [ -f "$CONFIG_FILE" ]; then
            echo "✅ Agent config found: $CONFIG_FILE"
            echo "Config file size: $(wc -l < "$CONFIG_FILE") lines"
          else
            echo "❌ Agent config not found: $CONFIG_FILE"
            echo "Available agent configs:"
            find agents/ -name "*.json" 2>/dev/null || echo "No agents/ directory found"
            exit 1
          fi
      
      # Step 9: Run AI Teammate
      - name: Run AI Teammate
        working-directory: original-repo
        env:
          PATH: "/home/runner/.local/bin:/home/runner/.dmtools/bin:/bin:/usr/bin:$PATH"
          ENCODED_CONFIG: ${{ inputs.encoded_config }}
        run: |
          CONFIG_FILE="${{ inputs.config_file }}"
          echo "🚀 Running AI Teammate with config: $CONFIG_FILE"
          echo "Working directory: $(pwd)"
          echo "dmtools.env location: $(pwd)/dmtools.env"
          
          # Verify dmtools can find dmtools.env
          if [ -f "dmtools.env" ]; then
            echo "✅ dmtools.env exists in working directory"
          else
            echo "❌ dmtools.env not found in working directory"
            exit 1
          fi
          
          # Run dmtools
          if [ -n "${ENCODED_CONFIG}" ]; then
            echo "Encoded config provided"
            echo "Encoded config length: ${#ENCODED_CONFIG} characters"
            dmtools run "$CONFIG_FILE" "${ENCODED_CONFIG}"
          else
            echo "No encoded config, using defaults from config file"
            dmtools run "$CONFIG_FILE"
          fi
```

---

## Migration Checklist

### Pre-Migration
- [ ] Review original `IstiN/dmtools` repository structure
- [ ] Identify which agent configs you need (from your repo or original)
- [ ] Map all `dmtools.env` variables to GitHub Secrets/Variables
- [ ] Test original workflow manually in `IstiN/dmtools` repository

### Setup GitHub Secrets/Variables
- [ ] Create GitHub Secrets for sensitive values:
  - `JIRA_EMAIL`
  - `JIRA_API_TOKEN`
  - `GEMINI_API_KEY`
  - `FIGMA_TOKEN`
  - `PAT_TOKEN`
  - `CURSOR_API_KEY`
- [ ] Create GitHub Variables for non-sensitive values:
  - `JIRA_BASE_PATH`
  - `JIRA_AUTH_TYPE`
  - `CONFLUENCE_BASE_PATH`
  - `CONFLUENCE_DEFAULT_SPACE`
  - `CONFLUENCE_GRAPHQL_PATH`
  - `FIGMA_BASE_PATH`
  - `GEMINI_DEFAULT_MODEL`

### Create Workflow
- [ ] Create `.github/workflows/ai-teammate-original.yml`
- [ ] Test workflow manually
- [ ] Verify `dmtools.env` is created correctly
- [ ] Verify `dmtools run` works with your credentials

### Update Jira Automation
- [ ] Update webhook URL (if workflow name changed)
- [ ] Test webhook trigger
- [ ] Verify end-to-end flow

---

## Advantages of This Approach

1. **Always Up-to-Date:** Uses latest `IstiN/dmtools` code automatically
2. **No Forking:** No need to maintain fork or sync changes
3. **Secure:** Credentials stored in GitHub Secrets, not in code
4. **Flexible:** Can use agent configs from your repo or original repo
5. **Maintainable:** Original repo controls tool updates, you control credentials

---

## Testing Steps

1. **Manual Test:**
   ```bash
   # Trigger workflow manually in GitHub Actions
   # Use inputs:
   # - config_file: "agents/learning_questions.json"
   # - use_your_agent_config: false (use original repo's config)
   ```

2. **Verify Logs:**
   - Check that original repo is checked out
   - Check that `dmtools.env` is created
   - Check that `dmtools run` executes successfully

3. **Test with Your Agent Config:**
   ```bash
   # Use inputs:
   # - config_file: "agents/learning_questions.json"
   # - use_your_agent_config: true (use your repo's config)
   ```

4. **Test from Jira:**
   - Trigger Jira automation
   - Verify workflow runs successfully
   - Verify questions are generated and sub-tickets created

---

## Troubleshooting

### Issue: dmtools.env not found
**Solution:** Ensure `dmtools.env` is created in the same directory where `dmtools run` is executed (working-directory).

### Issue: Agent config not found
**Solution:** 
- If using original repo's config: Ensure path is correct relative to original repo
- If using your repo's config: Ensure `use_your_agent_config: true` and file exists in your repo

### Issue: Credentials not working
**Solution:**
- Verify GitHub Secrets are set correctly
- Check that `dmtools.env` is created with correct values (mask sensitive data in logs)
- Verify `dmtools.sh` can find `dmtools.env` (should be in working directory)

### Issue: Original repo checkout fails
**Solution:**
- Ensure `GITHUB_TOKEN` has read access to `IstiN/dmtools`
- Check that repository is public or token has access

---

## Next Steps

1. **Create workflow file:** `.github/workflows/ai-teammate-original.yml`
2. **Set up GitHub Secrets/Variables:** Map your `dmtools.env` to GitHub
3. **Test manually:** Run workflow manually in GitHub Actions
4. **Update Jira automation:** Point webhook to new workflow
5. **Monitor:** Watch first few runs to ensure everything works

---

**Last Updated:** January 2, 2026
