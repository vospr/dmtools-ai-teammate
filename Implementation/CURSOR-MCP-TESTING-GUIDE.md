# Testing DMTools MCP Tools in Cursor IDE

## Quick Start

Since your dmtools MCP server is **connected** (92 tools enabled), you can test the tools directly in Cursor's chat interface.

## Which Cursor Mode to Use

### ✅ **Recommended: Chat Mode (Default)**
- **How to access:** Click the chat icon in the sidebar or press `Ctrl+L` (Windows) / `Cmd+L` (Mac)
- **Best for:** Testing individual tools, asking questions, getting quick results
- **MCP tools:** Fully available and automatically used by Cursor when needed

### ✅ **Alternative: Composer Mode**
- **How to access:** Click the Composer icon or press `Ctrl+I` (Windows) / `Cmd+I` (Mac)
- **Best for:** Multi-file operations, complex workflows, batch operations
- **MCP tools:** Available but may require more explicit instructions

### ❌ **Not Recommended: Agent Mode**
- Agent mode is for autonomous code changes and may not be ideal for simple tool testing
- Use Chat or Composer for testing MCP tools

**For this testing guide, use Chat Mode (`Ctrl+L` or `Cmd+L`).**

---

## Test Commands to Try

### 1. Test Jira Connection (Simplest)

**Step 1:** Open Cursor Chat Mode (`Ctrl+L` or `Cmd+L`)

**Step 2:** Type in the chat:
```
Get my Jira profile using the dmtools MCP tools
```

**Or more specifically:**
```
Use the jira_get_my_profile tool from dmtools to get my profile information
```

**Expected result:** Should return your Jira profile with:
- `displayName`
- `emailAddress` 
- `accountId`

---

### 2. Test Jira - List Projects

**Step 1:** In Cursor Chat Mode (`Ctrl+L`)

**Step 2:** Type:
```
Search for Jira tickets in project VOSPR using JQL: project = VOSPR ORDER BY created DESC
```

**Expected result:** Should return a list of tickets from your Jira project

---

### 3. Test Confluence Connection

**Step 1:** In Cursor Chat Mode (`Ctrl+L`)

**Step 2:** Type:
```
Get my Confluence profile using dmtools
```

**Or:**
```
Use confluence_get_current_user_profile tool
```

**Expected result:** Should return your Confluence user profile

---

### 4. Test Gemini AI

**Step 1:** In Cursor Chat Mode (`Ctrl+L`)

**Step 2:** Type:
```
Use the gemini_ai_chat tool to send a message: "Hello, respond with OK"
```

**Expected result:** Should return a response from Gemini AI

---

### 5. Test File Operations

**Step 1:** In Cursor Chat Mode (`Ctrl+L`)

**Step 2:** Type:
```
Use dmtools to read the file: c:\Users\AndreyPopov\dmtools\README.md
```

**Expected result:** Should return the contents of the README file

---

## How to Verify Tools Are Working

### Check Tool Execution

**In Chat Mode (`Ctrl+L`):**

1. When you ask Cursor to use a tool, it should:
   - Show which tool it's calling (you may see "Using tool: jira_get_my_profile")
   - Execute the tool
   - Return results

2. **Watch the chat interface:**
   - Cursor will indicate when it's calling an MCP tool
   - You may see a brief loading indicator
   - Results appear in the chat response

2. If authentication fails, you'll see:
   - Error messages about "401 Unauthorized"
   - "Client must be authenticated" errors

3. If tools work correctly, you'll see:
   - Actual data (profiles, tickets, AI responses, etc.)
   - No authentication errors

---

## Troubleshooting

### If Tools Don't Execute
1. **Check MCP Server Status:**
   - Settings → Tools & Integrations → MCP Servers
   - Verify "dmtools" shows as "Connected" (green)

2. **Check Cursor Output:**
   - View → Output
   - Select "anysphere.cursor-mcp.MCP user-dmtools"
   - Look for error messages

3. **Restart Cursor:**
   - Close Cursor completely
   - Reopen and wait 30-60 seconds for MCP servers to initialize

### If Authentication Fails
- The wrapper script loads credentials from `c:\Users\AndreyPopov\dmtools\dmtools.env`
- Verify the file exists and contains valid tokens
- Check that credentials haven't expired

---

## Next Steps After Testing

Once you've verified tools work in Cursor:
1. ✅ MCP integration is complete
2. ✅ You can use all 92 tools in Cursor chat
3. ✅ Ready to build AI workflows using DMTools

---

## Example Successful Test Output

**You ask:** "Get my Jira profile"

**Cursor responds:**
```
I'll get your Jira profile using the dmtools MCP tools.

[Calling jira_get_my_profile tool...]

Your Jira profile:
- Display Name: Andrey Popov
- Email: andrey_popov@epam.com
- Account ID: 123456:abcdef-1234-5678-90ab-cdef12345678
```

This confirms the tool executed successfully and authentication worked!
