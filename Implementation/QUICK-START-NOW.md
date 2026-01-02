# 🚀 Quick Start: Test Your Installation NOW

**Time Required:** 5 minutes  
**Status:** Ready to execute

---

## Step 1: Open PowerShell in Cursor

1. In Cursor, press `` Ctrl + ` `` (backtick) to open terminal
2. Or use the Terminal menu → New Terminal

---

## Step 2: Run the Test Script

Copy and paste this command:

```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"; .\test-dmtools-complete.ps1
```

**What happens:**
- Loads your API credentials
- Tests CLI accessibility
- Lists all 136 MCP tools
- Tests Jira connection
- Tests Confluence connection
- Tests Gemini AI connection
- Generates report and saves tool list

---

## Step 3: Review Results

The script will show:
```
========================================
DMTOOLS COMPLETE VERIFICATION
========================================

[1/6] Loading environment variables...
   Environment loaded successfully ✅

[2/6] Testing CLI accessibility...
   CLI is accessible ✅

[3/6] Listing all MCP tools...
   Found 136 MCP tools ✅
   Full list saved to: mcp-tools-list.txt

[4/6] Testing API credentials...
   [4.1] Testing Jira connection...
      JIRA: Connected successfully ✅
      
   [4.2] Testing Confluence connection...
      CONFLUENCE: Connected successfully ✅
      
   [4.3] Testing Gemini AI connection...
      GEMINI AI: Connected successfully ✅

========================================
VERIFICATION SUMMARY
========================================
CLI:        Tested ✅
Tools:      Listed and saved ✅
Jira:       Tested ✅
Confluence: Tested ✅
Gemini AI:  Tested ✅
```

---

## Step 4: Check Generated Files

After the test completes, check these files:

```powershell
# View tool list (136 tools)
notepad "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\mcp-tools-list.txt"

# Or just list it
Get-Content "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\mcp-tools-list.txt"
```

---

## Step 5: Try Manual Commands

### Test Jira
```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" jira_get_my_profile
```

**Expected:** Your Jira profile with email and display name

### Test Gemini AI
```powershell
cd "c:\Users\AndreyPopov\dmtools"
@{ prompt = "Say hello in one word" } | ConvertTo-Json | Out-File test-prompt.json
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" gemini_ai_chat --file test-prompt.json
```

**Expected:** AI response with "Hello" or similar

### List All Tools
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" list
```

**Expected:** Long list of 136 tool names

---

## Troubleshooting

### If Script Fails to Run

**Error:** "Execution policy"
```powershell
# Run this first:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# Then try the test script again
```

**Error:** "File not found"
```powershell
# Check you're in the right directory:
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
# List files:
dir
# Should see: test-dmtools-complete.ps1
```

### If API Tests Fail

**Check credentials file exists:**
```powershell
Test-Path "c:\Users\AndreyPopov\dmtools\dmtools.env"
```

**Should return:** True

If False, credentials not configured properly.

---

## What's Next?

### After Successful Tests:

1. **Review Documentation**
   - Open [dmtools-tools-reference.md](dmtools-tools-reference.md)
   - Browse the 136 available tools
   - Check usage examples

2. **Create Jira Project**
   - Follow [04-jira-project-setup.md](04-jira-project-setup.md)
   - Create "LEARN" project
   - Create test tickets

3. **Build Simple Agent**
   - Create agent configuration
   - Test locally with DMTools
   - Set up GitHub Actions

---

## Summary

**Just run this:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-dmtools-complete.ps1
```

**Then review:**
- [INSTALLATION-COMPLETE.md](INSTALLATION-COMPLETE.md) - Full summary
- [dmtools-tools-reference.md](dmtools-tools-reference.md) - All 136 tools
- [04-jira-project-setup.md](04-jira-project-setup.md) - Next steps

---

**Ready? Run the test script now!** ✨

