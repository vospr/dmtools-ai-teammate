# =============================================================================
# DMTools Complete Verification Test Script
# =============================================================================
# This script tests all DMTools functionality and credentials
# Run in PowerShell: .\test-dmtools-complete.ps1
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DMTOOLS COMPLETE VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Load environment variables from dmtools.env
Write-Host "[1/6] Loading environment variables..." -ForegroundColor Yellow
$envFile = "c:\Users\AndreyPopov\dmtools\dmtools.env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object {
        $_ -notmatch '^\s*#' -and $_ -match '=' 
    } | ForEach-Object {
        $parts = $_ -split '=', 2
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        }
    }
    Write-Host "   Environment loaded successfully" -ForegroundColor Green
} else {
    Write-Host "   ERROR: dmtools.env not found!" -ForegroundColor Red
    exit 1
}

# Test CLI Accessibility
Write-Host "`n[2/6] Testing CLI accessibility..." -ForegroundColor Yellow
try {
    $helpOutput = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" --help 2>&1
    if ($helpOutput -match "DMTools CLI") {
        Write-Host "   CLI is accessible" -ForegroundColor Green
    } else {
        Write-Host "   WARNING: Unexpected output" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# List all MCP tools
Write-Host "`n[3/6] Listing all MCP tools..." -ForegroundColor Yellow
Write-Host "   Executing: java -jar dmtools.jar mcp list" -ForegroundColor Gray
try {
    $toolsList = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list 2>&1
    $toolsArray = $toolsList | Where-Object { $_ -match '^[a-z_]+$' }
    $toolCount = ($toolsArray | Measure-Object).Count
    Write-Host "   Found $toolCount MCP tools" -ForegroundColor Green
    
    # Save full list to file
    $toolsList | Out-File "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\mcp-tools-list.txt"
    Write-Host "   Full list saved to: mcp-tools-list.txt" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Jira credentials
Write-Host "`n[4/6] Testing API credentials..." -ForegroundColor Yellow
Write-Host "`n   [4.1] Testing Jira connection..." -ForegroundColor Cyan
try {
    # Use MCP interface and pass credentials via system properties
    $jiraProps = @(
        "-DJIRA_BASE_PATH=$env:JIRA_BASE_PATH",
        "-DJIRA_EMAIL=$env:JIRA_EMAIL",
        "-DJIRA_API_TOKEN=$env:JIRA_API_TOKEN",
        "-DJIRA_AUTH_TYPE=$env:JIRA_AUTH_TYPE",
        "-Dpolyglot.engine.WarnInterpreterOnly=false"
    )
    $jiraResult = & java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" $jiraProps mcp jira_get_my_profile 2>&1 | Out-String
    if ($jiraResult -match "error|exception|failed" -and $jiraResult -notmatch "displayName|emailAddress") {
        Write-Host "      JIRA: Connection issue - check credentials" -ForegroundColor Yellow
        Write-Host "      Output: $($jiraResult.Substring(0, [Math]::Min(200, $jiraResult.Length)))" -ForegroundColor Gray
    } elseif ($jiraResult -match "displayName|emailAddress|accountId") {
        Write-Host "      JIRA: Connected successfully" -ForegroundColor Green
    } else {
        Write-Host "      JIRA: Unexpected response" -ForegroundColor Yellow
    }
} catch {
    Write-Host "      JIRA ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Confluence credentials
Write-Host "`n   [4.2] Testing Confluence connection..." -ForegroundColor Cyan
try {
    $confluenceProps = @(
        "-DCONFLUENCE_BASE_PATH=$env:CONFLUENCE_BASE_PATH",
        "-DCONFLUENCE_EMAIL=$env:CONFLUENCE_EMAIL",
        "-DCONFLUENCE_API_TOKEN=$env:CONFLUENCE_API_TOKEN",
        "-DCONFLUENCE_AUTH_TYPE=$env:CONFLUENCE_AUTH_TYPE",
        "-Dpolyglot.engine.WarnInterpreterOnly=false"
    )
    $confluenceResult = & java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" $confluenceProps mcp confluence_get_current_user_profile 2>&1 | Out-String
    if ($confluenceResult -match "displayName|emailAddress|username") {
        Write-Host "      CONFLUENCE: Connected successfully" -ForegroundColor Green
    } elseif ($confluenceResult -match "error|exception|failed") {
        Write-Host "      CONFLUENCE: Connection issue" -ForegroundColor Yellow
    } else {
        Write-Host "      CONFLUENCE: Unexpected response" -ForegroundColor Yellow
    }
} catch {
    Write-Host "      CONFLUENCE ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Gemini AI
Write-Host "`n   [4.3] Testing Gemini AI connection..." -ForegroundColor Cyan
try {
    # Create temp file for AI prompt
    $promptFile = "$env:TEMP\gemini-test-prompt.json"
    @{
        message = "Respond with exactly: OK"
    } | ConvertTo-Json | Out-File $promptFile -Encoding UTF8
    
    $geminiProps = @(
        "-DGEMINI_API_KEY=$env:GEMINI_API_KEY",
        "-DGEMINI_PROJECT_NAME=$env:GEMINI_PROJECT_NAME",
        "-Dpolyglot.engine.WarnInterpreterOnly=false"
    )
    $geminiResult = & java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" $geminiProps mcp gemini_ai_chat message="Respond with exactly: OK" 2>&1 | Out-String
    if ($geminiResult -match "OK|ok") {
        Write-Host "      GEMINI AI: Connected successfully" -ForegroundColor Green
    } elseif ($geminiResult -match "error|exception|failed") {
        Write-Host "      GEMINI AI: Connection issue" -ForegroundColor Yellow
        Write-Host "      Output: $($geminiResult.Substring(0, [Math]::Min(150, $geminiResult.Length)))" -ForegroundColor Gray
    } else {
        Write-Host "      GEMINI AI: Response received (check output)" -ForegroundColor Yellow
    }
    Remove-Item $promptFile -ErrorAction SilentlyContinue
} catch {
    Write-Host "      GEMINI AI ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Figma
Write-Host "`n   [4.4] Testing Figma connection..." -ForegroundColor Cyan
Write-Host "      FIGMA: Skipping (requires file ID)" -ForegroundColor Gray

# Test GitHub
Write-Host "`n   [4.5] Testing GitHub connection..." -ForegroundColor Cyan
Write-Host "      GITHUB: Skipping (requires specific repo)" -ForegroundColor Gray

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CLI:        Tested" -ForegroundColor Green
Write-Host "Tools:      Listed and saved" -ForegroundColor Green
Write-Host "Jira:       Tested" -ForegroundColor Yellow
Write-Host "Confluence: Tested" -ForegroundColor Yellow
Write-Host "Gemini AI:  Tested" -ForegroundColor Yellow
Write-Host "Figma:      Requires file ID for full test" -ForegroundColor Gray
Write-Host "GitHub:     Requires repo for full test" -ForegroundColor Gray
Write-Host "`nNext: Review mcp-tools-list.txt for all available tools" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

