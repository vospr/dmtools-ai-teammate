# Root Cause Analysis: Why dmtools CLI Commands Failed for Sub-ticket Creation

**Date:** January 1, 2026  
**Issue:** Sub-tickets could not be created using `dmtools` CLI commands  
**Solution:** Direct Jira REST API was used as workaround

---

## Executive Summary

The `dmtools` CLI commands failed to create sub-tickets due to **four root causes**:

1. **Missing `--file` flag implementation** - The flag is documented but not implemented in `McpCliHandler`
2. **PowerShell JSON escaping issues** - Complex JSON with newlines and special characters breaks when passed via stdin or `--data`
3. **Parameter parsing limitations** - The argument parser doesn't handle nested JSON objects correctly for `fieldsJson`
4. **Description format incompatibility** - Jira API v3 requires ADF format, but `dmtools` sends plain text descriptions

---

## Root Causes

### Root Cause #1: `--file` Flag Not Implemented

**Problem:**
- The documentation (`docs/cli-usage/mcp-tools.md`) shows `--file` flag is supported
- However, `McpCliHandler.parseToolArguments()` **does NOT implement `--file` flag handling**
- Only `--data` and `--stdin-data` flags are implemented

**Evidence:**
```java
// From McpCliHandler.java:179-222
private Map<String, Object> parseToolArguments(String[] args) {
    // ... only handles:
    if ("--data".equals(arg) && i + 1 < args.length) { ... }
    else if ("--stdin-data".equals(arg) && i + 1 < args.length) { ... }
    // NO HANDLING FOR --file FLAG!
}
```

**Error Observed:**
```
dmtools jira_create_ticket_with_parent --file params.json
Result: "Invalid tool or arguments: Required parameter 'issueType' is missing"
```

The `--file` argument is ignored, so no parameters are parsed, leading to "missing parameter" errors.

---

### Root Cause #2: PowerShell JSON Escaping Issues

**Problem:**
When passing JSON via stdin or `--data` flag in PowerShell:
- PowerShell's `ConvertTo-Json` adds extra escaping
- Newlines in descriptions (`\n`) get double-escaped or mangled
- Special characters in markdown descriptions break JSON parsing
- Command line length limits are exceeded for complex JSON

**Evidence:**
```powershell
# Attempt 1: Via stdin
$json | dmtools jira_create_ticket_with_parent
# Error: "The filename, directory name, or volume label syntax is incorrect"
# PowerShell interprets pipe differently than bash

# Attempt 2: Via --data flag
dmtools jira_create_ticket_with_json --data $jsonString
# Error: JSON parsing fails due to escaped quotes and newlines
```

**Why It Fails:**
1. PowerShell's `ConvertTo-Json` produces JSON with Windows line endings
2. When piped to `dmtools`, PowerShell may not pass stdin correctly
3. Complex descriptions with markdown (`*`, `\n`, etc.) break JSON structure
4. `dmtools` receives malformed JSON and fails to parse parameters

---

### Root Cause #3: Nested JSON Object Parameter Issues

**Problem:**
For `jira_create_ticket_with_json`, the `fieldsJson` parameter expects a **JSONObject**, not a JSON string:
- The parameter type is `JSONObject` (Java object)
- When passed via `--data`, it's received as a string
- The conversion from string to JSONObject may fail for complex nested structures
- PowerShell's JSON serialization doesn't match Java's JSONObject expectations

**Evidence:**
```java
// From JiraClient.java:1034
public String createTicketInProjectWithJson(
    @MCPParam(name = "project", ...) String project,
    @MCPParam(name = "fieldsJson", ...) JSONObject fieldsJson  // <-- Expects JSONObject
) throws IOException
```

**Error Observed:**
```
dmtools jira_create_ticket_with_json --file params.json
Result: "Invalid tool or arguments: Required parameter 'fieldsJson' is missing"
```

Even when the file contains valid JSON, the nested `fieldsJson` object isn't properly converted to a Java `JSONObject`.

---

## Why Direct API Call Worked

**Solution Used:**
Direct Jira REST API via PowerShell `Invoke-RestMethod`

**Why It Worked:**
1. **Full Control:** Direct API call bypasses all `dmtools` parsing layers
2. **Proper JSON:** PowerShell can construct JSON exactly as Jira API expects
3. **No Escaping Issues:** JSON is sent directly via HTTP, avoiding shell escaping
4. **ADF Format:** Can format descriptions in Atlassian Document Format (ADF) correctly

**Example:**
```powershell
$body = @{
    fields = @{
        project = @{ key = "ATL" }
        summary = "Q1: ..."
        description = @{ type = "doc"; version = 1; content = [...] }
        issuetype = @{ name = "Sub-task" }
        parent = @{ key = "ATL-2" }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://vospr.atlassian.net/rest/api/3/issue" `
    -Method Post -Headers @{ Authorization = "Basic $base64Auth" } `
    -Body $body
```

---

## Solutions to Fix dmtools CLI Commands

### Solution 1: Implement `--file` Flag Support

**What to Fix:**
Add `--file` flag handling in `McpCliHandler.parseToolArguments()`

**Implementation:**
```java
// In McpCliHandler.java, add to parseToolArguments():
else if ("--file".equals(arg) && i + 1 < args.length) {
    String filePath = args[i + 1];
    try {
        // Read file content
        String fileContent = new String(Files.readAllBytes(Paths.get(filePath)));
        // Parse JSON from file
        JSONObject jsonObj = new JSONObject(fileContent);
        jsonObj.keys().forEachRemaining(key -> {
            arguments.put(key, jsonObj.get(key));
        });
    } catch (Exception e) {
        logger.error("Failed to read or parse file: {}", filePath, e);
        throw new IllegalArgumentException("Failed to read file: " + filePath, e);
    }
    i++; // Skip next argument as it was consumed
}
```

**Location:** `dmtools-core/src/main/java/com/github/istin/dmtools/mcp/cli/McpCliHandler.java`

---

### Solution 2: Fix JSONObject Parameter Conversion

**What to Fix:**
Ensure `fieldsJson` parameter (and other JSONObject parameters) are properly converted from JSON string to JSONObject

**Implementation:**
In `MCPToolExecutor` or parameter conversion layer, detect when a parameter type is `JSONObject` and convert the string value:

```java
// In parameter conversion logic:
if (parameterType == JSONObject.class && value instanceof String) {
    try {
        return new JSONObject((String) value);
    } catch (JSONException e) {
        throw new IllegalArgumentException("Invalid JSON for parameter: " + paramName, e);
    }
}
```

**Location:** Check `MCPToolExecutor` or parameter binding logic

---

### Solution 3: Improve PowerShell Compatibility

**What to Fix:**
Handle PowerShell's JSON output format and stdin behavior

**Options:**

**Option A: Use `--data` with proper escaping**
```powershell
# Use single quotes to avoid PowerShell escaping
$json = '{"project":"ATL","issueType":"Sub-task","summary":"Test","description":"Test","parentKey":"ATL-2"}'
dmtools jira_create_ticket_with_parent --data $json
```

**Option B: Use positional arguments (simplest)**
```powershell
# Use positional arguments instead of JSON
dmtools jira_create_ticket_with_parent ATL "Sub-task" "Summary" "Description" "ATL-2"
```

**Option C: Use stdin with proper encoding**
```powershell
# Use UTF-8 encoding and pipe correctly
$json | Out-File -Encoding UTF8 temp.json -NoNewline
Get-Content temp.json -Raw | dmtools jira_create_ticket_with_parent
```

---

### Solution 4: Use Positional Arguments (Recommended Workaround)

**Best Immediate Solution:**
Use positional arguments instead of JSON for `jira_create_ticket_with_parent`:

```powershell
# This should work:
dmtools jira_create_ticket_with_parent ATL "Sub-task" "Summary" "Description" "ATL-2"
```

**Why This Works:**
- No JSON parsing needed
- No escaping issues
- Direct parameter mapping
- Simpler and more reliable

**Limitation:**
- Description with newlines may still cause issues
- For complex descriptions, use `jira_create_ticket_with_json` with proper file input

---

### Root Cause #4: Jira API Response Format Issue

**Problem:**
Even when using positional arguments (which should work), the command fails with:
```
"Tool execution failed: JSONObject[\"key\"] not found."
```

This suggests the Jira API response doesn't contain a `key` field, which could mean:
1. The ticket creation failed on Jira's side (validation error, permissions, etc.)
2. The response format is different than expected
3. The issue type "Sub-task" might not be available or requires different parameters

**Evidence:**
```powershell
dmtools jira_create_ticket_with_parent ATL "Sub-task" "Test" "Description" "ATL-2"
# Result: "JSONObject[\"key\"] not found"
```

**Why Direct API Worked:**
- Direct API call uses Atlassian Document Format (ADF) for descriptions
- Can handle complex nested JSON structures
- Full control over request format
- Proper error handling and response parsing

**Root Cause:**
The `createTicketInProject` method in `JiraClient.java` (line 975) sets description as a **plain string**:
```java
fields.set("description", description);
```

However, Jira REST API v3 expects descriptions in **Atlassian Document Format (ADF)** for sub-tasks. When a plain string is sent, Jira may reject the request or return an error response without a `key` field, causing the "JSONObject[\"key\"] not found" error.

**Fix Required:**
The `createTicketInProject` method should convert plain text descriptions to ADF format, or the method should accept ADF-formatted descriptions.

---

### Solution 5: Fix Description Format (Critical Fix)

**What to Fix:**
Update `JiraClient.createTicketInProject()` to convert plain text descriptions to ADF format for Jira API v3 compatibility.

**Implementation:**
```java
// In JiraClient.java, modify createTicketInProject():
// Instead of:
fields.set("description", description);

// Use:
if (description != null && !description.isEmpty()) {
    // Convert plain text to ADF format
    JSONObject descDoc = convertTextToADF(description);
    fields.set("description", descDoc);
}

// Add helper method:
private JSONObject convertTextToADF(String text) {
    JSONObject doc = new JSONObject();
    doc.put("type", "doc");
    doc.put("version", 1);
    
    JSONArray content = new JSONArray();
    JSONObject paragraph = new JSONObject();
    paragraph.put("type", "paragraph");
    
    JSONArray paraContent = new JSONArray();
    // Split by newlines and create text nodes
    String[] lines = text.split("\n");
    for (String line : lines) {
        if (!line.trim().isEmpty()) {
            JSONObject textNode = new JSONObject();
            textNode.put("type", "text");
            textNode.put("text", line);
            paraContent.put(textNode);
            // Add hard break for newlines
            if (lines.length > 1) {
                JSONObject hardBreak = new JSONObject();
                hardBreak.put("type", "hardBreak");
                paraContent.put(hardBreak);
            }
        }
    }
    paragraph.put("content", paraContent);
    content.put(paragraph);
    doc.put("content", content);
    
    return doc;
}
```

**Location:** `dmtools-core/src/main/java/com/github/istin/dmtools/atlassian/jira/JiraClient.java`

**Priority:** **CRITICAL** - This is likely the main reason positional arguments fail

---

## Recommended Fix Priority

1. **CRITICAL:** Fix description format (Solution 5)
   - This is the root cause of "JSONObject[\"key\"] not found" error
   - Affects all ticket creation commands
   - Required for Jira API v3 compatibility

2. **HIGH:** Implement `--file` flag support (Solution 1)
   - Most requested feature
   - Documented but not implemented
   - Would solve the immediate problem

3. **MEDIUM:** Fix JSONObject parameter conversion (Solution 2)
   - Needed for `jira_create_ticket_with_json` to work properly
   - Affects other tools with JSONObject parameters

4. **LOW:** Improve PowerShell compatibility (Solution 3)
   - Workarounds exist (positional args, direct API)
   - Platform-specific issue

---

## Testing After Fixes

**Test Case 1: `--file` Flag**
```powershell
# Create test file
@{
    project = "ATL"
    issueType = "Sub-task"
    summary = "Test"
    description = "Test description"
    parentKey = "ATL-2"
} | ConvertTo-Json | Out-File test.json

# Test command
dmtools jira_create_ticket_with_parent --file test.json
# Expected: Creates sub-task successfully
```

**Test Case 2: Positional Arguments**
```powershell
dmtools jira_create_ticket_with_parent ATL "Sub-task" "Test Summary" "Test Description" "ATL-2"
# Expected: Creates sub-task successfully
```

**Test Case 3: Complex JSON via `--data`**
```powershell
$json = '{"project":"ATL","fieldsJson":{"summary":"Test","description":"Multi-line\ndescription","issuetype":{"name":"Sub-task"},"parent":{"key":"ATL-2"}}}'
dmtools jira_create_ticket_with_json --data $json
# Expected: Creates sub-task with complex description
```

---

## Conclusion

The root problems were:
1. **Missing `--file` implementation** (documentation vs. reality mismatch)
2. **PowerShell JSON escaping** (platform-specific issue)
3. **JSONObject parameter conversion** (type conversion gap)

**Immediate Workaround:** Use positional arguments or direct API calls  
**Long-term Fix:** Implement `--file` flag and improve JSONObject parameter handling

---

**Files to Modify:**
- `dmtools-core/src/main/java/com/github/istin/dmtools/mcp/cli/McpCliHandler.java` (add `--file` support)
- Parameter conversion layer (fix JSONObject handling)
- Consider adding PowerShell-specific documentation/examples
