# GitHub Actions Setup Guide

This guide walks you through setting up GitHub Actions to automate your AI teammate workflows.

## Overview

**What We'll Set Up:**
- ✅ GitHub repository (choose existing or create new)
- ✅ GitHub Secrets for sensitive credentials
- ✅ GitHub Variables for configuration
- ✅ Workflow file for AI teammate automation
- ✅ Manual trigger capability for testing

**Time Required:** 20-30 minutes

---

## Architecture: GitHub Actions Workflow

```
┌────────────────────────────────────────────────────────────┐
│           GitHub Actions Workflow Flow                     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. Trigger                                                │
│     ├─ Manual (workflow_dispatch)                          │
│     └─ Webhook from Jira automation (later step)           │
│                                                            │
│  2. Setup Environment                                      │
│     ├─ Checkout code                                       │
│     ├─ Setup Java (for dmtools)                            │
│     ├─ Install dmtools CLI                                 │
│     └─ Load environment variables (secrets + vars)         │
│                                                            │
│  3. Execute Agent                                          │
│     ├─ Read agent configuration (learning_questions.json)  │
│     ├─ Get Jira ticket data (via dmtools)                  │
│     ├─ Call Gemini AI with prompt                          │
│     └─ Save response to outputs/response.md                │
│                                                            │
│  4. Post-Process                                           │
│     ├─ Execute JavaScript action (createQuestionsSimple.js)│
│     ├─ Create Jira sub-tickets                             │
│     ├─ Add labels                                          │
│     └─ Assign for review                                   │
│                                                            │
│  5. Report Results                                         │
│     ├─ Log summary                                         │
│     └─ Upload artifacts (for debugging)                    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## Step 1: Choose Repository

### Option A: Use Existing `dmtools-ai-teammate` Repository

**Pros:**
- Already has workflow structure
- Can reference existing examples
- Production-ready setup

**Cons:**
- Might have complexity you don't need yet

### Option B: Create New Learning Repository

**Pros:**
- Clean slate for learning
- No existing complexity
- Easy to experiment

**Cons:**
- Need to set up from scratch

**Recommendation for Learning:** Use **dmtools-ai-teammate** repository but in a separate branch.

---

## Step 2: Configure GitHub Secrets

Secrets are encrypted environment variables for sensitive data.

### Navigate to Repository Settings

1. Go to your repository: `https://github.com/YOUR_ORG/dmtools-ai-teammate`
2. Click **Settings** tab
3. Go to **Secrets and variables** → **Actions**
4. Click **Secrets** tab

### Add Required Secrets

Click **"New repository secret"** for each:

#### 1. JIRA_EMAIL
- **Name:** `JIRA_EMAIL`
- **Value:** Your Jira email address
- **Example:** `john.doe@company.com`

#### 2. JIRA_API_TOKEN
- **Name:** `JIRA_API_TOKEN`
- **Value:** Your Jira API token (from Step 1)
- **Example:** `ATATT3xFfGF0T...`

#### 3. GEMINI_API_KEY
- **Name:** `GEMINI_API_KEY`
- **Value:** Your Google Gemini API key
- **Example:** `AIzaSyD-9tSrKe...`

#### 4. CURSOR_API_KEY (Optional)
- **Name:** `CURSOR_API_KEY`
- **Value:** Your Cursor API key (if using Cursor CLI)
- **Note:** For learning, we can skip this and use Gemini directly

#### 5. FIGMA_TOKEN (Optional)
- **Name:** `FIGMA_TOKEN`
- **Value:** Your Figma personal access token
- **Example:** `figd_...`

#### 6. PAT_TOKEN (For PR creation, optional for now)
- **Name:** `PAT_TOKEN`
- **Value:** GitHub Personal Access Token
- **Use:** If agent needs to create pull requests

### Verify Secrets

After adding all secrets, you should see:

```
JIRA_EMAIL                      Updated X minutes ago
JIRA_API_TOKEN                  Updated X minutes ago
GEMINI_API_KEY                  Updated X minutes ago
CURSOR_API_KEY (optional)       Updated X minutes ago
FIGMA_TOKEN (optional)          Updated X minutes ago
PAT_TOKEN (optional)            Updated X minutes ago
```

---

## Step 3: Configure GitHub Variables

Variables are non-sensitive configuration that can be viewed in logs.

### Navigate to Variables Tab

1. Same location: **Settings** → **Secrets and variables** → **Actions**
2. Click **Variables** tab

### Add Required Variables

Click **"New repository variable"** for each:

#### 1. JIRA_BASE_PATH
- **Name:** `JIRA_BASE_PATH`
- **Value:** Your Jira URL
- **Example:** `https://yourcompany.atlassian.net`

#### 2. JIRA_AUTH_TYPE
- **Name:** `JIRA_AUTH_TYPE`
- **Value:** `basic`
- **Note:** For Atlassian Cloud, always use `basic`

#### 3. CONFLUENCE_BASE_PATH
- **Name:** `CONFLUENCE_BASE_PATH`
- **Value:** Your Confluence URL
- **Example:** `https://yourcompany.atlassian.net/wiki`

#### 4. CONFLUENCE_GRAPHQL_PATH
- **Name:** `CONFLUENCE_GRAPHQL_PATH`
- **Value:** GraphQL endpoint
- **Example:** `https://yourcompany.atlassian.net/gateway/api/graphql`

#### 5. CONFLUENCE_DEFAULT_SPACE (Optional)
- **Name:** `CONFLUENCE_DEFAULT_SPACE`
- **Value:** Default space key
- **Example:** `LEARNING`

#### 6. FIGMA_BASE_PATH (Optional)
- **Name:** `FIGMA_BASE_PATH`
- **Value:** `https://api.figma.com`

### Verify Variables

You should see:

```
JIRA_BASE_PATH                  Updated X minutes ago
JIRA_AUTH_TYPE                  Updated X minutes ago
CONFLUENCE_BASE_PATH            Updated X minutes ago
CONFLUENCE_GRAPHQL_PATH         Updated X minutes ago
```

---

## Step 4: Create Workflow File

Now create the GitHub Actions workflow file.

### File Location

Create: `.github/workflows/learning-ai-teammate.yml`

**Full path in your repo:**
```
dmtools-ai-teammate/
└── .github/
    └── workflows/
        └── learning-ai-teammate.yml
```

### Workflow Content

```yaml
name: Learning AI Teammate

on:
  workflow_dispatch:
    inputs:
      ticket_key:
        description: 'Jira ticket key to process (e.g., ATL-2)'
        required: true
        type: string
      config_file:
        description: 'Path to agent config (relative to repo root)'
        required: false
        type: string
        default: 'c:/Users/AndreyPopov/Documents/EPAM/AWS/GenAI Architect/ai-teammate/agents/learning_questions.json'

permissions:
  contents: read
  actions: read

jobs:
  process-ticket:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '11'
      
      - name: Install dmtools CLI
        run: |
          echo "📦 Installing dmtools CLI..."
          curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
          echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
          
          # Verify installation
          export PATH="$HOME/.dmtools/bin:$PATH"
          dmtools --version || echo "⚠️ dmtools version check failed"
      
      - name: Verify dmtools CLI
        run: |
          echo "🔍 Verifying dmtools installation..."
          which dmtools || echo "❌ dmtools not in PATH"
          dmtools --version || echo "❌ dmtools not working"
          dmtools list | head -20 || echo "❌ Cannot list tools"
      
      - name: Test Jira Connection
        env:
          JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
        run: |
          echo "🔗 Testing Jira connection..."
          dmtools jira_get_current_user || echo "❌ Jira connection failed"
      
      - name: Get Ticket Information
        id: get_ticket
        env:
          JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
        run: |
          echo "📋 Fetching ticket ${{ inputs.ticket_key }}..."
          dmtools jira_get_ticket ${{ inputs.ticket_key }} > ticket.json
          cat ticket.json
          
          # Extract summary for logging
          SUMMARY=$(cat ticket.json | jq -r '.fields.summary // "Unknown"')
          echo "Ticket summary: $SUMMARY"
          echo "TICKET_SUMMARY=$SUMMARY" >> $GITHUB_OUTPUT
      
      - name: Build AI Prompt
        id: build_prompt
        env:
          TICKET_KEY: ${{ inputs.ticket_key }}
        run: |
          echo "🤖 Building AI prompt..."
          
          # Read ticket data
          TICKET_JSON=$(cat ticket.json)
          SUMMARY=$(echo "$TICKET_JSON" | jq -r '.fields.summary')
          DESCRIPTION=$(echo "$TICKET_JSON" | jq -r '.fields.description // "No description"')
          
          # Create prompt file
          cat > prompt.txt <<'EOF'
          You are an Experienced Business Analyst analyzing Jira tickets.
          
          TICKET TO ANALYZE:
          Key: $TICKET_KEY
          Summary: $SUMMARY
          Description:
          $DESCRIPTION
          
          YOUR TASK:
          Generate 2-5 clarifying questions for any unclear requirements.
          
          OUTPUT FORMAT (must be valid JSON array):
          [
            {
              "summary": "Question summary (max 120 chars)",
              "priority": "High|Medium|Low",
              "description": "Detailed question in markdown"
            }
          ]
          
          If everything is crystal clear, output: []
          
          IMPORTANT: Output ONLY the JSON array, no other text.
          
          JSON array:
          EOF
          
          # Substitute variables
          sed -i "s/\$TICKET_KEY/$TICKET_KEY/g" prompt.txt
          sed -i "s/\$SUMMARY/$SUMMARY/g" prompt.txt
          sed -i "s/\$DESCRIPTION/$DESCRIPTION/g" prompt.txt
          
          echo "Prompt created:"
          cat prompt.txt
      
      - name: Call Gemini AI
        id: ai_response
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          echo "🧠 Calling Gemini AI..."
          
          PROMPT=$(cat prompt.txt)
          dmtools gemini_ai_chat "$PROMPT" > response.md
          
          echo "AI Response:"
          cat response.md
          
          # Validate JSON
          if grep -q '\[' response.md; then
            echo "✅ JSON array found in response"
          else
            echo "⚠️ No JSON array found in response"
          fi
      
      - name: Parse Questions
        id: parse_questions
        run: |
          echo "📝 Parsing questions from AI response..."
          
          # Extract JSON array from response
          RESPONSE=$(cat response.md)
          JSON=$(echo "$RESPONSE" | grep -oP '\[[\s\S]*\]' | head -1)
          
          if [ -z "$JSON" ]; then
            echo "No questions generated - requirements are clear!"
            echo "QUESTION_COUNT=0" >> $GITHUB_OUTPUT
            exit 0
          fi
          
          # Validate JSON
          echo "$JSON" | jq . > questions.json || {
            echo "❌ Invalid JSON!"
            exit 1
          }
          
          QUESTION_COUNT=$(echo "$JSON" | jq 'length')
          echo "Found $QUESTION_COUNT question(s)"
          echo "QUESTION_COUNT=$QUESTION_COUNT" >> $GITHUB_OUTPUT
          
          # Display questions
          echo "$JSON" | jq -r '.[] | "- \(.summary) [\(.priority)]"'
      
      - name: Create Sub-tickets
        if: steps.parse_questions.outputs.QUESTION_COUNT > 0
        env:
          JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
          TICKET_KEY: ${{ inputs.ticket_key }}
        run: |
          echo "🎫 Creating sub-tickets..."
          
          PROJECT_KEY=$(echo "$TICKET_KEY" | cut -d'-' -f1)
          QUESTIONS=$(cat questions.json)
          
          i=1
          echo "$QUESTIONS" | jq -c '.[]' | while read question; do
            SUMMARY=$(echo "$question" | jq -r '.summary')
            PRIORITY=$(echo "$question" | jq -r '.priority')
            DESC=$(echo "$question" | jq -r '.description')
            
            # Build summary with prefix
            FULL_SUMMARY="[Q$i] $SUMMARY"
            if [ ${#FULL_SUMMARY} -gt 120 ]; then
              FULL_SUMMARY="${FULL_SUMMARY:0:117}..."
            fi
            
            # Build description
            FULL_DESC="$DESC

---
*Generated by AI Teammate*
*Priority: $PRIORITY*"
            
            echo "Creating question $i: $FULL_SUMMARY"
            
            # Create ticket via dmtools
            # Note: This is a simplified version. The actual JavaScript action would be more robust.
            dmtools jira_create_ticket_with_json "{
              \"project\": \"$PROJECT_KEY\",
              \"fieldsJson\": {
                \"summary\": \"$FULL_SUMMARY\",
                \"description\": \"$FULL_DESC\",
                \"issuetype\": {\"name\": \"Sub-task\"},
                \"parent\": {\"key\": \"$TICKET_KEY\"},
                \"priority\": {\"name\": \"$PRIORITY\"}
              }
            }" || echo "Failed to create sub-ticket $i"
            
            i=$((i+1))
          done
      
      - name: Add Label
        if: steps.parse_questions.outputs.QUESTION_COUNT >= 0
        env:
          JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
          JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
          JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
          TICKET_KEY: ${{ inputs.ticket_key }}
        run: |
          echo "🏷️ Adding label..."
          
          if [ "${{ steps.parse_questions.outputs.QUESTION_COUNT }}" -eq "0" ]; then
            dmtools jira_add_label $TICKET_KEY "ai_no_questions_needed"
          else
            dmtools jira_add_label $TICKET_KEY "ai_questions_asked"
          fi
      
      - name: Summary
        run: |
          echo "========================================" 
          echo "AI TEAMMATE PROCESSING COMPLETE"
          echo "========================================"
          echo "Ticket: ${{ inputs.ticket_key }}"
          echo "Summary: ${{ steps.get_ticket.outputs.TICKET_SUMMARY }}"
          echo "Questions Created: ${{ steps.parse_questions.outputs.QUESTION_COUNT }}"
          echo "========================================"
          
          echo "✅ Check Jira: ${{ vars.JIRA_BASE_PATH }}/browse/${{ inputs.ticket_key }}"
      
      - name: Upload Artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ai-teammate-results-${{ github.run_number }}
          path: |
            ticket.json
            prompt.txt
            response.md
            questions.json
          retention-days: 7
```

---

## Step 5: Commit and Push Workflow

```bash
# Navigate to your dmtools-ai-teammate repository
cd c:\Users\AndreyPopov\dmtools-ai-teammate

# Create branch for learning
git checkout -b feature/learning-setup

# Create workflow file (copy content from above)
# Save to: .github/workflows/learning-ai-teammate.yml

# Commit
git add .github/workflows/learning-ai-teammate.yml
git commit -m "Add learning AI teammate workflow"

# Push
git push origin feature/learning-setup
```

---

## Step 6: Test Manual Trigger

### Trigger Workflow from GitHub UI

1. Go to **Actions** tab in your repository
2. Click **"Learning AI Teammate"** workflow in left sidebar
3. Click **"Run workflow"** dropdown button
4. Fill in inputs:
   - **ticket_key:** `ATL-2` (or your test ticket)
   - **config_file:** (leave default)
5. Click **"Run workflow"** button

### Monitor Execution

1. Workflow run will appear in the list
2. Click on the run to see details
3. Click on **"process-ticket"** job to see logs
4. Watch each step execute:
   - ✅ Install dmtools
   - ✅ Test Jira connection
   - ✅ Get ticket information
   - ✅ Build AI prompt
   - ✅ Call Gemini AI
   - ✅ Parse questions
   - ✅ Create sub-tickets
   - ✅ Add label

### Check Results

1. **In GitHub Actions:**
   - Check logs for success messages
   - Download artifacts to see AI response

2. **In Jira:**
   - Open ticket: `https://yourcompany.atlassian.net/browse/ATL-2`
   - Verify sub-tickets were created
   - Check label was added

---

## Troubleshooting

### Issue: "dmtools: command not found"

**Cause:** dmtools not in PATH after installation

**Solution:** Add this to workflow:
```yaml
- name: Add dmtools to PATH
  run: |
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
    export PATH="$HOME/.dmtools/bin:$PATH"
```

### Issue: "Authentication failed" with Jira

**Cause:** Secrets not configured correctly

**Debug steps:**
1. Check secret names match exactly (case-sensitive)
2. Verify JIRA_BASE_PATH has no trailing slash
3. Test authentication manually:
   ```yaml
   - name: Debug Jira Auth
     env:
       JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
       JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
     run: |
       echo "Email: $JIRA_EMAIL"
       echo "Base path: $JIRA_BASE_PATH"
       echo "Token length: ${#JIRA_API_TOKEN}"
   ```

### Issue: "Gemini API key invalid"

**Cause:** API key not set or incorrect

**Solution:**
1. Verify secret `GEMINI_API_KEY` exists
2. Check key starts with `AIza`
3. Test manually:
   ```bash
   curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_KEY"
   ```

### Issue: Sub-tickets not created

**Cause:** JSON format or API call failing

**Debug:**
```yaml
- name: Debug Sub-ticket Creation
  run: |
    echo "Project: $PROJECT_KEY"
    echo "Parent: $TICKET_KEY"
    cat questions.json
```

---

## Success Criteria

Your GitHub Actions setup is successful if:

- [ ] ✅ Workflow file exists in `.github/workflows/`
- [ ] ✅ All secrets are configured
- [ ] ✅ All variables are configured
- [ ] ✅ Manual trigger works
- [ ] ✅ dmtools installs successfully
- [ ] ✅ Jira authentication succeeds
- [ ] ✅ Gemini AI responds with questions
- [ ] ✅ Sub-tickets are created
- [ ] ✅ Labels are added
- [ ] ✅ Artifacts are uploaded

---

## What's Next?

Once GitHub Actions is working:

1. ✅ **Manual workflow trigger works**
2. ✅ **AI generates questions**
3. ✅ **Sub-tickets created automatically**

**→ Proceed to:** [07-jira-automation-setup.md](07-jira-automation-setup.md)

Set up Jira automation to trigger this workflow automatically when tickets are assigned.

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [05-local-testing-guide.md](05-local-testing-guide.md)  
**Next Step:** [07-jira-automation-setup.md](07-jira-automation-setup.md)

