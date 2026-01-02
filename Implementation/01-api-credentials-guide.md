# API Credentials Setup Guide

This guide will walk you through obtaining all the necessary API tokens and credentials for your DMTools AI Teammate setup.

## Overview

You'll need to obtain credentials for the following services:

| Service | Purpose | Required | Time to Obtain |
|---------|---------|----------|----------------|
| **Jira** | Read/update tickets, create sub-tickets | ✅ Yes | 2 minutes |
| **Google Gemini** | AI processing for agent intelligence | ✅ Yes | 3 minutes |
| **Confluence** | Access knowledge base and documentation | ✅ Yes | Same as Jira |
| **GitHub** | Trigger GitHub Actions workflows | ✅ Yes | 3 minutes |
| **Cursor** | Execute Cursor AI agent locally | ⚠️ Optional | 2 minutes |
| **Figma** | Design file integration | ⚠️ Optional | 3 minutes |

**Total setup time: 10-15 minutes**

---

## 1. Jira API Token

### What You Need
- Your Jira email address
- API token for authentication

### Step-by-Step Instructions

1. **Navigate to Atlassian Account Settings**
   - Open your browser and go to: [https://id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
   - Log in with your Atlassian account

2. **Create API Token**
   - Click the **"Create API token"** button
   - Give it a descriptive label: `dmtools-ai-teammate`
   - Click **"Create"**

3. **Copy and Save**
   - **IMPORTANT:** Copy the token immediately (it won't be shown again)
   - Save it temporarily in a secure location (password manager recommended)
   - Format: `ATATT3xFfGF0...` (long alphanumeric string)

4. **Find Your Jira Base URL**
   - Your Jira URL format: `https://[your-company].atlassian.net`
   - Example: `https://mycompany.atlassian.net`
   - Note this down - you'll need it for configuration

### Verification
Test your token:

**For Linux/Mac/Git Bash:**
```bash
curl -u andrey_popov@epam.com:ATATT3xREDACTED_FOR_SECURITY \
  https://vospr.atlassian.net/rest/api/3/myself
```

**For Windows PowerShell (Recommended):**
```powershell
$email = "andrey_popov@epam.com"
$token = "ATATT3xREDACTED_FOR_SECURITY"
$auth = [Convert]::ToBase64String(
  [Text.Encoding]::UTF8.GetBytes("${email}:${token}")
)
Invoke-RestMethod `
  -Method GET `
  -Uri "https://vospr.atlassian.net/rest/api/3/myself" `
  -Headers @{
      Authorization = "Basic $auth"
      Accept = "application/json"
  }
```

**Alternative - Single line PowerShell (if using actual curl.exe):**
```powershell
curl.exe -u "andrey_popov@epam.com:ATATT3xREDACTED_FOR_SECURITY" https://vospr.atlassian.net/rest/api/3/myself
```

**Expected result:** JSON response with your user information (displayName, emailAddress, accountId)

---

## 2. Confluence API Token

### Good News!
If you're using Atlassian Cloud (most common), **Confluence uses the same API token as Jira**.

### Configuration Details
- **Confluence Base Path:** `https://[your-company].atlassian.net/wiki`
- **API Token:** Same as Jira token
- **Email:** Same as Jira email

### For On-Premise Confluence
If you have a separate on-premise Confluence installation:
1. Go to your Confluence profile
2. Navigate to **Settings > Personal Access Tokens**
3. Create a new token with appropriate permissions
4. Copy and save the token

### Verification
Test Confluence access:

**For Linux/Mac/Git Bash:**
```bash
curl -u andrey_popov@epam.com:ATATT3xREDACTED_FOR_SECURITY \
  https://vospr.atlassian.net/wiki/rest/api/space
```

**For Windows PowerShell (Recommended):**
```powershell
$email = "andrey_popov@epam.com"
$token = "ATATT3xREDACTED_FOR_SECURITY"
$auth = [Convert]::ToBase64String(
  [Text.Encoding]::UTF8.GetBytes("${email}:${token}")
)
Invoke-RestMethod `
  -Method GET `
  -Uri "https://vospr.atlassian.net/wiki/rest/api/space" `
  -Headers @{
      Authorization = "Basic $auth"
      Accept = "application/json"
  }
```

**Alternative - Single line PowerShell (if using actual curl.exe):**
```powershell
curl.exe -u "andrey_popov@epam.com:ATATT3xREDACTED_FOR_SECURITY" https://vospr.atlassian.net/wiki/rest/api/space
```

**Expected result:** JSON response listing available spaces

---

## 3. Google Gemini API Key

### What You Need
- Google account
- Access to Google AI Studio

### Step-by-Step Instructions

1. **Navigate to Google AI Studio**
   - Open: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
   - Sign in with your Google account

2. **Create API Key**
   - Click **"Create API Key"**
   - Choose:
     - **"Create API key in new project"** (if first time)
     - OR select an existing Google Cloud project
   - Click **"Create API key"**

3. **Copy and Save**
   - Copy the API key (format: `AIza...`)
   - Save it securely
   - **IMPORTANT:** This key provides access to paid Google services - keep it secure!

4. **Important Notes**
   - **Free Tier:** Gemini offers a free tier with rate limits
   - **Billing:** For production use, you may need to enable billing
   - **Rate Limits:** 60 requests per minute (free tier)
   - **Models Available:**
     - `gemini-2.0-flash-exp` (recommended for learning)
     - `gemini-1.5-pro-latest` (more capable, higher cost)
     - `gemini-2.5-flash-preview-05-20` (latest preview)

### Verification
Test your API key:
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyBq6hsJ5E5YJBodjI3RNZUSBHMCYsKjyW8"
```

**Expected result:** JSON list of available models (gemini-2.0-flash-exp, gemini-1.5-pro-latest, etc.)

---

## 4. GitHub Personal Access Token (PAT)

### What You Need
- GitHub account
- Repository with Actions enabled

### Step-by-Step Instructions

1. **Navigate to GitHub Token Settings**
   - Open: [https://github.com/settings/tokens](https://github.com/settings/tokens)
   - Click **"Generate new token"** → **"Generate new token (classic)"**

2. **Configure Token**
   - **Note:** `dmtools-ai-teammate-workflows`
   - **Expiration:** Choose based on your needs (90 days recommended for learning)
   
   - **Select Scopes:**
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
     - ✅ `read:org` (Read org and team membership, if applicable)

3. **Generate and Copy**
   - Click **"Generate token"** at the bottom
   - **CRITICAL:** Copy the token immediately (format: `ghp_...`)
   - You cannot see it again after leaving the page

4. **Token Usage**
   - This token will be used for:
     - Triggering GitHub Actions workflows from Jira automation
     - Creating pull requests (if needed)
     - Accessing repository contents in workflows

### Verification
Test your token:
```bash
curl -H "Authorization: token ghp_REDACTED_FOR_SECURITY" \
  https://api.github.com/user
```

**Expected result:** JSON with your GitHub user information (login, name, email, etc.)

---

## 5. Cursor API Key (Optional)

### What You Need
- Cursor IDE installed
- Active Cursor subscription (Pro or Business plan)

### Step-by-Step Instructions

1. **Check if You Need This**
   - ✅ **Need it:** If running agents locally with Cursor IDE
   - ❌ **Don't need it:** If only using GitHub Actions automation

2. **Find Your API Key**
   - Open Cursor IDE
   - Go to **Settings** (Ctrl+, or Cmd+,)
   - Navigate to **Cursor Settings** → **Models**
   - Look for **"API Key"** section
   - Alternatively, check: `~/.cursor/config.json`

3. **For GitHub Actions**
   - If using Cursor in GitHub Actions, you may need to set `CURSOR_API_KEY`
   - Contact Cursor support or check their documentation for CI/CD usage

### Alternative: Use Gemini Directly
For learning purposes, you can use **Gemini API directly** instead of Cursor:
- Modify agent configuration to use `dmtools gemini_ai_chat` instead of Cursor CLI
- This avoids needing a Cursor API key
- See `02-dmtools-installation.md` for details

---

## 6. Figma Personal Access Token (Optional)

### What You Need
- Figma account
- Access to design files you want to integrate

### Step-by-Step Instructions

1. **Navigate to Figma Account Settings**
   - Open: [https://www.figma.com/settings](https://www.figma.com/settings)
   - Log in to your Figma account

2. **Generate Personal Access Token**
   - Scroll to **"Personal access tokens"** section
   - Click **"Create new token"**
   - Description: `dmtools-ai-teammate`
   - Click **"Generate token"**

3. **Copy and Save**
   - Copy the token (format: `figd_...`)
   - Save it securely
   - **IMPORTANT:** This token provides access to your Figma files

4. **Token Permissions**
   - Read access to all files you have access to
   - Cannot modify or delete files
   - Used for downloading design screenshots

### Verification
Test your token:
```bash
curl -H "X-Figma-Token: figd_REDACTED_FOR_SECURITY" \
  https://api.figma.com/v1/me
```

**Expected result:** JSON with your Figma user information (email, handle, img_url, etc.)

---

## Summary Checklist

Before proceeding to the next step, make sure you have:

- [ ] **Jira API Token** - Format: `ATATT3xFfGF0...`
- [ ] **Jira Base URL** - Format: `https://yourcompany.atlassian.net`
- [ ] **Jira Email** - Your Atlassian account email
- [ ] **Confluence Base URL** - Format: `https://yourcompany.atlassian.net/wiki`
- [ ] **Gemini API Key** - Format: `AIza...`
- [ ] **GitHub Personal Access Token** - Format: `ghp_...`
- [ ] **Cursor API Key** (optional) - Check Cursor settings
- [ ] **Figma Token** (optional) - Format: `figd_...`

---

## Security Best Practices

### ✅ DO:
- Store tokens in a password manager (1Password, LastPass, Bitwarden)
- Use environment files (`.env`) that are in `.gitignore`
- Set appropriate token expiration dates
- Use separate tokens for development and production
- Rotate tokens regularly (every 90 days recommended)
- Use GitHub Secrets for storing tokens in CI/CD

### ❌ DON'T:
- Commit tokens to Git repositories (even private ones)
- Share tokens via email or chat
- Use the same token across multiple projects
- Store tokens in plain text files in your codebase
- Take screenshots of tokens and share them
- Use overly permissive token scopes

---

## What's Next?

Once you have all your credentials:

1. ✅ **Keep them secure** - Store in a password manager
2. ✅ **Verify each token** - Use the verification commands above
3. ✅ **Proceed to Step 2** - `02-dmtools-installation.md` for dmtools CLI setup

---

## Troubleshooting

### Jira Token Not Working
- **Issue:** Authentication error
- **Solution:** 
  - Verify email address is correct
  - Check token hasn't expired
  - Ensure you're using the correct Jira URL
  - Try generating a new token

### Gemini API Key Invalid
- **Issue:** `API_KEY_INVALID` error
- **Solution:**
  - Check for extra spaces when copying
  - Verify the key starts with `AIza`
  - Ensure you enabled the Generative Language API in Google Cloud

### GitHub Token Lacks Permissions
- **Issue:** `403 Forbidden` when triggering workflows
- **Solution:**
  - Regenerate token with `workflow` scope
  - Check repository permissions
  - Verify token hasn't expired

### Rate Limiting Issues
- **Gemini:** 60 requests/min (free tier) - wait or upgrade
- **Jira:** 10,000 requests/hour - unlikely to hit this
- **GitHub:** 5,000 requests/hour - unlikely to hit this

---

## Additional Resources

- **Jira REST API Documentation:** [https://developer.atlassian.com/cloud/jira/platform/rest/v3/](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- **Confluence REST API:** [https://developer.atlassian.com/cloud/confluence/rest/](https://developer.atlassian.com/cloud/confluence/rest/)
- **Gemini API Documentation:** [https://ai.google.dev/docs](https://ai.google.dev/docs)
- **GitHub Actions Documentation:** [https://docs.github.com/en/actions](https://docs.github.com/en/actions)
- **Figma API Documentation:** [https://www.figma.com/developers/api](https://www.figma.com/developers/api)

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Next Step:** [02-dmtools-installation.md](02-dmtools-installation.md)

