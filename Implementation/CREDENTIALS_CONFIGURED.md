# Credentials Configuration Summary

✅ **Status:** All credentials have been configured

## Configured Services

### 1. Jira
- **URL:** https://vospr.atlassian.net
- **Email:** andrey_popov@epam.com
- **Token:** Configured ✅
- **Auth Type:** basic

### 2. Confluence
- **URL:** https://vospr.atlassian.net/wiki
- **Email:** andrey_popov@epam.com (same as Jira)
- **Token:** Same as Jira token ✅
- **GraphQL:** https://vospr.atlassian.net/gateway/api/graphql

### 3. Google Gemini AI
- **API Key:** Configured ✅
- **Project:** dmtools-ai-teammate
- **Project ID:** projects/192578446190
- **Model:** gemini-2.0-flash-exp

### 4. GitHub
- **Token:** Configured ✅
- **Organization:** vospr
- **Workflow Name:** dmtools-ai-teammate-workflows
- **URL:** https://github.com/vospr

### 5. Cursor AI
- **API Key:** Configured ✅
- **Email:** andrey_popov@epam.com

### 6. Figma
- **Token:** Configured ✅
- **Email:** andrey_popov@epam.com

### 7. AI Teammate
- **Email:** ai.vospr@gmail.com
- **Purpose:** AI agent notifications and operations

## Files Created

### Main Configuration
- ✅ `c:\Users\AndreyPopov\dmtools\dmtools.env`

## Next Steps

### 1. Verify Credentials Work

Run these commands to test each service:

```powershell
# Test Jira connection
dmtools jira_get_current_user

# Expected output: Your user information
```

```powershell
# Test Confluence access
dmtools confluence_list_spaces

# Expected output: List of available spaces
```

```powershell
# Test Gemini AI
dmtools gemini_ai_chat "Hello, please respond with 'Configuration successful!'"

# Expected output: "Configuration successful!"
```

```powershell
# Test GitHub (if dmtools has GitHub tool)
dmtools github_get_current_user

# Expected output: Your GitHub user info
```

### 2. Create Jira Test Project

Follow: [`04-jira-project-setup.md`](04-jira-project-setup.md)

Create project with key: **ATL** (AI Teammate Learning)

### 3. Get Your Jira Account ID

You'll need this for the agent configuration:

```powershell
# Run this and note your accountId
dmtools jira_get_current_user

# Look for: "accountId": "712020:xxxxx..."
```

### 4. Update Agent Configuration

Once you have your Jira account ID, update:

[`agents/learning_questions.json`](agents/learning_questions.json)

Change this line:
```json
"initiator": "your-jira-account-id"
```

To your actual account ID:
```json
"initiator": "712020:xxxxx..."
```

### 5. Configure GitHub Secrets

Go to: https://github.com/vospr/dmtools-ai-teammate/settings/secrets/actions

Add these secrets:
- `JIRA_EMAIL` = `andrey_popov@epam.com`
- `JIRA_API_TOKEN` = [your Jira token]
- `GEMINI_API_KEY` = [your Gemini key]
- `CURSOR_API_KEY` = [your Cursor key]
- `FIGMA_TOKEN` = [your Figma token]
- `PAT_TOKEN` = [your GitHub token]

Add these variables:
- `JIRA_BASE_PATH` = `https://vospr.atlassian.net`
- `JIRA_AUTH_TYPE` = `basic`
- `CONFLUENCE_BASE_PATH` = `https://vospr.atlassian.net/wiki`
- `CONFLUENCE_GRAPHQL_PATH` = `https://vospr.atlassian.net/gateway/api/graphql`

## Quick Test Script

Save this as `test-credentials.ps1` and run it:

```powershell
# Load environment variables
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

Write-Host "Testing Jira connection..." -ForegroundColor Yellow
try {
    $user = dmtools jira_get_current_user | ConvertFrom-Json
    Write-Host "✅ Jira: Connected as $($user.displayName)" -ForegroundColor Green
    Write-Host "   Account ID: $($user.accountId)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Jira: Failed - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Testing Confluence connection..." -ForegroundColor Yellow
try {
    dmtools confluence_list_spaces | Out-Null
    Write-Host "✅ Confluence: Connected" -ForegroundColor Green
} catch {
    Write-Host "❌ Confluence: Failed - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Testing Gemini AI..." -ForegroundColor Yellow
try {
    $response = dmtools gemini_ai_chat "Respond with just: OK"
    if ($response -match "OK") {
        Write-Host "✅ Gemini AI: Connected and responding" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Gemini AI: Connected but unexpected response" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Gemini AI: Failed - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
```

## Security Reminders

⚠️ **IMPORTANT:**

1. **Never commit `dmtools.env` to Git**
   - It's already in `.gitignore`
   - Double-check before any git commit

2. **Rotate tokens regularly**
   - Jira/Confluence: Every 90 days
   - GitHub PAT: Set expiration date
   - Gemini API Key: Monitor usage

3. **Monitor token usage**
   - Jira: Check API usage in admin panel
   - GitHub: https://github.com/settings/tokens
   - Gemini: https://console.cloud.google.com/apis/

4. **If tokens are compromised:**
   - Regenerate immediately
   - Update `dmtools.env`
   - Update GitHub Secrets
   - Check audit logs for unauthorized access

## Troubleshooting

### Issue: "dmtools: command not found"

Solution:
```powershell
# Add dmtools to PATH
$env:PATH += ";c:\Users\AndreyPopov\dmtools"

# Or run with full path
c:\Users\AndreyPopov\dmtools\dmtools.bat --version
```

### Issue: "JIRA_BASE_PATH not set"

Solution:
```powershell
# Load environment manually
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}
```

### Issue: "401 Unauthorized" from Jira

Possible causes:
- Token expired
- Wrong email address
- Token copied with extra spaces

Solution: Regenerate token at https://id.atlassian.com/manage-profile/security/api-tokens

## Support

If you encounter issues:

1. Check [`08-troubleshooting-guide.md`](08-troubleshooting-guide.md)
2. Test each layer independently
3. Verify token hasn't expired
4. Check firewall/proxy settings

---

**Last Updated:** December 30, 2025  
**Status:** Ready for testing ✅

