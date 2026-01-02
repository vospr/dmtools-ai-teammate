# Manual CLI Commands Testing Guide

This document provides manual commands to test dmtools CLI without requiring API credentials.

## Prerequisites

- dmtools JAR installed at: `C:\Users\AndreyPopov\.dmtools\dmtools.jar`
- Java 21+ installed and in PATH
- **No API credentials required** for these tests

---

## Test 1: Version Check

**Command:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --version
```

**Expected Output:**
```
DMTools 1.7.102
A comprehensive development management toolkit
```

**Alternative (if using wrapper):**
```powershell
# Note: --version may not work with wrapper, use direct JAR instead
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --version
```

**What to verify:**
- ✅ Version number is displayed
- ✅ No errors occur
- ✅ Command completes quickly (< 5 seconds)

---

## Test 2: List All Available Tools

**Command:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list
```

**Expected Output:**
- JSON object starting with `{"tools": [...]}`
- List of 90+ tools with names, descriptions, and parameters
- May include GraalVM warnings (safe to ignore)

**Save output to file:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list > tools-list.json 2>&1
```

**Count tools:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$jsonStart = $output.IndexOf('{')
if ($jsonStart -ge 0) {
    $json = $output.Substring($jsonStart) | ConvertFrom-Json
    Write-Host "Total tools: $($json.tools.Count)"
}
```

**What to verify:**
- ✅ JSON output is valid
- ✅ Tools array contains multiple tools
- ✅ Each tool has `name`, `description`, and `inputSchema`

---

## Test 3: Help for Specific Tool

**Test tool without parameters (should show error):**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp gemini_ai_chat
```

**Expected:** Error message indicating missing required parameters

**Test with invalid parameters:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_ticket
```

**Expected:** Error message about missing required parameters (e.g., "key" parameter)

**What to verify:**
- ✅ Tool responds (even if with error)
- ✅ Error message is clear and helpful
- ✅ No crashes or unhandled exceptions

---

## Test 4: Search for Specific Tools

**Find all Jira tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "jira_" | Select-Object -First 10
```

**Find all Confluence tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "confluence_" | Select-Object -First 10
```

**Find all Gemini AI tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "gemini_" | Select-Object -First 10
```

**Find all Figma tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "figma_" | Select-Object -First 10
```

**What to verify:**
- ✅ Tools are found by category
- ✅ Tool names follow consistent naming patterns

---

## Test 5: Tool Schema Inspection

**Get detailed schema for a specific tool:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$jsonStart = $output.IndexOf('{')
if ($jsonStart -ge 0) {
    $json = $output.Substring($jsonStart) | ConvertFrom-Json
    $tool = $json.tools | Where-Object { $_.name -eq "gemini_ai_chat" }
    $tool | ConvertTo-Json -Depth 10
}
```

**Check required parameters:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$jsonStart = $output.IndexOf('{')
if ($jsonStart -ge 0) {
    $json = $output.Substring($jsonStart) | ConvertFrom-Json
    $tool = $json.tools | Where-Object { $_.name -eq "jira_get_ticket" }
    Write-Host "Required parameters:"
    $tool.inputSchema.required
    Write-Host "`nAll parameters:"
    $tool.inputSchema.properties | Get-Member -MemberType NoteProperty | Select-Object Name
}
```

**What to verify:**
- ✅ Tool schema is well-structured
- ✅ Required parameters are clearly marked
- ✅ Parameter types and descriptions are present

---

## Test 6: Error Handling

**Test with invalid tool name:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp invalid_tool_name_xyz
```

**Expected:** Error message like "Unknown tool: invalid_tool_name_xyz"

**Test with malformed command:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" invalid_command
```

**Expected:** Error message or help text

**What to verify:**
- ✅ Errors are handled gracefully
- ✅ Error messages are clear and helpful
- ✅ No stack traces or crashes

---

## Test 7: Performance Test

**Time the list command:**
```powershell
Measure-Command {
    java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list | Out-Null
}
```

**Expected:** Should complete in 5-15 seconds (first run may be slower due to JVM startup)

**Time the version command:**
```powershell
Measure-Command {
    java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --version | Out-Null
}
```

**Expected:** Should complete in 2-5 seconds

**What to verify:**
- ✅ Commands complete in reasonable time
- ✅ No excessive delays or hangs

---

## Test 8: Output Format Validation

**Check JSON validity:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$jsonStart = $output.IndexOf('{')
if ($jsonStart -ge 0) {
    $json = $output.Substring($jsonStart)
    try {
        $parsed = $json | ConvertFrom-Json
        Write-Host "✅ Valid JSON" -ForegroundColor Green
        Write-Host "Tools count: $($parsed.tools.Count)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

**What to verify:**
- ✅ Output is valid JSON
- ✅ JSON structure matches MCP protocol specification
- ✅ All required fields are present

---

## Quick Test Script

**Run automated test:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
powershell -ExecutionPolicy Bypass -File test-basic-cli-commands.ps1
```

---

## Expected Results Summary

| Test | Expected Result | Status |
|------|----------------|--------|
| Version Check | Shows version number | ✅ Should work |
| List Tools | Returns JSON with 90+ tools | ✅ Should work |
| Tool Help | Shows error for missing params | ✅ Should work |
| Tool Search | Finds tools by category | ✅ Should work |
| Schema Inspection | Shows tool parameters | ✅ Should work |
| Error Handling | Graceful error messages | ✅ Should work |
| Performance | Completes in < 15 seconds | ✅ Should work |
| JSON Format | Valid JSON output | ✅ Should work |

---

## Troubleshooting

### Issue: "Unknown tool" when using wrapper
- **Solution:** The wrapper adds `mcp` prefix. Use direct JAR execution for `--version`:
  ```powershell
  java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --version
  ```

### Issue: GraalVM warnings in output
- **Solution:** These are informational and safe to ignore. They don't affect functionality.

### Issue: Slow first run
- **Solution:** Normal - JVM startup takes time. Subsequent runs are faster.

### Issue: No JSON output
- **Solution:** Add `2>&1` to capture stderr:
  ```powershell
  java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1
  ```

### Issue: JSON parsing fails
- **Solution:** Extract JSON from output (skip warnings):
  ```powershell
  $output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
  $jsonStart = $output.IndexOf('{')
  $json = $output.Substring($jsonStart) | ConvertFrom-Json
  ```

---

## Next Steps

After verifying basic CLI commands work:

1. ✅ **Proceed to Step 5:** Test commands with API credentials
2. ✅ **Configure credentials:** Ensure `dmtools.env` is set up
3. ✅ **Test API connections:** Use tools that require authentication

---

**Last Updated:** December 30, 2025
