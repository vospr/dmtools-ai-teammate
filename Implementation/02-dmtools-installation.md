# DMTools CLI Installation and Verification Guide

This guide will help you install and verify the dmtools CLI, which provides 67 MCP (Model Context Protocol) tools for integrating with Jira, Confluence, Figma, and other services.

## Overview

**What is dmtools CLI?**
- Command-line interface for project management automation
- 67 built-in MCP tools for Jira, Confluence, GitHub, GitLab, Figma
- Used by Cursor AI and GitHub Actions for automated workflows
- Written in Java, works on Windows, macOS, and Linux

**What You'll Accomplish:**
- ✅ Verify if dmtools is already installed
- ✅ Install dmtools if needed (using PowerShell script)
- ✅ Verify MCP server capabilities
- ✅ Test basic CLI commands

---

## Step 1: Check If dmtools Is Already Installed

Open PowerShell or Command Prompt and run:

```powershell
dmtools --version
```

### Possible Outcomes:

#### ✅ **Already Installed**
```
dmtools version 1.x.x
Java version: 11.0.x
```
→ **Skip to Step 3** (Verify MCP Server)

#### ❌ **Not Installed**
```
'dmtools' is not recognized as an internal or external command
```
→ **Continue to Step 2** (Installation)

#### ⚠️ **Path Issue**
```
The system cannot find the path specified
```
→ Check your `PATH` environment variable or **continue to Step 2** for fresh installation

---

## Step 2: Install dmtools CLI

### Installation Method 1: Using PowerShell Script (Recommended)

The dmtools repository includes a PowerShell installation script that handles everything automatically.

#### Prerequisites
- Windows 10 or later
- PowerShell 5.1 or later
- Java 11 or later (will be installed if missing)

#### Run Installation Script

1. **Open PowerShell as Administrator**
   - Press `Win + X`
   - Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Navigate to dmtools folder**
   ```powershell
   cd "c:\Users\AndreyPopov\dmtools"
   ```

3. **Run the installation script**
   ```powershell
   .\install.ps1
   ```

4. **Follow the prompts**
   - The script will check for Java
   - Install Java if needed
   - Build the dmtools JAR file
   - Set up PATH environment variables
   - Create a `dmtools` command wrapper

#### Expected Output
```
Checking Java installation...
Java 11.0.x found
Building dmtools...
BUILD SUCCESSFUL
Installing dmtools CLI...
Setting up PATH...
Installation complete!

Please restart your terminal to use 'dmtools' command.
```

5. **Restart PowerShell**
   - Close and reopen PowerShell to apply PATH changes
   - Test: `dmtools --version`

### Installation Method 2: Manual Installation

If the automated script doesn't work, follow these manual steps:

#### Step 2.1: Verify Java Installation

```powershell
java -version
```

**Required:** Java 11 or later

If Java is not installed:
1. Download from: [https://adoptium.net/](https://adoptium.net/)
2. Install the JDK (not just JRE)
3. Verify installation: `java -version`

#### Step 2.2: Build dmtools JAR

```powershell
cd "c:\Users\AndreyPopov\dmtools"
.\gradlew.bat shadowJar
```

**Expected output:**
```
BUILD SUCCESSFUL in Xs
```

**Result:** JAR file created at `dmtools-server\build\libs\dmtools.jar`

#### Step 2.3: Install dmtools JAR and Create Command Wrapper

The dmtools JAR should be installed to the user's home directory, and a wrapper script created for easy access.

**Step 2.3.1: Copy JAR to Installation Directory**

```powershell
# Create installation directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.dmtools\bin"

# Copy the built JAR to installation directory
Copy-Item "build\libs\dmtools-v1.7.102-all.jar" "$env:USERPROFILE\.dmtools\dmtools.jar" -Force
```

**Step 2.3.2: Create Command Wrapper**

Create a batch file: `C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd`

```batch
@echo off
setlocal

REM DMTools CLI Wrapper for Windows
REM This script provides a simple 'dmtools' command that wraps the Java execution

REM Check if Java is available
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 11 or later from https://adoptium.net/
    exit /b 1
)

REM Set DMTools JAR path (relative to this script)
set DMTOOLS_JAR=%~dp0..\dmtools.jar

REM Check if JAR exists
if not exist "%DMTOOLS_JAR%" (
    echo Error: dmtools.jar not found at %DMTOOLS_JAR%
    echo Please run: gradlew shadowJar
    exit /b 1
)

REM Load environment from dmtools.env if it exists in current directory
if exist "dmtools.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("dmtools.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            if not "%%a"=="" (
                set "%%a=%%b"
            )
        )
    )
)

REM Load environment from dmtools source folder if it exists
if exist "%~dp0..\..\dmtools\dmtools.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%~dp0..\..\dmtools\dmtools.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            if not "%%a"=="" (
                set "%%a=%%b"
            )
        )
    )
)

REM Execute dmtools with "mcp" prefix and all arguments passed through
java -jar "%DMTOOLS_JAR%" mcp %*

endlocal
```

**Expected File Structure After Step 2.3:**

```
C:\Users\AndreyPopov\.dmtools\
├── bin\
│   └── dmtools.cmd          [Command wrapper]
└── dmtools.jar              [Installed JAR file]

c:\Users\AndreyPopov\dmtools\
└── dmtools.env              [Configuration file with credentials]
```

**Note:** The `dmtools.env` file should remain in the source directory (`c:\Users\AndreyPopov\dmtools\`). The wrapper script will automatically load it from there when you run commands from any directory.

#### Step 2.4: Add dmtools to PATH

1. **Open System Environment Variables**
   - Press `Win + R`
   - Type: `sysdm.cpl` and press Enter
   - Go to **Advanced** tab → **Environment Variables**

2. **Edit PATH**
   - Under **User variables**, find `Path`
   - Click **Edit**
   - Click **New**
   - Add: `C:\Users\AndreyPopov\.dmtools\bin`
   - Click **OK** on all dialogs
   
   **Note:** This adds the `bin` directory containing `dmtools.cmd` to your PATH, not the source directory.

3. **Test PATH Configuration**

   **Option A: Restart PowerShell (Recommended)**
   - Close and reopen PowerShell
   - Test: `dmtools --version`
   
   **Option B: Reload PATH in Current Session (Quick Test)**
   - Run the test script to reload PATH and verify:
     ```powershell
     cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
     powershell -ExecutionPolicy Bypass -File test-dmtools-path.ps1
     ```
   - This script will:
     - Reload PATH from User environment variables
     - Verify dmtools is in PATH
     - Test the `dmtools --version` command
     - Show success/failure status
   
   **Expected Output:**
   ```
   ✅ PATH CONFIGURATION TEST PASSED
   The dmtools command is now working in this PowerShell session!
   ```

---

## Step 3: Verify MCP Server Capabilities

dmtools provides 67 MCP tools. Let's verify they're accessible:

### List All Available Tools

```powershell
dmtools list
```

**Expected output:** Long list of available tools

Key tools you should see:
```
jira_get_ticket
jira_search_by_jql
jira_create_ticket
jira_update_ticket
confluence_get_page
confluence_search
figma_get_file
figma_download_image_of_file
github_create_pull_request
gemini_ai_chat
gemini_ai_chat_with_files
... (total 67 tools)
```

### Verify Tool Help

Test that help information is available:

```powershell
dmtools help jira_get_ticket
```

**Expected output:**
```
Tool: jira_get_ticket
Description: Get a Jira ticket by key
Parameters:
  - ticketKey (required): The Jira ticket key (e.g., PROJ-123)
Example:
  dmtools jira_get_ticket PROJ-123
```

---

## Step 4: Test Basic CLI Commands (Without Configuration)

Before setting up full configuration, let's test that dmtools can execute commands:

### Test 1: Version Check
```powershell
dmtools --version
```

**Expected:** Version information

### Test 2: List Tools
```powershell
dmtools list
```

**Expected:** List of 67 tools

### Test 3: Help for Specific Tool
```powershell
dmtools help gemini_ai_chat
```

**Expected:** Help text with parameters and examples

---

## Step 5: Verify File Structure

Ensure all necessary files are in place:

### Source Directory Structure

**Location:** `c:\Users\AndreyPopov\dmtools\`

```powershell
cd "c:\Users\AndreyPopov\dmtools"
Get-ChildItem -Directory | Select-Object Name | Sort-Object Name
Get-ChildItem -File | Select-Object Name | Sort-Object Name
```

**Key directories you should see:**

| Directory | Purpose |
|-----------|---------|
| `dmtools-server/` | Main server code and CLI implementation |
| `dmtools-core/` | Core functionality (Jira, Confluence, Figma clients) |
| `dmtools-automation/` | Automation jobs and workflows |
| `dmtools-mcp-annotations/` | MCP protocol annotations |
| `dmtools-annotation-processor/` | Compile-time annotation processing |
| `build/` | Build output directory (created after build) |
| `agents/` | AI agent configurations |
| `docs/` | Documentation files |
| `examples/` | Example scripts and configurations |
| `gradle/` | Gradle wrapper files |
| `.gradle/` | Gradle cache (created automatically) |

**Key files you should see:**

| File | Purpose |
|------|---------|
| `build.gradle` | Root build configuration |
| `settings.gradle` | Gradle project settings |
| `gradlew.bat` | Gradle wrapper for Windows |
| `gradlew` | Gradle wrapper for Linux/macOS |
| `install.ps1` | PowerShell installation script |
| `install.sh` | Linux/macOS installation script |
| `dmtools.env` | **Your environment configuration** (with credentials) |
| `dmtools.env.example` | Example environment configuration template |
| `README.md` | Project documentation |
| `LICENSE` | License file |

### Installation Directory Structure

**Location:** `C:\Users\AndreyPopov\.dmtools\`

```powershell
Get-ChildItem "C:\Users\AndreyPopov\.dmtools" -Recurse | Select-Object FullName, Length
```

**Expected structure:**

```
C:\Users\AndreyPopov\.dmtools\
├── bin\
│   └── dmtools.cmd          [Command wrapper script - 1.4 KB]
└── dmtools.jar              [Main JAR file - ~76 MB]
```

**Verification commands:**

```powershell
# Check installation directory
Test-Path "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
Test-Path "C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd"

# Check source directory
Test-Path "c:\Users\AndreyPopov\dmtools\dmtools.env"
Test-Path "c:\Users\AndreyPopov\dmtools\build.gradle"
```

**Expected results:** All paths should return `True`

### Automated File Structure Test

**Run the validation script:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
powershell -ExecutionPolicy Bypass -File test-file-structure.ps1
```

**What it checks:**
- ✅ Source directory exists
- ✅ All 7 required source directories present
- ✅ All 6 required source files present
- ✅ Installation directory exists
- ✅ Installation files present (JAR and wrapper)
- ✅ Configuration file exists with credentials

**Expected Output:**
```
✅ File structure is correct!
All required files and directories are in place.
```

---

## Step 6: MCP Server Configuration for Cursor

Configure Cursor IDE to automatically discover and use dmtools MCP tools.

### Cursor MCP Configuration Location

**Windows Configuration File:**
```
%USERPROFILE%\.cursor\mcp.json
```

**Full Path:**
```
C:\Users\AndreyPopov\.cursor\mcp.json
```

### Automated Setup (Recommended)

**Run the setup script:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
powershell -ExecutionPolicy Bypass -File setup-cursor-mcp.ps1
```

This script will:
- ✅ Create `.cursor` directory if it doesn't exist
- ✅ Create or update `mcp.json` with dmtools configuration
- ✅ Preserve any existing MCP server configurations
- ✅ Configure dmtools to use stdio transport

**Expected Output:**
```
✅ MCP configuration saved to: C:\Users\AndreyPopov\.cursor\mcp.json
```

### Manual Setup (Alternative)

If you prefer to configure manually:

1. **Create or edit MCP configuration file:**
   ```powershell
   # Ensure .cursor directory exists
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.cursor"
   
   # Edit mcp.json
   notepad "$env:USERPROFILE\.cursor\mcp.json"
   ```

2. **Add dmtools MCP server configuration:**
   ```json
   {
     "mcpServers": {
       "dmtools": {
         "command": "powershell",
         "args": [
           "-ExecutionPolicy",
           "Bypass",
           "-File",
           "C:\\Users\\AndreyPopov\\.dmtools\\bin\\dmtools-mcp-wrapper.ps1"
         ],
         "env": {
           "DMTOOLS_ENV": "c:\\Users\\AndreyPopov\\dmtools\\dmtools.env"
         }
       }
     }
   }
   ```

   **Note:** If you already have other MCP servers configured, add `dmtools` to the existing `mcpServers` object.

3. **Save the file** and restart Cursor IDE

### Verify Configuration

**Option A: Check Configuration File**
```powershell
Get-Content "$env:USERPROFILE\.cursor\mcp.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

**Option B: Run Validation Script**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
powershell -ExecutionPolicy Bypass -File test-cursor-mcp-config.ps1
```

### Activate in Cursor

1. **Restart Cursor IDE** (required to load new MCP configuration)
   - Close all Cursor windows
   - Reopen Cursor

2. **Verify MCP Server Connection:**
   - Open Cursor Settings (`Ctrl+,`)
   - Navigate to **Tools & Integrations** → **MCP Servers**
   - Look for **"dmtools"** in the list
   - It should show as **"Connected"** with a green indicator

3. **Test MCP Tools:**
   - In Cursor chat, try: `@dmtools list tools`
   - Or use Command Palette: `Ctrl+Shift+P` → search for "MCP" or "dmtools"
   - You should see dmtools MCP tools available

### Expected MCP Configuration Format

The `mcp.json` file should contain:
```json
{
  "mcpServers": {
    "dmtools": {
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "C:\\Users\\AndreyPopov\\.dmtools\\bin\\dmtools-mcp-wrapper.ps1"
      ],
      "env": {
        "DMTOOLS_ENV": "c:\\Users\\AndreyPopov\\dmtools\\dmtools.env"
      }
    }
  }
}
```

**Note:** The wrapper script (`dmtools-mcp-wrapper.ps1`) handles JSON-RPC protocol conversion, as dmtools CLI doesn't natively support JSON-RPC over stdio.

**Key Points:**
- `command`: The Java executable (must be in PATH)
- `args`: Arguments to pass to Java (JAR path and "mcp" command)
- `env`: Environment variables (points to dmtools.env for credentials)
- Uses **stdio transport** (Cursor communicates via stdin/stdout)

### Troubleshooting

**Issue: Cursor doesn't show dmtools MCP server**
- **Solution:** 
  - Verify `mcp.json` exists and has valid JSON
  - Restart Cursor completely (close all windows)
  - Check Cursor Settings → Tools & Integrations

**Issue: "Command not found" error**
- **Solution:**
  - Ensure Java is in PATH: `java -version`
  - Verify JAR path is correct: `Test-Path "C:\Users\AndreyPopov\.dmtools\dmtools.jar"`

**Issue: MCP server shows as "Disconnected"**
- **Solution:**
  - Check that `dmtools.env` exists at the specified path
  - Verify Java can execute the JAR: `java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list`
  - Check Cursor's developer console for error messages

**Issue: Tools not appearing in Cursor**
- **Solution:**
  - Wait 10-30 seconds after Cursor starts (MCP servers load asynchronously)
  - Try using `@dmtools` in chat or Command Palette
  - Check Cursor's MCP server status in Settings

---

## Step 7: Verification Checklist

Before proceeding to configuration, verify:

- [x] **Java 21** installed and accessible ✅ VERIFIED
- [x] **dmtools CLI built successfully** (v1.7.102) ✅ VERIFIED
- [x] **136 MCP tools generated** ✅ VERIFIED
- [x] **JAR file installed** at `C:\Users\AndreyPopov\.dmtools\dmtools.jar` ✅ VERIFIED
- [x] **CLI wrapper created** (`dmtools.cmd`) ✅ VERIFIED
- [x] **Environment configured** (`dmtools.env` with all credentials) ✅ VERIFIED
- [ ] API connections tested (use test script below) ⏳ READY

---

## Step 8: ✅ INSTALLATION COMPLETED SUCCESSFULLY

### Build Summary

**Date:** December 30, 2025  
**Version:** DMTools v1.7.102  
**Java:** OpenJDK 21.0.5 LTS  
**Build Tool:** Gradle 8.11.1  
**Build Time:** 1 minute 30 seconds  
**Status:** ✅ **SUCCESS**

### Generated MCP Tools: 136

During build, the following tool categories were generated:

| Category | Tools | Examples |
|----------|-------|----------|
| **Jira** | ~60 | jira_get_ticket, jira_create_ticket, jira_post_comment |
| **Confluence** | ~25 | confluence_create_page, confluence_search_content_by_text |
| **Figma** | ~15 | figma_download_node_image, figma_get_styles |
| **Microsoft Teams** | ~30 | teams_send_message, teams_get_call_transcripts |
| **Azure DevOps** | ~15 | ado_get_work_item, ado_create_work_item |
| **AI Services** | ~10 | gemini_ai_chat, anthropic_ai_chat, bedrock_ai_chat |
| **File Operations** | ~4 | file_read, file_write |
| **Other** | ~7 | kb_get, mermaid_index_generate, cli_execute_command |

### Installation Paths

**CLI Installation:**
```
C:\Users\AndreyPopov\.dmtools\
├── bin\dmtools.cmd        [CLI wrapper]
└── dmtools.jar            [v1.7.102-all, includes all dependencies]
```

**Source & Build:**
```
c:\Users\AndreyPopov\dmtools\
├── build\libs\dmtools-v1.7.102-all.jar  [Built successfully]
└── dmtools.env                           [Credentials configured]
```

### Configuration Status

All required credentials configured in `dmtools.env`:

- ✅ **Jira:** https://vospr.atlassian.net (andrey_popov@epam.com)
- ✅ **Confluence:** https://vospr.atlassian.net/wiki (andrey_popov@epam.com)
- ✅ **Gemini AI:** API key configured (gemini-2.0-flash-exp)
- ✅ **GitHub:** Token configured (workspace: vospr)
- ✅ **Figma:** API key configured
- ✅ **Cursor:** API key configured

### Verified Commands

The following commands are ready to use:

```powershell
# Show help
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --help

# List all 136 tools
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" list

# Test Jira connection
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" jira_get_my_profile

# Test Gemini AI
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" gemini_ai_chat --data '{"prompt":"Hello"}'
```

---

## Step 9: Test API Connections (Optional)

### Automated Test Script

A comprehensive test script has been created to verify all API connections:

**Location:** `ai-teammate\test-dmtools-complete.ps1`

**To run:**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-dmtools-complete.ps1
```

**What it tests:**
1. ✅ CLI accessibility
2. ✅ Lists all 136 MCP tools
3. ✅ Jira API connection
4. ✅ Confluence API connection
5. ✅ Gemini AI connection
6. ℹ️ Saves tool list to `mcp-tools-list.txt`

### Manual Testing (Alternative)

If you prefer to test manually:

```powershell
# Load environment variables
cd "c:\Users\AndreyPopov\dmtools"

# Test Jira
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" jira_get_my_profile

# Test Confluence
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" confluence_get_current_user_profile

# Test Gemini AI (create prompt file first)
@{ prompt = "Say hello" } | ConvertTo-Json | Out-File test-prompt.json
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" gemini_ai_chat --file test-prompt.json
```

---

## Step 10: Review Documentation

Three comprehensive reference documents have been created:

### 1. Tools Reference (136 tools)
**File:** `ai-teammate\dmtools-tools-reference.md`

Complete catalog of all 136 MCP tools with:
- Categorization by service
- Usage examples
- Common patterns
- Configuration requirements

### 2. Verification Results
**File:** `ai-teammate\dmtools-verification-results.md`

Detailed installation report including:
- Build timeline and modifications
- File structure verification
- Test procedures
- Troubleshooting guide

### 3. Test Script
**File:** `ai-teammate\test-dmtools-complete.ps1`

Automated testing for:
- CLI functionality
- Tool discovery
- API connections
- Credential validation

---

## Troubleshooting

### Issue: "dmtools is not recognized"

**Causes:**
- PATH not set correctly
- PowerShell not restarted after installation

**Solutions:**
1. Restart PowerShell completely (close all windows)
2. Verify PATH includes dmtools folder:
   ```powershell
   $env:PATH -split ';' | Select-String "dmtools"
   ```
3. Try running dmtools with full path:
   ```powershell
   c:\Users\AndreyPopov\dmtools\dmtools.bat --version
   ```

### Issue: "Java not found"

**Solution:**
```powershell
# Check if Java is installed
java -version

# If not, install from: https://adoptium.net/
# Download: Eclipse Temurin JDK 11 or later
```

### Issue: "BUILD FAILED" during installation

**Common causes:**
- No internet connection (Gradle needs to download dependencies)
- Firewall blocking Gradle
- Insufficient disk space

**Solutions:**
1. Check internet connection
2. Try again with administrator privileges
3. Clear Gradle cache:
   ```powershell
   rd /s /q "$env:USERPROFILE\.gradle\caches"
   .\gradlew.bat clean shadowJar
   ```

### Issue: "Cannot find JAR file"

**Solution:**
```powershell
# Verify JAR was built
dir "c:\Users\AndreyPopov\dmtools\dmtools-server\build\libs\dmtools.jar"

# If missing, rebuild
cd "c:\Users\AndreyPopov\dmtools"
.\gradlew.bat clean shadowJar
```

### Issue: MCP tools not appearing in Cursor

**Current Status:**
- MCP integration with Cursor on Windows may require additional configuration
- For this learning tutorial, we'll use dmtools CLI directly via commands
- GitHub Actions integration (covered later) doesn't require MCP integration

**Workaround:**
- Use dmtools CLI commands directly in terminal
- Example in Cursor: Open terminal and run `dmtools jira_get_ticket PROJ-123`

---

## Understanding dmtools Architecture

### Components

```
dmtools/
├── dmtools-core/           # Core functionality (Jira, Confluence clients)
├── dmtools-server/         # CLI server and MCP implementation
├── dmtools-automation/     # Automation jobs (20 predefined jobs)
├── dmtools-mcp-annotations/ # MCP protocol annotations
└── dmtools-annotation-processor/ # Compile-time processing
```

### How It Works

1. **CLI Layer:** `dmtools` command accepts tool names and parameters
2. **MCP Layer:** Tools are discovered via MCP protocol annotations
3. **Integration Layer:** Each tool connects to external APIs (Jira, Gemini, etc.)
4. **Configuration Layer:** Environment variables from `dmtools.env` provide credentials

### MCP Protocol

**Model Context Protocol (MCP)** is a standard for:
- **Tool Discovery:** AI agents can list available tools
- **Tool Execution:** AI agents can call tools with parameters
- **Standardized Interface:** Consistent way to expose capabilities

dmtools implements MCP via:
- `@MCPTool` annotation on tool methods
- Automatic discovery and registration
- JSON-RPC protocol for communication

---

## What's Next?

Now that dmtools is installed and verified:

1. ✅ **dmtools CLI is working** (v1.7.102)
2. ✅ **136 MCP tools are accessible**
3. ✅ **Java 21 environment is configured**
4. ✅ **All credentials configured in `dmtools.env`**
5. ✅ **Documentation and test scripts created**

### Recommended Next Steps:

**Option 1: Test API Connections (Recommended)**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-dmtools-complete.ps1
```

**Option 2: Review Tools Reference**
- See: [dmtools-tools-reference.md](dmtools-tools-reference.md)
- Browse all 136 available tools
- Learn usage patterns and examples

**Option 3: Proceed to Jira Project Setup**
→ **Next Guide:** [04-jira-project-setup.md](04-jira-project-setup.md)  
Create a simple Jira project for testing the AI teammate

### Quick Reference

| File | Purpose |
|------|---------|
| [dmtools-tools-reference.md](dmtools-tools-reference.md) | Complete catalog of 136 tools |
| [dmtools-verification-results.md](dmtools-verification-results.md) | Installation report & test procedures |
| [test-dmtools-complete.ps1](test-dmtools-complete.ps1) | Automated test script |
| [04-jira-project-setup.md](04-jira-project-setup.md) | Next: Create test project |

---

## Additional Resources

- **DMTools GitHub:** [https://github.com/IstiN/dmtools](https://github.com/IstiN/dmtools)
- **DMTools Documentation:** `c:\Users\AndreyPopov\dmtools\docs\`
- **MCP Protocol Specification:** [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- **Java Download:** [https://adoptium.net/](https://adoptium.net/)

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [01-api-credentials-guide.md](01-api-credentials-guide.md)  
**Next Step:** Create `dmtools.env` configuration file

