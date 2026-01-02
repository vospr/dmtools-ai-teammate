# Test Jira with Cache Clear
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "JIRA API CONNECTION TEST (CLEAR CACHE)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd "c:\Users\AndreyPopov\dmtools"

Write-Host "[1/3] Clearing DMTools cache..." -ForegroundColor Yellow

# Clear all cache directories
$cacheDirs = @(
    "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\cacheBasicJiraClient",
    "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\cacheGeminiJSAIClient",
    "c:\Users\AndreyPopov\dmtools\cache",
    "$env:USERPROFILE\.dmtools\cache"
)

foreach ($dir in $cacheDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $dir" -ForegroundColor Gray
    }
}
Write-Host "   Cache cleared" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Loading environment variables..." -ForegroundColor Yellow
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
Write-Host ""

Write-Host "[3/3] Testing Jira API (may take 10-20 seconds)..." -ForegroundColor Yellow
$result = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile 2>&1 | Out-String

# Check result
if ($result -match '"accountId"' -and $result -match '"emailAddress"') {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Jira API Connected" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Extract info
    if ($result -match '"displayName"\s*:\s*"([^"]+)"') {
        Write-Host "Name: $($matches[1])" -ForegroundColor White
    }
    if ($result -match '"emailAddress"\s*:\s*"([^"]+)"') {
        Write-Host "Email: $($matches[1])" -ForegroundColor White
    }
    if ($result -match '"accountId"\s*:\s*"([^"]+)"') {
        $accountId = $matches[1]
        Write-Host "Account ID: $accountId" -ForegroundColor White
        $accountId | Out-File "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
    }
    
    Write-Host "`nFull response saved to: jira-profile.json" -ForegroundColor Gray
    $result | Out-File "jira-profile.json" -Encoding UTF8
    
} elseif ($result -match '401') {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "FAILED: 401 Authentication Error" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    Write-Host "The API token may be expired or invalid." -ForegroundColor Yellow
    Write-Host "Please regenerate token at:" -ForegroundColor Yellow
    Write-Host "https://id.atlassian.com/manage-profile/security/api-tokens" -ForegroundColor Cyan
    
} else {
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "Unknown Result" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
    Write-Host $result
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

