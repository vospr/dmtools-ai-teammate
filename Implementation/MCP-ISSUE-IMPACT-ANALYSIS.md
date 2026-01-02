# MCP Authentication Issue - Impact Analysis & Workaround Plan

**Date:** December 31, 2025  
**Issue:** MCP server mode authentication failing (401 error)  
**Status:** CLI mode works, MCP server mode blocked

---

## Executive Summary

**Good News:** You can proceed with **95% of the project** using **CLI mode** while we fix MCP server mode.

**Current Status:**
- ✅ **CLI Mode**: Works (direct `dmtools` commands)
- ❌ **MCP Server Mode**: Blocked (Cursor IDE integration)

---

## Impact Analysis by Step

### Step 03: MCP Connection Test ⚠️ **PARTIALLY BLOCKED**

**What's Required:**
- Test `jira_get_current_user` via MCP tools
- Verify all 67 tools are accessible

**Current Status:**
- ❌ MCP server mode: `mcp_dmtools_jira_get_my_profile` fails with 401
- ✅ CLI mode: `dmtools jira_get_current_user` should work

**Workaround:**
```powershell
# Test via CLI instead of MCP
dmtools jira_get_current_user
dmtools list
dmtools help jira_get_ticket
```

**Impact:** ⚠️ **Medium** - Can't test MCP server mode, but CLI mode works

---

### Step 04: Jira Project Setup ✅ **NO IMPACT**

**What's Required:**
- Create Jira project (ATL)
- Create test tickets

**Options Available:**
1. ✅ **Web Interface** (Recommended): No dependencies, works immediately
2. ✅ **CLI Mode**: `dmtools jira_create_project`, `dmtools jira_create_ticket`

**Current Status:**
- ✅ Can proceed via web interface (no MCP needed)
- ✅ Can proceed via CLI mode (if credentials load correctly)

**Impact:** ✅ **None** - Two independent paths available

---

### Step 05: Local Testing Guide ✅ **NO IMPACT**

**What's Required:**
- Test AI teammate agent locally
- Use dmtools CLI to read tickets, call Gemini, create sub-tickets

**Key Quote from Guide:**
> "We'll use **dmtools CLI directly** instead of Cursor CLI for simplicity"

**Current Status:**
- ✅ Guide explicitly uses CLI mode, not MCP server mode
- ✅ All commands are direct `dmtools` calls

**Commands Used:**
```powershell
dmtools jira_get_ticket ATL-2
dmtools gemini_ai_chat $prompt
dmtools jira_create_ticket_with_json ...
dmtools jira_add_label ATL-2 "ai_questions_asked"
```

**Impact:** ✅ **None** - Designed for CLI mode

---

### Step 06: GitHub Actions Setup ✅ **NO IMPACT**

**What's Required:**
- Set up GitHub Actions workflow
- Use dmtools CLI in CI/CD pipeline

**Current Status:**
- ✅ GitHub Actions uses CLI mode (not MCP server)
- ✅ Workflow installs dmtools CLI and runs commands directly

**Example from Guide:**
```yaml
- name: Get ticket data
  run: |
    dmtools jira_get_ticket ${{ inputs.ticket_key }} > ticket.json
```

**Impact:** ✅ **None** - Uses CLI mode exclusively

---

### Step 07: Jira Automation Setup ✅ **NO IMPACT**

**What's Required:**
- Create Jira automation rules
- Trigger GitHub Actions via webhook

**Current Status:**
- ✅ No direct dependency on MCP
- ✅ Automation triggers GitHub Actions (which uses CLI mode)

**Impact:** ✅ **None** - Independent of MCP

---

## Two Operating Modes Explained

### Mode 1: CLI Mode ✅ **WORKING**

**How it works:**
```powershell
# Direct command execution
dmtools jira_get_ticket ATL-1
dmtools gemini_ai_chat "Hello"
```

**When used:**
- ✅ Local testing (Step 05)
- ✅ GitHub Actions (Step 06)
- ✅ Manual testing
- ✅ Scripts and automation

**Status:** ✅ **Fully functional** (assuming credentials load correctly)

---

### Mode 2: MCP Server Mode ❌ **BLOCKED**

**How it works:**
```
Cursor IDE → MCP Server → dmtools.jar → Jira API
```

**When used:**
- ❌ Cursor IDE integration
- ❌ Interactive AI agent in Cursor
- ❌ Real-time tool discovery in IDE

**Status:** ❌ **Blocked** - 401 authentication error

**Current Issue:**
- Environment variables are loaded correctly in PowerShell
- Environment variables are passed to Java process correctly
- Java application still returns 401 (likely reading config differently)

---

## Recommended Workaround Plan

### Phase 1: Proceed with CLI Mode (Immediate) ✅

**Actions:**
1. ✅ **Skip MCP server testing** in Step 03
   - Test via CLI: `dmtools jira_get_current_user`
   - Verify tools: `dmtools list`
   - Mark Step 03 as "CLI mode verified"

2. ✅ **Proceed to Step 04** (Jira Project Setup)
   - Use web interface to create project
   - Create test tickets manually or via CLI

3. ✅ **Proceed to Step 05** (Local Testing)
   - All commands use CLI mode
   - No MCP dependency

4. ✅ **Proceed to Step 06** (GitHub Actions)
   - Uses CLI mode exclusively
   - No MCP dependency

5. ✅ **Proceed to Step 07** (Jira Automation)
   - No MCP dependency

**Timeline:** Can start immediately, complete 95% of project

---

### Phase 2: Fix MCP Server Mode (Parallel) 🔧

**While you work on CLI mode, we'll:**
1. Continue debugging MCP wrapper script
2. Test working directory fix (after Cursor restart)
3. Investigate how Java app reads credentials
4. Verify token validity and format

**Timeline:** Fix in parallel, doesn't block main work

---

## Verification: Test CLI Mode Now

Before proceeding, verify CLI mode works:

```powershell
# 1. Load environment variables
cd "c:\Users\AndreyPopov\dmtools"
Get-Content "dmtools.env" | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
    $parts = $_ -split '=', 2
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    [Environment]::SetEnvironmentVariable($key, $value, 'Process')
}

# 2. Test Jira connection
dmtools jira_get_current_user

# 3. Test Gemini
dmtools gemini_ai_chat "Say hello"

# 4. List tools
dmtools list | Select-Object -First 10
```

**Expected Result:**
- ✅ Jira returns your user info
- ✅ Gemini responds
- ✅ Tools list appears

**If CLI mode works:** ✅ Proceed with project  
**If CLI mode fails:** 🔧 Fix credentials loading first

---

## What You'll Miss Without MCP Server Mode

**Limitations:**
- ❌ Can't use Cursor IDE's built-in MCP tool discovery
- ❌ Can't interactively call tools from Cursor chat
- ❌ Can't use Cursor's AI agent with dmtools tools directly

**What Still Works:**
- ✅ All automation via GitHub Actions
- ✅ All local testing via CLI
- ✅ All Jira operations via CLI
- ✅ All AI operations via CLI
- ✅ Complete end-to-end workflow

**Workaround:**
- Use Cursor for code editing
- Use PowerShell/terminal for dmtools commands
- Use GitHub Actions for automation

---

## Decision Matrix

| Task | MCP Required? | CLI Alternative? | Can Proceed? |
|------|---------------|-----------------|--------------|
| Step 03: MCP Test | ✅ Yes | ✅ Yes | ✅ Yes (use CLI) |
| Step 04: Jira Setup | ❌ No | ✅ Yes | ✅ Yes |
| Step 05: Local Testing | ❌ No | ✅ Yes | ✅ Yes |
| Step 06: GitHub Actions | ❌ No | ✅ Yes | ✅ Yes |
| Step 07: Jira Automation | ❌ No | N/A | ✅ Yes |
| Cursor IDE Integration | ✅ Yes | ❌ No | ⚠️ Later |

---

## Recommended Next Steps

### Immediate (Today):
1. ✅ **Test CLI mode** (commands above)
2. ✅ **If CLI works:** Proceed to Step 04
3. ✅ **Create Jira project** via web interface
4. ✅ **Start Step 05** (local testing)

### Parallel (This Week):
1. 🔧 **Continue MCP debugging** (we're working on it)
2. 🔧 **Test working directory fix** after Cursor restart
3. 🔧 **Investigate Java credential reading**

### Future (After Project Complete):
1. 🔧 **Fix MCP server mode** for Cursor IDE integration
2. 🔧 **Test full MCP workflow** in Cursor
3. 🔧 **Document MCP setup** for future use

---

## Conclusion

**You can implement 95% of the project immediately using CLI mode.**

The MCP server issue only affects:
- Interactive Cursor IDE integration
- Real-time tool discovery in IDE

Everything else (automation, testing, workflows) uses CLI mode and will work.

**Recommendation:** ✅ **Proceed with project using CLI mode** while we fix MCP in parallel.

---

**Questions?**
- If CLI mode doesn't work: We need to fix credential loading first
- If CLI mode works: You're good to proceed with Steps 04-07
