# dmtools.env Configuration Template

This document explains how to create your `dmtools.env` configuration file with all the API credentials you obtained in Step 1.

## Location

Create this file at: **`c:\Users\AndreyPopov\dmtools\dmtools.env`**

## Security Warning

⚠️ **IMPORTANT:** This file contains sensitive credentials
- **DO NOT** commit this file to Git
- Verify `.gitignore` includes `dmtools.env`
- File permissions should be read-only for your user
- Never share this file or take screenshots

---

## Configuration Template

Copy the template below and replace placeholder values with your actual credentials:

```properties
# =============================================================================
# JIRA CONFIGURATION (Required)
# =============================================================================
# Your Jira instance base URL (from Step 1)
JIRA_BASE_PATH=https://yourcompany.atlassian.net

# Your Jira email address
JIRA_EMAIL=your.email@company.com

# Jira API token (from Step 1: 01-api-credentials-guide.md)
JIRA_API_TOKEN=ATATT3xFfGF0T_your_actual_token_here

# Authentication type (use 'basic' for Atlassian Cloud)
JIRA_AUTH_TYPE=basic

# Optional: Enable detailed logging for debugging
# JIRA_LOGGING_ENABLED=true

# Optional: Extra fields to fetch (comma-separated custom field IDs)
# JIRA_EXTRA_FIELDS=customfield_10001,customfield_10002

# =============================================================================
# CONFLUENCE CONFIGURATION (Required)
# =============================================================================
# Your Confluence instance base URL
CONFLUENCE_BASE_PATH=https://yourcompany.atlassian.net/wiki

# Confluence email (usually same as Jira)
CONFLUENCE_EMAIL=your.email@company.com

# Confluence API token (same as Jira token for Atlassian Cloud)
CONFLUENCE_API_TOKEN=ATATT3xFfGF0T_your_actual_token_here

# Authentication type
CONFLUENCE_AUTH_TYPE=basic

# Optional: Default space key for operations
# CONFLUENCE_DEFAULT_SPACE=LEARNING

# Optional: GraphQL endpoint for advanced queries
CONFLUENCE_GRAPHQL_PATH=https://yourcompany.atlassian.net/gateway/api/graphql

# =============================================================================
# GOOGLE GEMINI CONFIGURATION (Required)
# =============================================================================
# Google Gemini API Key (from Step 1: 01-api-credentials-guide.md)
GEMINI_API_KEY=AIza_your_actual_api_key_here

# Default Gemini model to use
GEMINI_DEFAULT_MODEL=gemini-2.0-flash-exp

# Optional: Gemini base path (use default unless you have a custom endpoint)
# GEMINI_BASE_PATH=https://generativelanguage.googleapis.com/v1beta/models

# =============================================================================
# GITHUB CONFIGURATION (Required for GitHub Actions workflows)
# =============================================================================
# GitHub Personal Access Token (from Step 1: 01-api-credentials-guide.md)
GITHUB_TOKEN=ghp_your_actual_token_here

# Optional: GitHub organization or user name
# GITHUB_WORKSPACE=your-org

# Optional: Default repository name
# GITHUB_REPOSITORY=dmtools-ai-teammate

# Optional: Default branch
# GITHUB_BRANCH=main

# Optional: GitHub API base path (use default unless using GitHub Enterprise)
# GITHUB_BASE_PATH=https://api.github.com

# =============================================================================
# FIGMA CONFIGURATION (Optional - for design integration)
# =============================================================================
# Figma Personal Access Token (from Step 1: 01-api-credentials-guide.md)
FIGMA_API_KEY=figd_your_actual_token_here

# Figma base path (use default)
# FIGMA_BASE_PATH=https://api.figma.com

# =============================================================================
# CURSOR CONFIGURATION (Optional - for local Cursor AI execution)
# =============================================================================
# Cursor API key (from your Cursor IDE settings or subscription)
# CURSOR_API_KEY=your_cursor_api_key_here

# =============================================================================
# ADVANCED CONFIGURATION (Optional - use defaults for learning)
# =============================================================================
# AI retry configuration
# AI_RETRY_AMOUNT=3
# AI_RETRY_DELAY_STEP=20000

# Prompt configuration for chunking large contexts
# PROMPT_CHUNK_TOKEN_LIMIT=4000
# PROMPT_CHUNK_MAX_SINGLE_FILE_SIZE_MB=4
# PROMPT_CHUNK_MAX_TOTAL_FILES_SIZE_MB=4
# PROMPT_CHUNK_MAX_FILES=10

# Request throttling (milliseconds between requests)
# SLEEP_TIME_REQUEST=1000

# =============================================================================
# GITLAB CONFIGURATION (Optional - if using GitLab instead of GitHub)
# =============================================================================
# GITLAB_TOKEN=glpat_your_gitlab_token_here
# GITLAB_WORKSPACE=your-group
# GITLAB_REPOSITORY=your-repo
# GITLAB_BRANCH=main
# GITLAB_BASE_PATH=https://gitlab.com/api/v4

# =============================================================================
# BITBUCKET CONFIGURATION (Optional - if using Bitbucket)
# =============================================================================
# BITBUCKET_TOKEN=your_bitbucket_app_password_here
# BITBUCKET_WORKSPACE=your-workspace
# BITBUCKET_REPOSITORY=your-repo
# BITBUCKET_BRANCH=main
# BITBUCKET_API_VERSION=2.0
# BITBUCKET_BASE_PATH=https://api.bitbucket.org
```

---

## Step-by-Step Configuration Instructions

### Step 1: Create the File

Open PowerShell and create the file:

```powershell
cd "c:\Users\AndreyPopov\dmtools"
notepad dmtools.env
```

### Step 2: Copy the Template

1. Copy the template above (from the Configuration Template section)
2. Paste it into notepad
3. **DO NOT save yet** - we need to replace placeholder values

### Step 3: Fill in Your Credentials

Replace these placeholder values with your actual credentials from Step 1:

| Placeholder | Replace With | Example |
|------------|--------------|---------|
| `yourcompany` | Your Atlassian subdomain | `mycompany` |
| `your.email@company.com` | Your email address | `john.doe@example.com` |
| `ATATT3xFfGF0T_your_actual_token_here` | Your Jira API token | `ATATT3xFfGF0TjqL8r...` |
| `AIza_your_actual_api_key_here` | Your Gemini API key | `AIzaSyD-9tSrKe4P...` |
| `ghp_your_actual_token_here` | Your GitHub token | `ghp_16C7e42F292c...` |
| `figd_your_actual_token_here` | Your Figma token (if using) | `figd_DJx8K3F2vN...` |

### Step 4: Verify URLs

Make sure your URLs are correct:

**Jira URL format:**
```
JIRA_BASE_PATH=https://yourcompany.atlassian.net
```
- ✅ Correct: `https://acme.atlassian.net`
- ❌ Wrong: `https://acme.atlassian.net/` (no trailing slash)
- ❌ Wrong: `https://jira.acme.com/jira` (not Atlassian Cloud format)

**Confluence URL format:**
```
CONFLUENCE_BASE_PATH=https://yourcompany.atlassian.net/wiki
```
- ✅ Correct: `https://acme.atlassian.net/wiki`
- ❌ Wrong: `https://acme.atlassian.net/wiki/` (no trailing slash)

### Step 5: Save the File

1. In notepad, go to **File > Save**
2. Ensure the file is saved as `dmtools.env` (not `dmtools.env.txt`)
3. Close notepad

### Step 6: Verify File Contents

Check that the file was saved correctly:

```powershell
# View the file (without showing sensitive data in history)
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | Select-String "JIRA_BASE_PATH"
```

**Expected output:**
```
JIRA_BASE_PATH=https://yourcompany.atlassian.net
```

### Step 7: Set File Permissions (Security)

Restrict file access to your user only:

```powershell
# Remove inheritance and set permissions
$acl = Get-Acl "c:\Users\AndreyPopov\dmtools\dmtools.env"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERNAME", "Read,Write", "Allow")
$acl.SetAccessRule($rule)
Set-Acl "c:\Users\AndreyPopov\dmtools\dmtools.env" $acl
```

---

## Verification

Test that dmtools can read the configuration:

### Test 1: Verify Jira Connection

```powershell
# This will attempt to get information about yourself from Jira
dmtools jira_get_current_user
```

**Expected output:**
```json
{
  "accountId": "712020:...",
  "displayName": "Your Name",
  "emailAddress": "your.email@company.com",
  "active": true
}
```

**If you get an error:**
- Check JIRA_BASE_PATH is correct
- Verify JIRA_EMAIL matches your Atlassian account
- Confirm JIRA_API_TOKEN is valid
- Ensure JIRA_AUTH_TYPE is set to `basic`

### Test 2: Verify Confluence Connection

```powershell
# List Confluence spaces you have access to
dmtools confluence_list_spaces
```

**Expected output:**
```json
{
  "results": [
    {
      "key": "SPACE1",
      "name": "Space Name",
      ...
    }
  ]
}
```

### Test 3: Verify Gemini API

```powershell
# Simple AI chat test
dmtools gemini_ai_chat "Hello, please respond with 'Configuration successful!'"
```

**Expected output:**
```
Configuration successful!
```

---

## Common Configuration Issues

### Issue: "Authentication failed" with Jira

**Possible causes:**
1. Incorrect JIRA_BASE_PATH
2. Wrong JIRA_EMAIL
3. Invalid or expired JIRA_API_TOKEN
4. Incorrect JIRA_AUTH_TYPE

**Solution:**
```powershell
# Test authentication manually with curl
curl -u "your.email@company.com:ATATT3xFfGF0T..." `
  "https://yourcompany.atlassian.net/rest/api/3/myself"
```

If this works but dmtools doesn't, check your dmtools.env file for:
- Extra spaces around `=` signs
- Missing quotes (none should be needed)
- Incorrect variable names (check spelling)

### Issue: "API_KEY_INVALID" with Gemini

**Possible causes:**
1. Wrong API key format
2. Extra spaces when copying
3. API key not enabled
4. Billing not set up (for paid features)

**Solution:**
1. Re-copy the API key from Google AI Studio
2. Ensure it starts with `AIza`
3. Check Google Cloud Console for API status

### Issue: dmtools not reading .env file

**Possible causes:**
1. File in wrong location
2. File has wrong name (e.g., `dmtools.env.txt`)
3. Environment variables not loaded

**Solution:**
```powershell
# Verify file exists and has correct name
Test-Path "c:\Users\AndreyPopov\dmtools\dmtools.env"

# Check file extension
Get-ChildItem "c:\Users\AndreyPopov\dmtools\dmtools.env" | Select-Object Name, Extension
```

The extension should be empty (not `.txt`).

### Issue: "Cannot find JIRA_BASE_PATH"

dmtools might not be loading the `.env` file. Try setting environment variables manually for testing:

```powershell
# Load environment variables from .env file
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

# Now try dmtools command
dmtools jira_get_current_user
```

---

## Example: Complete Configuration for Learning

Here's a complete example (with fake credentials - replace with your real ones):

```properties
# Jira Configuration
JIRA_BASE_PATH=https://acmelearning.atlassian.net
JIRA_EMAIL=john.doe@acme.com
JIRA_API_TOKEN=ATATT3xFfGF0TjqL8r9K3FmN2vX5bY8pQ1wZ6cH4gT7dL9mR3sV5xJ2nK8fB4yG7t
JIRA_AUTH_TYPE=basic

# Confluence Configuration
CONFLUENCE_BASE_PATH=https://acmelearning.atlassian.net/wiki
CONFLUENCE_EMAIL=john.doe@acme.com
CONFLUENCE_API_TOKEN=ATATT3xFfGF0TjqL8r9K3FmN2vX5bY8pQ1wZ6cH4gT7dL9mR3sV5xJ2nK8fB4yG7t
CONFLUENCE_AUTH_TYPE=basic
CONFLUENCE_GRAPHQL_PATH=https://acmelearning.atlassian.net/gateway/api/graphql

# Gemini Configuration
GEMINI_API_KEY=AIzaSyD-9tSrKe4PWxQeHjT8NfL2VmYzK3FcGpA
GEMINI_DEFAULT_MODEL=gemini-2.0-flash-exp

# GitHub Configuration
GITHUB_TOKEN=ghp_16C7e42F292c6912E7f1FaD0b013CeF4A5D6789B
```

---

## Next Steps

Once your `dmtools.env` file is configured and verified:

1. ✅ **File created:** `c:\Users\AndreyPopov\dmtools\dmtools.env`
2. ✅ **Credentials filled in** from Step 1
3. ✅ **File permissions secured**
4. ✅ **Connections tested** (Jira, Confluence, Gemini)

**→ Proceed to:** [03-mcp-connection-test.md](03-mcp-connection-test.md)

Test the complete MCP integration with Cursor and verify all 67 tools are accessible.

---

## Reference: All Required Variables

For quick reference, these are the **minimum required** variables for the learning project:

```properties
JIRA_BASE_PATH=...
JIRA_EMAIL=...
JIRA_API_TOKEN=...
JIRA_AUTH_TYPE=basic

CONFLUENCE_BASE_PATH=...
CONFLUENCE_EMAIL=...
CONFLUENCE_API_TOKEN=...
CONFLUENCE_AUTH_TYPE=basic

GEMINI_API_KEY=...
GEMINI_DEFAULT_MODEL=gemini-2.0-flash-exp

GITHUB_TOKEN=...
```

Everything else is optional or has sensible defaults.

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [02-dmtools-installation.md](02-dmtools-installation.md)  
**Next Step:** [03-mcp-connection-test.md](03-mcp-connection-test.md)

