# Quick Start - Your Credentials Are Ready! 🚀

Your API credentials have been configured! Here's what to do next.

## ✅ What's Already Done

1. **Credentials file created:** `c:\Users\AndreyPopov\dmtools\dmtools.env`
2. **All API tokens configured:**
   - ✅ Jira (https://vospr.atlassian.net)
   - ✅ Confluence (https://vospr.atlassian.net/wiki)
   - ✅ Gemini AI (AIzaSy...W8)
   - ✅ GitHub (https://github.com/vospr)
   - ✅ Cursor AI
   - ✅ Figma

## 🎯 Next Steps (30 minutes)

### Step 1: Test Your Credentials (5 minutes)

Open PowerShell and run:

```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-credentials.ps1
```

**Expected output:**
```
✅ Jira: Connected as Andrey Popov
📋 Account ID: 712020:xxxxx...
✅ Confluence: Found X space(s)
✅ Gemini AI: Configuration test successful
```

**IMPORTANT:** The script will save your Jira Account ID to `YOUR_JIRA_ACCOUNT_ID.txt` - you'll need this!

### Step 2: Get Your Jira Account ID (already done by script)

The test script automatically saved it, but you can also get it manually:

```powershell
dmtools jira_get_current_user
```

Look for: `"accountId": "712020:xxxxx..."`

### Step 3: Update Agent Configuration (2 minutes)

Open: [`agents\learning_questions.json`](agents\learning_questions.json)

Find this line:
```json
"initiator": "your-jira-account-id",
```

Replace with your actual account ID from Step 2:
```json
"initiator": "712020:xxxxx...",
```

Also update:
```json
"inputJql": "key = ATL-2",
```
(You'll create ATL-2 in the next step, so leave this for now)

### Step 4: Create Jira Learning Project (15 minutes)

Follow the guide: [`04-jira-project-setup.md`](04-jira-project-setup.md)

**Quick summary:**
1. Go to: https://vospr.atlassian.net
2. Create new project: "AI Teammate Learning" (key: **ATL**)
3. Create 3-5 test tickets using samples from [`test-data/sample-ticket-descriptions.md`](test-data/sample-ticket-descriptions.md)

**Key tickets to create:**
- **ATL-1:** User login (clear requirements)
- **ATL-2:** Dashboard analytics (vague - good for testing!)
- **ATL-3:** File upload (edge cases)

### Step 5: Test Locally (10 minutes)

Follow: [`05-local-testing-guide.md`](05-local-testing-guide.md)

**Quick test:**
```powershell
# Get ticket
$ticket = dmtools jira_get_ticket ATL-2

# Build simple prompt
$prompt = "Analyze this Jira ticket and generate 2-3 clarifying questions in JSON format: $ticket"

# Call AI
$response = dmtools gemini_ai_chat $prompt

# View response
$response
```

---

## 🔧 Optional: GitHub Actions Setup (1 hour)

Once local testing works, set up automation:

### Configure GitHub Secrets

Go to: https://github.com/vospr/dmtools-ai-teammate/settings/secrets/actions

(Or whichever repository you're using)

**Add these secrets:**

1. **JIRA_EMAIL**
   - Value: `andrey_popov@epam.com`

2. **JIRA_API_TOKEN**
   - Value: [Copy from dmtools.env]

3. **GEMINI_API_KEY**
   - Value: [Copy from dmtools.env]

4. **CURSOR_API_KEY** (optional)
   - Value: [Copy from dmtools.env]

5. **FIGMA_TOKEN** (optional)
   - Value: [Copy from dmtools.env]

6. **PAT_TOKEN**
   - Value: [Your GitHub token from dmtools.env]

**Add these variables:**

1. **JIRA_BASE_PATH**
   - Value: `https://vospr.atlassian.net`

2. **JIRA_AUTH_TYPE**
   - Value: `basic`

3. **CONFLUENCE_BASE_PATH**
   - Value: `https://vospr.atlassian.net/wiki`

4. **CONFLUENCE_GRAPHQL_PATH**
   - Value: `https://vospr.atlassian.net/gateway/api/graphql`

Then follow: [`06-github-actions-setup.md`](06-github-actions-setup.md)

---

## 📚 Full Learning Path

If you want the complete tutorial:

1. ✅ **[DONE]** API Credentials - [`01-api-credentials-guide.md`](01-api-credentials-guide.md)
2. ✅ **[DONE]** dmtools Installation - [`02-dmtools-installation.md`](02-dmtools-installation.md)
3. ✅ **[DONE]** Environment Configuration - [`dmtools-env-template.md`](dmtools-env-template.md)
4. 🎯 **[NEXT]** Test MCP Connection - [`03-mcp-connection-test.md`](03-mcp-connection-test.md)
5. 🎯 **[NEXT]** Create Jira Project - [`04-jira-project-setup.md`](04-jira-project-setup.md)
6. **[LATER]** Local Testing - [`05-local-testing-guide.md`](05-local-testing-guide.md)
7. **[LATER]** GitHub Actions - [`06-github-actions-setup.md`](06-github-actions-setup.md)
8. **[LATER]** Jira Automation - [`07-jira-automation-setup.md`](07-jira-automation-setup.md)
9. **[REFERENCE]** Troubleshooting - [`08-troubleshooting-guide.md`](08-troubleshooting-guide.md)
10. **[REVIEW]** Learning Summary - [`00-learning-summary.md`](00-learning-summary.md)

---

## 🆘 Troubleshooting

### Issue: "dmtools: command not found"

```powershell
# Add to PATH temporarily
$env:PATH += ";c:\Users\AndreyPopov\dmtools"

# Or use full path
c:\Users\AndreyPopov\dmtools\dmtools.bat --version
```

### Issue: "JIRA_BASE_PATH not set"

Environment variables not loaded. Run this first:

```powershell
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}
```

### Issue: "401 Unauthorized" from Jira

Your token might be copied with extra spaces. Check `dmtools.env` and ensure the token is on one line with no spaces around it.

### Issue: Test script won't run

Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🎓 Your Learning Journey

```
[✅] Step 1: Get API Tokens (DONE!)
[✅] Step 2: Configure dmtools.env (DONE!)
[⏳] Step 3: Test Credentials (← YOU ARE HERE)
[ ] Step 4: Create Jira Project
[ ] Step 5: Test Locally
[ ] Step 6: GitHub Actions
[ ] Step 7: Jira Automation
[🎯] Step 8: Working AI Teammate!
```

**Estimated time remaining:** 2-3 hours

---

## 📞 Need Help?

1. **Check troubleshooting guide:** [`08-troubleshooting-guide.md`](08-troubleshooting-guide.md)
2. **Review architecture:** [`00-learning-summary.md`](00-learning-summary.md)
3. **Test each layer:**
   - Credentials: Run `test-credentials.ps1`
   - dmtools CLI: `dmtools --version`
   - Jira API: `dmtools jira_get_current_user`
   - Gemini AI: `dmtools gemini_ai_chat "test"`

---

## 🎉 Ready to Start?

**Run this now:**

```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-credentials.ps1
```

Then proceed to Step 4: Create your Jira learning project!

**Good luck! 🚀**

---

**Last Updated:** December 30, 2025  
**Status:** Credentials configured, ready for testing ✅

