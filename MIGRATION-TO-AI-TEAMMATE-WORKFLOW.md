# Migration Plan: learning-ai-teammate.yml → ai-teammate.yml

**Date:** January 2, 2026  
**Purpose:** Step-by-step guide to migrate from `learning-ai-teammate.yml` to `ai-teammate.yml` workflow

---

## Overview

### Current State (learning-ai-teammate.yml)
- ✅ **Input:** `ticket_key` (required), `config_file` (optional, default: `agents/learning_questions.json`)
- ✅ **Approach:** Explicit step-by-step CLI commands
- ✅ **Dependencies:** dmtools only, Java 23
- ✅ **Local files:** Uses `releases/` directory for JAR and scripts
- ✅ **Permissions:** `contents: read`, `actions: read`
- ✅ **Error handling:** Extensive fallback methods

### Target State (ai-teammate.yml)
- ⚠️ **Input:** `config_file` (required), `encoded_config` (optional)
- ⚠️ **Approach:** Delegates to `dmtools run` command
- ⚠️ **Dependencies:** Cursor CLI + dmtools, Java (via reusable action)
- ⚠️ **Local files:** Downloads from GitHub releases
- ⚠️ **Permissions:** `contents: write`, `pull-requests: write`, `actions: read`
- ⚠️ **Error handling:** Minimal (relies on dmtools)

---

## Key Differences Summary

| Aspect | learning-ai-teammate.yml | ai-teammate.yml |
|--------|-------------------------|-----------------|
| **Input Format** | `ticket_key` + `config_file` | `config_file` + `encoded_config` |
| **Execution** | Step-by-step CLI commands | `dmtools run` delegation |
| **Cursor CLI** | ❌ Not required | ✅ Required |
| **Local Files** | ✅ Supported (`releases/`) | ❌ Downloads from GitHub |
| **Java Setup** | Direct `setup-java@v4` | Reusable action `setup-java-only` |
| **Permissions** | Read-only | Write (for PRs) |
| **Complexity** | High (589 lines) | Low (112 lines) |

---

## Migration Steps

### Phase 1: Preparation and Analysis

#### Step 1.1: Verify Agent Config File
**Status:** ✅ Already exists

**Action:**
- Verify `agents/learning_questions.json` is valid
- Check that `inputJql` can be overridden via `encoded_config`
- Ensure `initiator` can be passed dynamically

**Current config:**
```json
{
  "inputJql": "key = ATL-2",  // Hardcoded - needs to be dynamic
  "initiator": "your-jira-account-id"  // Hardcoded - needs to be dynamic
}
```

**Required changes:**
- `inputJql` should be set via `encoded_config` (base64-encoded JSON)
- `initiator` should be set via `encoded_config`

---

#### Step 1.2: Understand `encoded_config` Format

**What is `encoded_config`?**
- Base64-encoded JSON string
- Contains dynamic parameters that override agent config
- Passed from Jira automation via webhook

**Example structure:**
```json
{
  "params": {
    "inputJql": "key = ATL-2",
    "initiator": "account-id-here"
  }
}
```

**Encoding:**
```bash
# Create JSON
echo '{"params":{"inputJql":"key = ATL-2","initiator":"account-id"}}' > config.json

# Encode to base64
ENCODED=$(cat config.json | base64 -w 0)
echo $ENCODED
```

---

#### Step 1.3: Check Cursor CLI Requirement

**Question:** Is Cursor CLI actually required for your use case?

**Analysis:**
- Your agent config has `"skipAIProcessing": true`
- This suggests it might not need Cursor CLI
- However, `ai-teammate.yml` always installs Cursor CLI

**Options:**
1. **Keep Cursor CLI** (if agent config requires it)
2. **Remove Cursor CLI** (if not needed, simplifies workflow)
3. **Make it optional** (conditional installation)

**Recommendation:** Test if `dmtools run` works without Cursor CLI first.

---

### Phase 2: Workflow File Updates

#### Step 2.1: Create New Workflow File

**Action:** Create `ai-teammate-learning.yml` (or update existing `ai-teammate.yml`)

**Base template:** Use `ai-teammate.yml` from `vospr/dmtools` as starting point

**Location:** `.github/workflows/ai-teammate-learning.yml`

---

#### Step 2.2: Adapt Input Format

**Current (learning-ai-teammate.yml):**
```yaml
inputs:
  ticket_key:
    description: 'Jira ticket key to process (e.g., ATL-2)'
    required: true
    type: string
  config_file:
    description: 'Path to agent config (relative to repo root)'
    required: false
    type: string
    default: 'agents/learning_questions.json'
```

**Target (ai-teammate.yml):**
```yaml
inputs:
  config_file:
    description: 'Path to config'
    required: true
  encoded_config:
    description: 'Encoded or JSON Agent Config'
    required: false
```

**Decision needed:**
- **Option A:** Keep `ticket_key` input for backward compatibility
- **Option B:** Remove `ticket_key`, use only `encoded_config`
- **Option C:** Hybrid - accept both, prefer `encoded_config`

**Recommendation:** **Option C (Hybrid)** - Support both for transition period

**Proposed hybrid input:**
```yaml
inputs:
  config_file:
    description: 'Path to agent config (relative to repo root)'
    required: false
    type: string
    default: 'agents/learning_questions.json'
  encoded_config:
    description: 'Base64-encoded JSON with dynamic params (ticket_key, initiator, etc.)'
    required: false
    type: string
  ticket_key:
    description: 'Jira ticket key (legacy - use encoded_config instead)'
    required: false
    type: string
```

---

#### Step 2.3: Update Java Setup

**Current:**
```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '23'
```

**Target:**
```yaml
- name: Setup Java Environment
  uses: ./.github/actions/setup-java-only
  with:
    cache-key-suffix: '-cursor'
```

**Action required:**
- Check if `.github/actions/setup-java-only` exists in `dmtools-ai-teammate`
- If not, either:
  - Copy from `vospr/dmtools` repository
  - Or keep using `actions/setup-java@v4` directly

**Recommendation:** Keep `actions/setup-java@v4` if reusable action doesn't exist.

---

#### Step 2.4: Add Cursor CLI Installation

**Add this step:**
```yaml
- name: Install Cursor CLI
  run: |
    echo "Installing Cursor CLI..."
    curl https://cursor.com/install -fsS | bash
    
    # Cursor CLI installs to ~/.local/bin
    echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    # Verify installation
    export PATH="$HOME/.local/bin:$PATH"
    if command -v cursor-agent >/dev/null 2>&1; then
      echo "✅ cursor-agent found at: $(command -v cursor-agent)"
      cursor-agent --version || echo "Version check failed"
    else
      echo "❌ cursor-agent not found after installation"
      exit 1
    fi
```

**Note:** This step is required if your agent config uses Cursor CLI.

---

#### Step 2.5: Update dmtools Installation

**Current (learning-ai-teammate.yml):**
```yaml
- name: Install dmtools CLI
  env:
    DMTOOLS_LOCAL_SOURCE: ${{ github.workspace }}/releases
  run: |
    # Extensive local file detection logic
```

**Target (ai-teammate.yml):**
```yaml
- name: Install DMTools CLI
  run: |
    curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

**Decision needed:**
- **Option A:** Keep local file support (recommended for your use case)
- **Option B:** Use GitHub releases only (simpler)

**Recommendation:** **Option A** - Keep local file support since you have `releases/` directory

**Proposed hybrid:**
```yaml
- name: Install DMTools CLI
  env:
    DMTOOLS_LOCAL_SOURCE: ${{ github.workspace }}/releases
  run: |
    # Try local first, fallback to GitHub
    if [ -f "${{ github.workspace }}/install.sh" ]; then
      bash "${{ github.workspace }}/install.sh"
    else
      curl -fsSL https://raw.githubusercontent.com/vospr/dmtools/main/install.sh | bash
    fi
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

---

#### Step 2.6: Replace Execution Steps

**Current (learning-ai-teammate.yml):**
```yaml
# Multiple explicit steps:
- Get Ticket Information
- Build AI Prompt
- Call Gemini AI
- Parse Questions
- Create Sub-tickets
- Add Label
```

**Target (ai-teammate.yml):**
```yaml
- name: Run AI Teammate
  env:
    CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
    MODEL: sonnet-4.5
    # ... all environment variables ...
  run: |
    if [ -n "${ENCODED_CONFIG}" ]; then
      dmtools run "${{ inputs.config_file }}" "${ENCODED_CONFIG}"
    else
      dmtools run "${{ inputs.config_file }}"
    fi
```

**Action:** Replace all explicit steps with single `dmtools run` command.

---

#### Step 2.7: Update Permissions

**Current:**
```yaml
permissions:
  contents: read
  actions: read
```

**Target:**
```yaml
permissions:
  contents: write
  pull-requests: write
  actions: read
```

**Note:** Only needed if agent config creates PRs. If not, keep `read` permissions.

---

#### Step 2.8: Add Environment Variables

**Add missing variables from ai-teammate.yml:**
- `CURSOR_API_KEY` (if using Cursor CLI)
- `MODEL: sonnet-4.5` (or `sonnet-4`)
- `AGENT_DISABLE_WATCHDOG: "1"`
- Additional Jira vars (if needed):
  - `JIRA_CLEAR_CACHE`
  - `JIRA_EXTRA_FIELDS`
  - `JIRA_EXTRA_FIELDS_PROJECT`
  - `JIRA_LOGGING_ENABLED`
  - `JIRA_WAIT_BEFORE_PERFORM`
- Additional AI vars:
  - `GEMINI_DEFAULT_MODEL`
  - `PROMPT_CHUNK_TOKEN_LIMIT`

---

### Phase 3: Agent Config Updates

#### Step 3.1: Make Agent Config Dynamic

**Current (`learning_questions.json`):**
```json
{
  "params": {
    "inputJql": "key = ATL-2",  // Hardcoded
    "initiator": "your-jira-account-id"  // Hardcoded
  }
}
```

**Required:** These should be set via `encoded_config` parameter

**Solution:** Keep defaults in config, allow override via `encoded_config`:
```json
{
  "params": {
    "inputJql": "key = {{ticket_key}}",  // Placeholder or default
    "initiator": "{{initiator}}"  // Placeholder or default
  }
}
```

**Note:** `dmtools run` will merge `encoded_config` with base config.

---

#### Step 3.2: Test Agent Config Locally

**Action:** Test `dmtools run` command locally:

```bash
# Test 1: Without encoded_config
dmtools run agents/learning_questions.json

# Test 2: With encoded_config
echo '{"params":{"inputJql":"key = ATL-2","initiator":"your-account-id"}}' | base64 -w 0
# Use the base64 output as encoded_config
dmtools run agents/learning_questions.json "BASE64_STRING_HERE"
```

**Verify:**
- ✅ Agent config is read correctly
- ✅ `encoded_config` overrides work
- ✅ Ticket is fetched correctly
- ✅ Questions are generated
- ✅ Sub-tickets are created
- ✅ Labels are added

---

### Phase 4: Jira Automation Updates

#### Step 4.1: Update Webhook URL

**Current:**
```
https://api.github.com/repos/vospr/dmtools-ai-teammate/actions/workflows/learning-ai-teammate.yml/dispatches
```

**Target:**
```
https://api.github.com/repos/vospr/dmtools-ai-teammate/actions/workflows/ai-teammate-learning.yml/dispatches
```

**Or if keeping same file name:**
- Keep URL the same if you're updating `learning-ai-teammate.yml` in place
- Change URL if creating new workflow file

---

#### Step 4.2: Update Webhook Request Body

**Current:**
```json
{
  "ref": "main",
  "inputs": {
    "ticket_key": "{{issue.key}}",
    "config_file": "agents/learning_questions.json"
  }
}
```

**Target (Option A - encoded_config):**
```json
{
  "ref": "main",
  "inputs": {
    "config_file": "agents/learning_questions.json",
    "encoded_config": "{{base64EncodedConfig}}"
  }
}
```

**Where `base64EncodedConfig` is:**
```json
{
  "params": {
    "inputJql": "key = {{issue.key}}",
    "initiator": "{{initiator.accountId}}"
  }
}
```

**Target (Option B - Hybrid, recommended for transition):**
```json
{
  "ref": "main",
  "inputs": {
    "config_file": "agents/learning_questions.json",
    "ticket_key": "{{issue.key}}",
    "encoded_config": "{{base64EncodedConfig}}"
  }
}
```

**Jira Smart Value for base64 encoding:**
- Jira automation doesn't have built-in base64 encoding
- **Solution:** Use a JavaScript action or webhook transformation

**Alternative:** Pass as JSON string (not base64):
```json
{
  "ref": "main",
  "inputs": {
    "config_file": "agents/learning_questions.json",
    "encoded_config": "{\"params\":{\"inputJql\":\"key = {{issue.key}}\",\"initiator\":\"{{initiator.accountId}}\"}}"
  }
}
```

**Note:** Check if `dmtools run` accepts JSON string or requires base64.

---

#### Step 4.3: Create Jira Automation Helper

**Problem:** Jira automation can't easily create base64-encoded JSON

**Solution Options:**

**Option 1: Use JavaScript Action in Jira**
1. Add JavaScript action before webhook
2. Create JSON object with ticket_key and initiator
3. Base64 encode it
4. Store in variable
5. Use variable in webhook body

**Option 2: Use Workflow Input Transformation**
- Modify workflow to accept JSON string
- Decode in workflow step before calling `dmtools run`

**Option 3: Keep ticket_key Input (Hybrid)**
- Accept `ticket_key` in workflow
- Build `encoded_config` inside workflow
- Pass to `dmtools run`

**Recommendation:** **Option 3 (Hybrid)** - Simplest for Jira automation

---

### Phase 5: Workflow Implementation

#### Step 5.1: Create Hybrid Workflow

**Proposed workflow structure:**

```yaml
name: AI Teammate (Learning)

on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Path to agent config'
        required: false
        type: string
        default: 'agents/learning_questions.json'
      encoded_config:
        description: 'Base64-encoded JSON with dynamic params'
        required: false
        type: string
      ticket_key:
        description: 'Jira ticket key (legacy support)'
        required: false
        type: string
      initiator:
        description: 'Jira account ID (legacy support)'
        required: false
        type: string

jobs:
  ai-teammate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '23'

      - name: Install Cursor CLI
        run: |
          # ... Cursor CLI installation ...

      - name: Install DMTools CLI
        env:
          DMTOOLS_LOCAL_SOURCE: ${{ github.workspace }}/releases
        run: |
          # ... Local file support + GitHub fallback ...

      - name: Build encoded_config from inputs
        id: build_config
        if: inputs.ticket_key != '' && inputs.encoded_config == ''
        run: |
          # Build JSON config from ticket_key and initiator
          CONFIG_JSON=$(cat <<EOF
          {
            "params": {
              "inputJql": "key = ${{ inputs.ticket_key }}",
              "initiator": "${{ inputs.initiator }}"
            }
          }
          EOF
          )
          # Encode to base64
          ENCODED=$(echo "$CONFIG_JSON" | base64 -w 0)
          echo "ENCODED_CONFIG=$ENCODED" >> $GITHUB_OUTPUT
          echo "Using ticket_key input: ${{ inputs.ticket_key }}"

      - name: Run AI Teammate
        env:
          CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
          MODEL: sonnet-4.5
          AGENT_DISABLE_WATCHDOG: "1"
          PATH: "/home/runner/.local/bin:/home/runner/.dmtools/bin:/bin:/usr/bin:$PATH"
          # Jira Configuration
          JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
          # AI Configuration
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          DEFAULT_LLM: "gemini"
          # Use encoded_config from step or input
          ENCODED_CONFIG: ${{ steps.build_config.outputs.ENCODED_CONFIG || inputs.encoded_config }}
        run: |
          CONFIG_FILE="${{ inputs.config_file || 'agents/learning_questions.json' }}"
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

#### Step 5.2: Test Workflow Locally First

**Before deploying to GitHub Actions:**

1. **Test agent config:**
   ```bash
   dmtools run agents/learning_questions.json
   ```

2. **Test with encoded_config:**
   ```bash
   ENCODED=$(echo '{"params":{"inputJql":"key = ATL-2","initiator":"your-id"}}' | base64 -w 0)
   dmtools run agents/learning_questions.json "$ENCODED"
   ```

3. **Verify:**
   - ✅ Ticket is fetched
   - ✅ Questions are generated
   - ✅ Sub-tickets are created
   - ✅ Labels are added

---

### Phase 6: Deployment and Testing

#### Step 6.1: Deploy Workflow to GitHub

**Actions:**
1. Create/update workflow file: `.github/workflows/ai-teammate-learning.yml`
2. Commit and push to `main` branch
3. Verify workflow appears in GitHub Actions

---

#### Step 6.2: Test Manual Trigger

**Actions:**
1. Go to: https://github.com/vospr/dmtools-ai-teammate/actions
2. Select workflow: "AI Teammate (Learning)"
3. Click "Run workflow"
4. Test scenarios:
   - **Scenario A:** With `ticket_key` input (legacy)
   - **Scenario B:** With `encoded_config` input (new)
   - **Scenario C:** With both (should prefer `encoded_config`)

---

#### Step 6.3: Update Jira Automation (Gradual)

**Option A: Update in Place**
1. Update webhook URL (if workflow name changed)
2. Update request body to use `encoded_config`
3. Test with one ticket

**Option B: Create New Rule (Recommended)**
1. Create new Jira automation rule: "AI Teammate v2"
2. Use new workflow and `encoded_config`
3. Keep old rule active for fallback
4. Test new rule
5. Disable old rule once confirmed working

---

#### Step 6.4: Verify End-to-End Flow

**Test checklist:**
- [ ] Jira automation triggers workflow
- [ ] Workflow receives inputs correctly
- [ ] Cursor CLI installs successfully
- [ ] dmtools CLI installs successfully
- [ ] Agent config is read correctly
- [ ] Ticket is fetched from Jira
- [ ] AI generates questions
- [ ] Sub-tickets are created
- [ ] Labels are added
- [ ] Ticket is assigned to initiator

---

### Phase 7: Cleanup (Optional)

#### Step 7.1: Remove Old Workflow

**After successful migration:**
- Archive or delete `learning-ai-teammate.yml`
- Update documentation references

---

#### Step 7.2: Remove Debug Logging

**If keeping local file support:**
- Remove DEBUG statements from `install.sh`
- Clean up verbose logging in workflow

---

## Migration Checklist

### Pre-Migration
- [ ] Understand `dmtools run` command behavior
- [ ] Test agent config locally with `dmtools run`
- [ ] Verify Cursor CLI requirement
- [ ] Check if reusable Java action exists
- [ ] Document current Jira automation setup

### Workflow Updates
- [ ] Create/update workflow file
- [ ] Update input format (hybrid approach)
- [ ] Add Cursor CLI installation step
- [ ] Update dmtools installation (keep local support)
- [ ] Replace execution steps with `dmtools run`
- [ ] Update permissions (if needed)
- [ ] Add all required environment variables
- [ ] Add config building step (ticket_key → encoded_config)

### Agent Config
- [ ] Verify agent config file is valid
- [ ] Test agent config with `dmtools run`
- [ ] Ensure dynamic parameters work via `encoded_config`

### Jira Automation
- [ ] Update webhook URL (if workflow name changed)
- [ ] Update request body format
- [ ] Test webhook manually
- [ ] Create new automation rule (or update existing)

### Testing
- [ ] Test workflow manually in GitHub Actions
- [ ] Test with `ticket_key` input (legacy)
- [ ] Test with `encoded_config` input (new)
- [ ] Test end-to-end from Jira automation
- [ ] Verify all steps complete successfully

### Deployment
- [ ] Commit workflow changes
- [ ] Push to `main` branch
- [ ] Verify workflow appears in GitHub Actions
- [ ] Update Jira automation
- [ ] Monitor first few runs

---

## Risks and Mitigations

### Risk 1: Cursor CLI Installation Fails
**Mitigation:**
- Add fallback: Skip Cursor CLI if not needed
- Make installation conditional based on agent config

### Risk 2: `dmtools run` Doesn't Work as Expected
**Mitigation:**
- Test locally first
- Keep explicit steps as fallback
- Add error handling in workflow

### Risk 3: Jira Automation Can't Create base64
**Mitigation:**
- Use hybrid approach (accept `ticket_key`, build `encoded_config` in workflow)
- Or use JavaScript action in Jira to encode

### Risk 4: Agent Config Doesn't Support Dynamic Params
**Mitigation:**
- Test agent config with `encoded_config` locally
- Verify `dmtools run` merges configs correctly

### Risk 5: Loss of Local File Support
**Mitigation:**
- Keep local file detection in dmtools installation
- Use hybrid approach (local first, GitHub fallback)

---

## Recommended Approach

### Option A: Full Migration (Simplest)
- Replace `learning-ai-teammate.yml` with `ai-teammate.yml` approach
- Use hybrid input format (support both `ticket_key` and `encoded_config`)
- Keep local file support for dmtools installation
- Make Cursor CLI optional (skip if not needed)

### Option B: Gradual Migration (Safest)
- Create new workflow: `ai-teammate-learning.yml`
- Keep `learning-ai-teammate.yml` active
- Test new workflow in parallel
- Switch Jira automation once confirmed
- Remove old workflow after success

### Option C: Hybrid Workflow (Recommended)
- Create workflow that supports both approaches
- Use `dmtools run` but keep explicit steps as fallback
- Support both input formats
- Best of both worlds

---

## Next Steps

1. **Decide on approach:** Full migration, gradual, or hybrid
2. **Test locally:** Verify `dmtools run` works with your agent config
3. **Create workflow:** Implement chosen approach
4. **Test in GitHub:** Manual trigger first
5. **Update Jira:** Update automation webhook
6. **Monitor:** Watch first few runs closely
7. **Iterate:** Fix any issues that arise

---

## Questions to Answer Before Migration

1. **Is Cursor CLI required?** 
   - Check if agent config actually uses Cursor CLI
   - If `skipAIProcessing: true`, might not need it

2. **Does `dmtools run` support your use case?**
   - Test locally with your agent config
   - Verify it creates sub-tickets correctly

3. **Can Jira automation create base64-encoded JSON?**
   - If not, use hybrid approach (accept `ticket_key`)

4. **Do you need PR creation capabilities?**
   - If not, keep `contents: read` permissions

5. **Do you want to keep local file support?**
   - Recommended: Yes (for CI/CD reliability)

---

**Last Updated:** January 2, 2026
