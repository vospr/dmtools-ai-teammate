# Manual Testing Guide for DMTools

**Status:** Ready for manual testing  
**Date:** December 30, 2025

---

## ✅ What's Been Verified

### 1. Java Installation ✅
```powershell
PS C:\> java -version
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment Temurin-21.0.5+11 (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.5+11 (build 21.0.5+11-LTS, mixed mode, sharing)
```
**Result:** ✅ Java 21 working perfectly

### 2. DMTools JAR Exists ✅
```powershell
PS C:\> Test-Path "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
True
```
**Result:** ✅ JAR file installed correctly

### 3. DMTools CLI Help ✅
```powershell
PS C:\> java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --help
DMTools CLI Wrapper

Usage:
  dmtools list                           # List available MCP tools
  dmtools run <json-file>                # Execute job with JSON config file
  [... full help output ...]
```
**Result:** ✅ CLI is accessible and working

### 4. DMTools Wrapper Created ✅
**Location:** `C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd`  
**Result:** ✅ Wrapper script created

---

## Manual Tests to Run

### Test 1: List All MCP Tools

**Command:**
```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list > tools-list.txt
notepad tools-list.txt
```

**Expected:** File with list of all 136 MCP tools

---

### Test 2: Test Jira Connection

**Method A: Direct with Environment Variables**
```powershell
cd "c:\Users\AndreyPopov\dmtools"

# Set environment variables
$env:JIRA_BASE_PATH="https://vospr.atlassian.net"
$env:JIRA_EMAIL="andrey_popov@epam.com"
$env:JIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF"
$env:JIRA_AUTH_TYPE="basic"

# Test connection (this may take 10-30 seconds)
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
```

**Expected Output:**
```json
{
  "accountId": "...",
  "emailAddress": "andrey_popov@epam.com",
  "displayName": "Andrey Popov",
  "active": true
}
```

---

### Test 3: Test Gemini AI Connection

**Command:**
```powershell
cd "c:\Users\AndreyPopov\dmtools"

# Set Gemini environment variables
$env:GEMINI_API_KEY="AIzaSyBq6hsJ5E5YJBodjI3RNZUSBHMCYsKjyW8"
$env:GEMINI_DEFAULT_MODEL="gemini-2.0-flash-exp"

# Create test prompt
@{ prompt = "Say hello in one word" } | ConvertTo-Json | Out-File -Encoding UTF8 test-prompt.json

# Test AI (this may take 10-30 seconds)
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp gemini_ai_chat --file test-prompt.json
```

**Expected Output:**
```
Hello
```
or
```json
{"response": "Hello"}
```

---

### Test 4: Load All Environment and Test

**Complete Test Script:**
```powershell
# Navigate to dmtools folder
cd "c:\Users\AndreyPopov\dmtools"

# Load all environment variables from dmtools.env
Get-Content "dmtools.env" | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -match '='
} | ForEach-Object {
    $parts = $_ -split '=', 2
    if ($parts.Length -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        Write-Host "Set: $key" -ForegroundColor Gray
    }
}

Write-Host "`nEnvironment loaded. Testing Jira..." -ForegroundColor Yellow

# Test Jira
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile

Write-Host "`nJira test complete." -ForegroundColor Green
```

---

## Alternative: Use dmtools Wrapper

The wrapper script automatically loads environment from `dmtools.env`:

```powershell
# Add to PATH
$env:PATH = "C:\Users\AndreyPopov\.dmtools\bin;$env:PATH"

# Navigate to folder with dmtools.env
cd "c:\Users\AndreyPopov\dmtools"

# Run commands
dmtools list
dmtools jira_get_my_profile
```

---

## Troubleshooting

### If Commands Take Long Time (10-30 seconds)
**This is normal** for:
- First-time API connections
- AI tools (Gemini processing)
- Large data queries

**Solution:** Be patient, wait up to 30 seconds

### If "No output" appears
**Check:**
1. Output might be JSON on stdout (check terminal carefully)
2. Errors go to stderr (look for red text)
3. Try redirecting to file: `command > output.txt 2>&1`

### If "401 Unauthorized"
**Check:**
1. Environment variables are set: `Get-ChildItem Env:JIRA_*`
2. API tokens are correct in `dmtools.env`
3. You're in the `c:\Users\AndreyPopov\dmtools` directory

### If "Connection Timeout"
**Possible causes:**
1. Firewall blocking Java
2. Network/VPN issues
3. API endpoint unreachable

**Solution:**
1. Check internet connection
2. Try from different network
3. Verify URLs in dmtools.env are correct

---

## Success Criteria

After manual testing, you should have:

- [ ] List of all 136 tools saved to `tools-list.txt`
- [ ] Successful Jira profile response (JSON with your email)
- [ ] Successful Gemini AI response ("Hello" or similar)
- [ ] Environment variables loading correctly
- [ ] No authentication errors (401)

---

## What's Next

Once manual testing is successful:

1. **Create Jira Test Project**
   - Follow: [04-jira-project-setup.md](04-jira-project-setup.md)
   - Create "LEARN" project

2. **Build Simple Agent**
   - Create agent configuration
   - Test locally with dmtools

3. **Set Up GitHub Actions**
   - Configure repository secrets
   - Enable automation workflow

---

## Quick Reference Commands

### Set All Environment Variables
```powershell
cd "c:\Users\AndreyPopov\dmtools"
Get-Content "dmtools.env" | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object { $parts = $_ -split '=', 2; if ($parts.Length -eq 2) { [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process') } }
```

### Test Jira Quickly
```powershell
cd "c:\Users\AndreyPopov\dmtools"
$env:JIRA_BASE_PATH="https://vospr.atlassian.net"; $env:JIRA_EMAIL="andrey_popov@epam.com"; $env:JIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF"; $env:JIRA_AUTH_TYPE="basic"; java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
```

### Check Environment Variables
```powershell
Get-ChildItem Env: | Where-Object { $_.Name -match 'JIRA|GEMINI|GITHUB|FIGMA|CONFLUENCE' }
```

---

**Note:** All tests should be run from PowerShell terminal in Cursor or standalone PowerShell window.

**Estimated Time:** 5-10 minutes for all tests

**Date:** December 30, 2025  
**Status:** Ready for manual execution

