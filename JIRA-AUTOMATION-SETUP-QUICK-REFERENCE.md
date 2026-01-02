# Jira Automation Setup - Quick Reference

## Ready-to-Use Configuration

This file contains the exact configuration you need to copy into your Jira automation rule.

---

## Webhook Configuration

### Webhook URL
```
https://api.github.com/repos/vospr/dmtools-ai-teammate/actions/workflows/learning-ai-teammate.yml/dispatches
```

### HTTP Method
```
POST
```

### Headers
```
Accept: application/vnd.github.v3+json
Authorization: token {{githubToken}}
Content-Type: application/json
```

### Request Body (JSON)
```json
{
  "ref": "main",
  "inputs": {
    "ticket_key": "{{issue.key}}",
    "config_file": "agents/learning_questions.json"
  }
}
```

### Web Request Body Type
```
Custom data
```

### Delay Execution
```
0 seconds
```

---

## Step-by-Step Setup in Jira

### 1. Create GitHub Token Variable

**Variable name:** `githubToken`  
**Smart value:** Your GitHub Personal Access Token (PAT) with `repo` and `actions:write` permissions

**How to create GitHub PAT:**
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Select scopes: `repo`, `workflow`
4. Copy the token (format: `ghp_...`)
5. Paste into Jira automation variable `{{githubToken}}`

---

### 2. Configure Webhook Action

**Action type:** `Send web request`

**Configuration:**
- **Webhook URL:** Copy from above
- **HTTP Method:** `POST`
- **Headers:** Copy all three headers from above
- **Request Body:** Copy the JSON from above
- **Web request body type:** `Custom data`
- **Delay execution:** `0 seconds` (or 5-10 seconds if needed)

---

### 3. Automation Rule Trigger

**When:** Work item assigned  
**Condition:** Assignee is "AI Teammate"  
**Additional Condition:** Labels contains none of `ai_questions_asked`

---

## Verification Checklist

- [ ] GitHub PAT token created with `repo` and `workflow` scopes
- [ ] GitHub token stored in Jira variable `{{githubToken}}`
- [ ] Webhook URL points to correct repository: `vospr/dmtools-ai-teammate`
- [ ] Webhook URL points to correct workflow: `learning-ai-teammate.yml`
- [ ] Request body uses `"ref": "main"` (not `TEST` or other branch)
- [ ] Request body uses `"config_file": "agents/learning_questions.json"` (relative path, not Windows path)
- [ ] Automation rule triggers on assignment to "AI Teammate"
- [ ] Automation rule checks for `ai_questions_asked` label to prevent duplicates

---

## Testing the Automation

1. **Create a test ticket** in your Jira project (e.g., `ATL-2`)
2. **Assign the ticket** to "AI Teammate" user
3. **Check GitHub Actions:**
   - Go to: https://github.com/vospr/dmtools-ai-teammate/actions
   - Look for a new workflow run triggered by "Learning AI Teammate"
4. **Check Jira ticket:**
   - After workflow completes, check if sub-tickets were created
   - Check if label `ai_questions_asked` or `ai_no_questions_needed` was added

---

## Troubleshooting

### Webhook returns 404
- Verify the workflow file exists: `.github/workflows/learning-ai-teammate.yml`
- Verify the repository name is correct: `dmtools-ai-teammate`
- Verify the organization is correct: `vospr`

### Webhook returns 401 Unauthorized
- Check that `{{githubToken}}` variable is set correctly
- Verify the GitHub PAT has `repo` and `workflow` scopes
- Check that the token hasn't expired

### Workflow runs but fails
- Check GitHub Actions logs for error messages
- Verify all required secrets are set in GitHub repository:
  - `JIRA_EMAIL`
  - `JIRA_API_TOKEN`
  - `GEMINI_API_KEY`
- Verify all required variables are set in GitHub repository:
  - `JIRA_BASE_PATH`
  - `JIRA_AUTH_TYPE`

### Config file not found
- Verify `agents/learning_questions.json` exists in the `main` branch
- Check that the path in webhook body is: `agents/learning_questions.json` (relative, not absolute)

---

## Files Reference

- **Webhook config JSON:** `jira-automation-webhook-config.json`
- **Webhook body only:** `webhook-body-reference.json`
- **Workflow file:** `.github/workflows/learning-ai-teammate.yml`
- **Config file:** `agents/learning_questions.json`

---

**Last updated:** After TEST → main merge  
**Branch:** `main`  
**Status:** Ready for automation testing
