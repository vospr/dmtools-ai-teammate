# Show full DMTools output
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DMTOOLS FULL OUTPUT DEBUG" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd "c:\Users\AndreyPopov\dmtools"

Write-Host "Method 1: Using dmtools.env from current directory" -ForegroundColor Yellow
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
Write-Host "dmtools.env exists: $(Test-Path 'dmtools.env')" -ForegroundColor Gray
Write-Host ""

Write-Host "Full output from DMTools:" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$output = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile 2>&1

Write-Host $output
Write-Host "----------------------------------------" -ForegroundColor Gray

Write-Host "`n`nMethod 2: Using explicit Java properties" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

$output2 = java `
    -DJIRA_BASE_PATH="https://vospr.atlassian.net" `
    -DJIRA_EMAIL="andrey_popov@epam.com" `
    -DJIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF" `
    -DJIRA_AUTH_TYPE="basic" `
    -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" `
    mcp jira_get_my_profile 2>&1

Write-Host $output2
Write-Host "----------------------------------------" -ForegroundColor Gray

Write-Host "`n`nChecking dmtools.env format:" -ForegroundColor Yellow
Write-Host "First 10 lines of dmtools.env:" -ForegroundColor Gray
Get-Content "dmtools.env" -Head 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

Write-Host "`n`nLooking for JIRA_API_TOKEN line:" -ForegroundColor Yellow
$jiraTokenLine = Get-Content "dmtools.env" | Select-String "JIRA_API_TOKEN"
Write-Host "  $jiraTokenLine" -ForegroundColor Gray

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

