# Manual MCP Server Testing Commands

This document provides manual commands to test dmtools MCP server capabilities in your terminal.

## Prerequisites

- dmtools JAR installed at: `C:\Users\AndreyPopov\.dmtools\dmtools.jar`
- Java 21+ installed and in PATH
- `dmtools.env` configured with credentials (optional for basic tests)

---

## Test 1: List All MCP Tools

**Command:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list
```

**Expected Output:**
- JSON object with `{"tools": [...]}` structure
- List of 136+ tools with names, descriptions, and parameters

**Save output to file:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list > mcp-tools-list.json 2>&1
```

**Count tools:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$json = $output | ConvertFrom-Json
Write-Host "Total tools: $($json.tools.Count)"
```

---

## Test 2: Check Specific Tools

**Check if a tool exists:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "jira_get_ticket"
```

**List all Jira tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "jira_"
```

**List all Confluence tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "confluence_"
```

**List all Gemini AI tools:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Select-String "gemini_"
```

---

## Test 3: Test Tool Execution (Without Credentials)

**Test tool with missing parameters (should show error):**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_ticket
```

**Expected:** Error message indicating missing required parameters

**Test tool with invalid parameters:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_ticket --data '{"key":"INVALID-123"}'
```

**Expected:** Error message (either authentication error or ticket not found)

---

## Test 4: Test Tool Execution (With Credentials)

**Prerequisites:** Ensure `dmtools.env` exists in `c:\Users\AndreyPopov\dmtools\`

**Test Jira connection:**
```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
```

**Expected:** JSON with your Jira profile (displayName, emailAddress, accountId)

**Test Confluence connection:**
```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp confluence_get_current_user_profile
```

**Expected:** JSON with your Confluence profile

---

## Test 5: Test Tool with JSON Input

**Using inline JSON:**
```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp gemini_ai_chat --data '{"prompt":"Say hello in one sentence"}'
```

**Using JSON file:**
```powershell
# Create test file
@{
    prompt = "What is 2+2?"
} | ConvertTo-Json | Out-File test-prompt.json -Encoding UTF8

# Run tool
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp gemini_ai_chat --file test-prompt.json
```

---

## Test 6: Verify Tool Schema

**Get tool schema (if supported):**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$json = $output | ConvertFrom-Json
$tool = $json.tools | Where-Object { $_.name -eq "jira_get_ticket" }
$tool | ConvertTo-Json -Depth 10
```

**Check required parameters:**
```powershell
$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1 | Out-String
$json = $output | ConvertFrom-Json
$tool = $json.tools | Where-Object { $_.name -eq "jira_get_ticket" }
$tool.inputSchema.required
```

---

## Test 7: Performance Test

**Time the list command:**
```powershell
Measure-Command {
    java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list | Out-Null
}
```

**Expected:** Should complete in 5-15 seconds

---

## Test 8: Error Handling

**Test with invalid tool name:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp invalid_tool_name
```

**Expected:** Error message indicating unknown tool

**Test with malformed JSON:**
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_ticket --data '{"invalid":json}'
```

**Expected:** JSON parsing error

---

## Quick Test Script

**Run all basic tests:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
powershell -ExecutionPolicy Bypass -File test-mcp-capabilities.ps1
```

---

## Troubleshooting

### Issue: "Unknown tool" error
- **Solution:** Ensure you're using `mcp list` or `mcp <tool_name>` format
- The wrapper script adds `mcp` prefix automatically

### Issue: Authentication errors
- **Solution:** Ensure `dmtools.env` exists in `c:\Users\AndreyPopov\dmtools\`
- Check that credentials are correct

### Issue: Slow response
- **Normal:** First run may take 10-20 seconds (JVM startup)
- Subsequent runs should be faster

### Issue: No output
- **Solution:** Add `2>&1` to capture both stdout and stderr:
  ```powershell
  java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1
  ```

---

## Expected Tool Categories

When you run `mcp list`, you should see tools in these categories:

1. **Jira Tools** (~60 tools)
   - `jira_get_ticket`, `jira_create_ticket`, `jira_search_by_jql`, etc.

2. **Confluence Tools** (~25 tools)
   - `confluence_create_page`, `confluence_search_content_by_text`, etc.

3. **Figma Tools** (~15 tools)
   - `figma_get_screen_source`, `figma_download_node_image`, etc.

4. **AI Tools** (~10 tools)
   - `gemini_ai_chat`, `gemini_ai_chat_with_files`, `anthropic_ai_chat`, etc.

5. **Microsoft Teams Tools** (~30 tools)
   - `teams_send_message`, `teams_get_call_transcripts`, etc.

6. **Azure DevOps Tools** (~15 tools)
   - `ado_get_work_item`, `ado_create_work_item`, etc.

7. **File Operations** (~4 tools)
   - `file_read`, `file_write`, `file_validate_json`, etc.

8. **Other Tools** (~7 tools)
   - `kb_get`, `mermaid_index_generate`, `cli_execute_command`, etc.

**Total: 136+ tools**

---

**Last Updated:** December 30, 2025
