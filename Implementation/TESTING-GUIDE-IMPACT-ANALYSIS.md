# Testing Guide Impact Analysis

**Date:** December 31, 2025  
**Document:** `05-local-testing-guide.md`  
**Current Architecture:** Direct PowerShell API calls (workaround for `dmtools.jar` authentication issues)

---

## Executive Summary

**Critical Impact:** ⚠️ **HIGH** - Multiple steps require modification

The testing guide assumes `dmtools` CLI commands work correctly, but your current architecture uses **direct PowerShell API calls** due to authentication issues with `dmtools.jar`. **Most steps that use `dmtools` commands will need to be replaced** with direct API calls.

---

## Affected Steps & Scenarios

### 🔴 **CRITICAL - Requires Complete Replacement**

#### **Step 2: Get Ticket Data from Jira**
**Current Guide:**
```powershell
$ticketData = dmtools jira_get_ticket $ticketKey
```

**Impact:** ❌ **WILL FAIL** - `dmtools` CLI has 401 authentication errors

**Required Change:** Replace with direct PowerShell API call:
```powershell
# Load credentials and get ticket
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

$ticketData = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/${ticketKey}" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json" }
```

---

#### **Step 4: Manually Build Complete Prompt**
**Current Guide:**
```powershell
$ticket = dmtools jira_get_ticket ATL-2 | ConvertFrom-Json
```

**Impact:** ❌ **WILL FAIL** - Same as Step 2

**Required Change:** Use direct API call (same as Step 2)

---

#### **Step 5: Call Gemini AI to Generate Questions**
**Current Guide:**
```powershell
$response = dmtools gemini_ai_chat $prompt
```

**Impact:** ❌ **WILL FAIL** - `dmtools` CLI has authentication issues

**Required Change:** Replace with direct PowerShell API call:
```powershell
# Load Gemini credentials
cd "c:\Users\AndreyPopov\dmtools"
$apiKey = (Get-Content "dmtools.env" | Select-String "^GEMINI_API_KEY=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^GEMINI_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
if ([string]::IsNullOrEmpty($basePath)) { $basePath = "https://generativelanguage.googleapis.com/v1beta" }

$model = "gemini-2.0-flash-exp"
$uri = "${basePath}/${model}:generateContent?key=${apiKey}"

$body = @{
    contents = @(
        @{
            parts = @(
                @{ text = $prompt }
            )
        }
    )
} | ConvertTo-Json -Depth 5

$responseObj = Invoke-RestMethod -Method POST -Uri $uri `
    -Headers @{ "Content-Type" = "application/json" } `
    -Body $body

$response = $responseObj.candidates[0].content.parts[0].text
```

---

#### **Step 8: Create Sub-tickets via dmtools**
**Current Guide:**
```powershell
$result = dmtools jira_create_ticket_with_json @"
{
  "project": "$projectKey",
  "fieldsJson": $fieldsJson
}
"@
```

**Impact:** ❌ **WILL FAIL** - `dmtools` CLI has authentication issues

**Required Change:** Replace with direct PowerShell API call:
```powershell
# Create sub-task ticket
$ticketBody = @{
    fields = @{
        project = @{ key = $projectKey }
        summary = $summary
        description = @{ type = "doc"; version = 1; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = $description }) }) }
        issuetype = @{ id = "10011" }  # Sub-task ID from your project
        parent = @{ key = $parentKey }
        priority = @{ name = $question.priority }
    }
} | ConvertTo-Json -Depth 10

$result = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/issue" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json"; "Content-Type" = "application/json" } `
    -Body $ticketBody

$createdKey = $result.key
```

**Note:** Issue type ID `10011` is "Sub-task" in your project (verified earlier)

---

#### **Step 9: Add Label and Assign Ticket**
**Current Guide:**
```powershell
dmtools jira_add_label ATL-2 "ai_questions_asked"
$currentUser = dmtools jira_get_current_user | ConvertFrom-Json
dmtools jira_assign_ticket @"
{
  "key": "ATL-2",
  "accountId": "$yourAccountId"
}
"@
```

**Impact:** ❌ **WILL FAIL** - All three `dmtools` commands will fail

**Required Change:** Replace with direct API calls:
```powershell
# Add label
$ticket = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/ATL-2?fields=labels" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json" }
$currentLabels = if ($ticket.fields.labels) { $ticket.fields.labels } else { @() }
$newLabels = $currentLabels + "ai_questions_asked"
$updateBody = @{ fields = @{ labels = $newLabels } } | ConvertTo-Json
Invoke-RestMethod -Method PUT -Uri "${basePath}/rest/api/3/issue/ATL-2" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json"; "Content-Type" = "application/json" } `
    -Body $updateBody | Out-Null

# Get current user
$currentUser = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/myself" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json" }
$yourAccountId = $currentUser.accountId

# Assign ticket
$assignBody = @{ accountId = $yourAccountId } | ConvertTo-Json
Invoke-RestMethod -Method PUT -Uri "${basePath}/rest/api/3/issue/ATL-2/assignee" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json"; "Content-Type" = "application/json" } `
    -Body $assignBody | Out-Null
```

---

#### **Complete Test Script (Step 10)**
**Impact:** ❌ **WILL FAIL** - Script uses multiple `dmtools` commands throughout

**Required Change:** Replace all `dmtools` commands with direct API calls (see above patterns)

---

### 🟡 **MODERATE - May Need Adjustment**

#### **Issue Type Configuration**
**Current Guide Assumes:**
- "Story" issue type exists
- "Sub-task" issue type exists

**Your Configuration:**
- ✅ "Sub-task" exists (ID: 10011)
- ❌ "Story" does NOT exist (only "Task" ID: 10010 and "Sub-task" ID: 10011)

**Impact:** ⚠️ **MINOR** - Sub-tasks can still be created, but parent tickets are "Task" not "Story"

**Required Change:** None - Sub-tasks work with "Task" as parent. Just note that your tickets are "Task" type, not "Story".

---

#### **Priority Names**
**Current Guide Uses:**
- "Highest", "High", "Medium", "Low", "Lowest"

**Your Configuration:**
- ✅ Standard Jira priorities (should match)

**Impact:** ⚠️ **MINOR** - Verify priority names match your Jira instance

**Required Change:** Verify priority names in your Jira:
```powershell
# Get available priorities (if API supports it)
# Or check via Jira UI: Settings → Issues → Priorities
```

---

### 🟢 **NO IMPACT - Works As-Is**

#### **Step 1: Prepare Test Directory Structure**
**Impact:** ✅ **NO CHANGE NEEDED** - Pure PowerShell file operations

#### **Step 3: Create Instructions File**
**Impact:** ✅ **NO CHANGE NEEDED** - File creation only

#### **Step 6: Validate AI Response**
**Impact:** ✅ **NO CHANGE NEEDED** - JSON parsing only

#### **Step 7: Test JavaScript Action (Dry Run)**
**Impact:** ✅ **NO CHANGE NEEDED** - Display/logic only

#### **Step 10: Verify in Jira Web Interface**
**Impact:** ✅ **NO CHANGE NEEDED** - Manual verification

---

## Summary Table

| Step | Command Used | Impact Level | Status | Action Required |
|------|--------------|--------------|--------|-----------------|
| **Step 1** | File operations | 🟢 None | ✅ OK | None |
| **Step 2** | `dmtools jira_get_ticket` | 🔴 Critical | ❌ Fail | Replace with direct API |
| **Step 3** | File creation | 🟢 None | ✅ OK | None |
| **Step 4** | `dmtools jira_get_ticket` | 🔴 Critical | ❌ Fail | Replace with direct API |
| **Step 5** | `dmtools gemini_ai_chat` | 🔴 Critical | ❌ Fail | Replace with direct API |
| **Step 6** | JSON parsing | 🟢 None | ✅ OK | None |
| **Step 7** | Display logic | 🟢 None | ✅ OK | None |
| **Step 8** | `dmtools jira_create_ticket_with_json` | 🔴 Critical | ❌ Fail | Replace with direct API |
| **Step 9** | `dmtools jira_add_label`<br>`dmtools jira_get_current_user`<br>`dmtools jira_assign_ticket` | 🔴 Critical | ❌ Fail | Replace with direct API |
| **Step 10** | Multiple `dmtools` commands | 🔴 Critical | ❌ Fail | Replace all with direct API |
| **Issue Types** | "Story" vs "Task" | 🟡 Moderate | ⚠️ Note | Document difference |

---

## Recommended Modifications

### 1. Create Helper Functions

Create a PowerShell module with helper functions to avoid code duplication:

```powershell
# Save as: test-run/jira-helpers.ps1

function Get-JiraTicket {
    param([string]$TicketKey)
    # Implementation using direct API calls
}

function Invoke-GeminiAI {
    param([string]$Prompt)
    # Implementation using direct API calls
}

function New-JiraSubTask {
    param([string]$ParentKey, [string]$Summary, [string]$Description, [string]$Priority)
    # Implementation using direct API calls
}

function Add-JiraLabel {
    param([string]$TicketKey, [string]$Label)
    # Implementation using direct API calls
}

function Set-JiraAssignee {
    param([string]$TicketKey, [string]$AccountId)
    # Implementation using direct API calls
}
```

### 2. Update All Steps

Replace all `dmtools` commands with:
- Direct API calls, OR
- Helper functions (recommended)

### 3. Update Complete Test Script

Replace the entire script in Step 10 with a version that uses:
- Direct API calls or helper functions
- Proper error handling
- Credential loading from `dmtools.env`

---

## Testing Scenarios Affected

### ✅ **Scenario 1: Basic Question Generation**
- **Impact:** 🔴 **HIGH** - Steps 2, 4, 5 need modification
- **Workaround:** Use direct API calls for Jira and Gemini

### ✅ **Scenario 2: Sub-ticket Creation**
- **Impact:** 🔴 **HIGH** - Step 8 needs modification
- **Workaround:** Use direct API calls for ticket creation
- **Note:** Sub-tasks work with "Task" parent (not "Story")

### ✅ **Scenario 3: Label and Assignment**
- **Impact:** 🔴 **HIGH** - Step 9 needs modification
- **Workaround:** Use direct API calls for label and assignment

### ✅ **Scenario 4: Complete End-to-End Test**
- **Impact:** 🔴 **HIGH** - Complete script needs rewrite
- **Workaround:** Rewrite using direct API calls throughout

---

## Key Configuration Differences

| Aspect | Guide Assumes | Your Configuration | Impact |
|--------|---------------|-------------------|--------|
| **Jira Access** | `dmtools` CLI works | Direct PowerShell API calls | 🔴 High |
| **Gemini Access** | `dmtools` CLI works | Direct PowerShell API calls | 🔴 High |
| **Issue Types** | "Story" exists | Only "Task" and "Sub-task" | 🟡 Moderate |
| **Sub-tasks** | Works with "Story" parent | Works with "Task" parent | ✅ OK |
| **Authentication** | `dmtools.jar` loads credentials | Manual credential loading in scripts | 🔴 High |

---

## Action Items

### Immediate (Required for Testing)

1. ✅ **Create helper functions** for Jira and Gemini API calls
2. ✅ **Update Step 2** - Replace `dmtools jira_get_ticket`
3. ✅ **Update Step 4** - Replace `dmtools jira_get_ticket`
4. ✅ **Update Step 5** - Replace `dmtools gemini_ai_chat`
5. ✅ **Update Step 8** - Replace `dmtools jira_create_ticket_with_json`
6. ✅ **Update Step 9** - Replace all three `dmtools` commands
7. ✅ **Rewrite Complete Test Script** - Replace all `dmtools` commands

### Documentation Updates

1. ✅ Add note about using direct API calls instead of `dmtools` CLI
2. ✅ Document that tickets are "Task" type, not "Story"
3. ✅ Add troubleshooting section for API call errors
4. ✅ Update prerequisites to mention API call workaround

---

## Conclusion

**Overall Impact:** ⚠️ **HIGH** - Most testing steps require modification

**Critical Path:**
1. Replace all `dmtools` CLI commands with direct PowerShell API calls
2. Create helper functions to reduce code duplication
3. Update complete test script
4. Test each step individually before running end-to-end

**Estimated Effort:** 
- Helper functions: 1-2 hours
- Step updates: 2-3 hours
- Testing and validation: 1-2 hours
- **Total: 4-7 hours**

**Recommendation:** Create a modified version of the testing guide that uses direct API calls throughout, or create helper functions that abstract the API calls to match the guide's command structure.

---

**Document Created:** December 31, 2025  
**Based On:** Current architecture using direct PowerShell API calls  
**Reference:** `03-mcp-connection-test.md` (working API call patterns)
