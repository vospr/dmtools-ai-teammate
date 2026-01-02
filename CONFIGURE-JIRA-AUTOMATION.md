# Configure Jira Automation Rule - Step-by-Step Guide

This guide walks you through configuring the Jira automation rule using the configuration files in this repository.

---

## Prerequisites

- Access to your Jira project with automation permissions
- GitHub Personal Access Token (PAT) with `repo` and `workflow` scopes
  - **Note:** You can reuse the same PAT you saved in GitHub Secrets (`PAT_TOKEN`) if it has these scopes
- "AI Teammate" user account created in Jira

---

## Step 1: Create GitHub Token Variable in Jira

### 1.1. Get Your GitHub PAT

**You can reuse your existing GitHub PAT** if it has the required scopes (`repo` and `workflow`). 

**If you already have a PAT** (e.g., saved in `dmtools.env` or GitHub Secrets as `PAT_TOKEN`):
- ✅ **You can reuse it** - Just copy the same token value
- ✅ **Check scopes:** Ensure it has `repo` and `workflow` permissions
- ✅ **No need to generate a new one** unless you want separate tokens for security

**If you need to create a new PAT** (or verify your existing one):

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `Jira Automation - AI Teammate` (or reuse existing name)
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click **"Generate token"**
6. **Copy the token immediately** (format: `ghp_...`)

**Note:** The same PAT can be used for:
- GitHub Secrets (`PAT_TOKEN`) - Used by GitHub Actions workflows
- Jira Automation (`githubToken`) - Used by Jira to trigger workflows

### 1.2. Store Token in Jira Automation

1. In Jira, go to your project → **Project settings** → **Automation**
2. Click **"Create rule"** or edit an existing rule
3. Click **"Add component"** → **"Create variable"**
4. Configure:
   - **Variable name:** `githubToken`
   - **Smart value:** Paste your GitHub PAT token (can be the same one from `PAT_TOKEN` if it has `repo` and `workflow` scopes)
5. Click **"Save"**

**Important:** Keep this token secure. It has access to your GitHub repository.

---

## Step 2: Configure Automation Rule Trigger

### 2.1. Set Up Trigger

1. In your automation rule, click **"When"**
2. Select: **"Work item assigned"**
3. Click **"Save"**

### 2.2. Add Condition

1. Click **"Add condition"**
2. Select: **"Assignee condition"**
3. Configure:
   - **Assignee is:** `AI Teammate` (select the user account you created)
4. Click **"Save"**

### 2.3. Add Additional Condition (Prevent Duplicates)

1. Click **"Add condition"** again
2. Select: **"Labels condition"**
3. Configure:
   - **Labels contains none of:** `ai_questions_asked`
4. Click **"Save"**

This prevents the automation from running multiple times on the same ticket.

---

## Step 3: Configure Webhook Action

### 3.1. Add Webhook Action

1. Click **"Then"** → **"Add component"**
2. Select: **"Send web request"**

### 3.2. Configure Webhook Details

**Copy values from `jira-automation-webhook-config.json`:**

#### HTTP Method
```
POST
```

#### Webhook URL
```
https://api.github.com/repos/vospr/dmtools-ai-teammate/actions/workflows/learning-ai-teammate.yml/dispatches
```

**Note:** If your repository is different, replace:
- `vospr` with your GitHub organization/username
- `dmtools-ai-teammate` with your repository name

#### Headers

Add three headers (one per line):

**Header 1:**
- **Name:** `Accept`
- **Value:** `application/vnd.github.v3+json`

**Header 2:**
- **Name:** `Authorization`
- **Value:** `token {{githubToken}}`

**Header 3:**
- **Name:** `Content-Type`
- **Value:** `application/json`

### 3.3. Configure Request Body

**Copy from `webhook-body-reference.json` or use this:**

```json
{
  "ref": "main",
  "inputs": {
    "ticket_key": "{{issue.key}}",
    "config_file": "agents/learning_questions.json"
  }
}
```

**Important settings:**
- **Web request body type:** Select `Custom data` (not `Form data`)
- **Delay execution:** `0` seconds (or 5-10 seconds if needed)

### 3.4. Save Webhook Action

Click **"Save"** to save the webhook action.

---

## Step 4: Add Optional Comment Action (Recommended)

This helps track when automation is triggered.

1. Click **"Add component"** after the webhook
2. Select: **"Add comment"**
3. Configure:
   - **Comment:**
   ```
   🤖 AI Teammate processing started...
   
   The AI is analyzing this ticket to generate clarifying questions. You'll be notified when complete.
   
   Triggered by: {{initiator.displayName}}
   GitHub Actions Run: Check [workflow runs](https://github.com/vospr/dmtools-ai-teammate/actions)
   ```
4. Click **"Save"**

---

## Step 5: Save and Activate Rule

1. Review your automation rule configuration
2. Give it a name: `AI Teammate - Generate Questions`
3. Click **"Save"** or **"Turn it on"**

---

## Step 6: Test the Automation

### 6.1. Create Test Ticket

1. Create a new ticket in your Jira project (e.g., `ATL-2`)
2. Add a description with some requirements (can be vague to trigger questions)
3. **Assign the ticket to "AI Teammate"**

### 6.2. Verify Webhook Triggered

1. Go to: https://github.com/vospr/dmtools-ai-teammate/actions
2. Look for a new workflow run:
   - **Workflow:** "Learning AI Teammate"
   - **Triggered by:** workflow_dispatch
   - **Status:** Should show "In progress" or "Completed"

### 6.3. Check Workflow Logs

1. Click on the workflow run
2. Check each step:
   - ✅ Checkout repository
   - ✅ Setup Java
   - ✅ Install dmtools CLI
   - ✅ Get Ticket Information
   - ✅ Call Gemini AI
   - ✅ Parse Questions
   - ✅ Create Sub-tickets (if questions were generated)
   - ✅ Add Label

### 6.4. Verify Results in Jira

1. Go back to your test ticket in Jira
2. Check for:
   - **Label added:** `ai_questions_asked` or `ai_no_questions_needed`
   - **Sub-tickets created:** If questions were generated, you should see sub-tasks
   - **Comment added:** If you configured the comment action

---

## Troubleshooting

### Webhook Returns 404 Not Found

**Problem:** GitHub API returns 404 when webhook is triggered.

**Solutions:**
1. Verify the webhook URL is correct:
   - Check organization: `vospr`
   - Check repository: `dmtools-ai-teammate`
   - Check workflow file: `learning-ai-teammate.yml`
2. Verify the workflow file exists:
   - Go to: https://github.com/vospr/dmtools-ai-teammate/tree/main/.github/workflows
   - Confirm `learning-ai-teammate.yml` exists
3. Verify you're using the correct branch: `main`

### Webhook Returns 401 Unauthorized

**Problem:** GitHub API returns 401 Unauthorized.

**Solutions:**
1. Check that `{{githubToken}}` variable is set correctly in Jira
2. Verify the GitHub PAT token has not expired
3. Verify the token has `repo` and `workflow` scopes
4. Try regenerating the token and updating the Jira variable

### Workflow Runs But Fails

**Problem:** Workflow is triggered but fails during execution.

**Solutions:**
1. Check GitHub Actions logs for specific error messages
2. Verify all required secrets are set in GitHub:
   - Go to: Repository → Settings → Secrets and variables → Actions → Secrets
   - Required secrets:
     - `JIRA_EMAIL`
     - `JIRA_API_TOKEN`
     - `GEMINI_API_KEY`
3. Verify all required variables are set:
   - Go to: Repository → Settings → Secrets and variables → Actions → Variables
   - Required variables:
     - `JIRA_BASE_PATH`
     - `JIRA_AUTH_TYPE`

### Config File Not Found

**Problem:** Workflow fails with "config file not found" error.

**Solutions:**
1. Verify `agents/learning_questions.json` exists in the `main` branch:
   - Go to: https://github.com/vospr/dmtools-ai-teammate/tree/main/agents
   - Confirm `learning_questions.json` exists
2. Verify the path in webhook body is correct:
   - Should be: `agents/learning_questions.json` (relative path)
   - NOT: `c:/Users/...` (Windows absolute path)

### Automation Doesn't Trigger

**Problem:** Assigning ticket to "AI Teammate" doesn't trigger automation.

**Solutions:**
1. Verify the automation rule is enabled (turned on)
2. Check the trigger condition:
   - Assignee must be exactly "AI Teammate"
   - Case-sensitive: "AI Teammate" not "ai teammate"
3. Check the label condition:
   - If ticket already has `ai_questions_asked` label, automation won't run
   - Remove the label to test again
4. Check Jira automation logs:
   - Go to: Project settings → Automation → View rule → Execution history

---

## Configuration Files Reference

All configuration values are available in these files:

- **Complete webhook config:** `jira-automation-webhook-config.json`
- **Webhook body only:** `webhook-body-reference.json`
- **Quick reference guide:** `JIRA-AUTOMATION-SETUP-QUICK-REFERENCE.md`
- **This detailed guide:** `CONFIGURE-JIRA-AUTOMATION.md`

---

## Verification Checklist

Before testing, verify:

- [ ] GitHub PAT token created with `repo` and `workflow` scopes
- [ ] GitHub token stored in Jira variable `{{githubToken}}`
- [ ] "AI Teammate" user account exists in Jira
- [ ] Automation rule trigger: "Work item assigned" to "AI Teammate"
- [ ] Automation rule condition: Labels does not contain `ai_questions_asked`
- [ ] Webhook URL is correct: `https://api.github.com/repos/vospr/dmtools-ai-teammate/actions/workflows/learning-ai-teammate.yml/dispatches`
- [ ] Webhook headers are correct (all three)
- [ ] Request body uses `"ref": "main"`
- [ ] Request body uses `"config_file": "agents/learning_questions.json"`
- [ ] All GitHub secrets are set: `JIRA_EMAIL`, `JIRA_API_TOKEN`, `GEMINI_API_KEY`
- [ ] All GitHub variables are set: `JIRA_BASE_PATH`, `JIRA_AUTH_TYPE`
- [ ] Workflow file exists: `.github/workflows/learning-ai-teammate.yml`
- [ ] Config file exists: `agents/learning_questions.json`

---

## Next Steps After Configuration

1. **Test with a real ticket** that needs clarification
2. **Monitor the first few runs** to ensure everything works correctly
3. **Adjust delay execution** if needed (some Jira instances need 5-10 seconds)
4. **Review generated questions** to ensure AI is working as expected
5. **Fine-tune the automation** based on your team's needs

---

**Status:** Ready to configure  
**Last updated:** After TEST → main merge  
**Branch:** `main`
