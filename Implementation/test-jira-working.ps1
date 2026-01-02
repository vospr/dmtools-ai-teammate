# Working Jira Connection Test
# Loads environment variables and tests Jira API

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "JIRA API CONNECTION TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Navigate to dmtools folder
cd "c:\Users\AndreyPopov\dmtools"

Write-Host "[1/2] Loading environment variables from dmtools.env..." -ForegroundColor Yellow

# Load environment variables from dmtools.env
Get-Content "dmtools.env" | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -match '='
} | ForEach-Object {
    $parts = $_ -split '=', 2
    if ($parts.Length -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        [Environment]::SetEnvironmentVariable($key, $value, 'Process')
    }
}

Write-Host "   Environment loaded" -ForegroundColor Green
Write-Host "   JIRA_BASE_PATH: $env:JIRA_BASE_PATH" -ForegroundColor Gray
Write-Host "   JIRA_EMAIL: $env:JIRA_EMAIL" -ForegroundColor Gray
Write-Host ""

Write-Host "[2/2] Testing Jira API connection..." -ForegroundColor Yellow
Write-Host "   This may take 10-20 seconds..." -ForegroundColor Gray
Write-Host ""

# Test Jira connection
$result = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile 2>&1 | Out-String

# Check if successful
if ($result -match '"accountId"' -and $result -match '"emailAddress"') {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS: Jira API Connected!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your Jira Profile:" -ForegroundColor Cyan
    
    # Extract key info from JSON
    if ($result -match '"displayName"\s*:\s*"([^"]+)"') {
        Write-Host "   Name: $($matches[1])" -ForegroundColor White
    }
    if ($result -match '"emailAddress"\s*:\s*"([^"]+)"') {
        Write-Host "   Email: $($matches[1])" -ForegroundColor White
    }
    if ($result -match '"accountId"\s*:\s*"([^"]+)"') {
        Write-Host "   Account ID: $($matches[1])" -ForegroundColor White
        # Save account ID for later use
        $matches[1] | Out-File "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
    }
    
    Write-Host ""
    Write-Host "Full response saved to: jira-profile.json" -ForegroundColor Gray
    $result | Out-File "jira-profile.json" -Encoding UTF8
    
} elseif ($result -match '401') {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "FAILED: Authentication Error (401)" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  - API token expired or invalid" -ForegroundColor Gray
    Write-Host "  - Incorrect email address" -ForegroundColor Gray
    Write-Host "  - Incorrect Jira URL" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Check credentials in: c:\Users\AndreyPopov\dmtools\dmtools.env" -ForegroundColor Cyan
    
} elseif ($result -match '"error"\s*:\s*true') {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "FAILED: API Error" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $result
    
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "UNKNOWN RESULT" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Full output:" -ForegroundColor Gray
    Write-Host $result
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

