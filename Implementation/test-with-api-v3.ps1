# Test with API v3 in base path
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST WITH API V3 PATH WORKAROUND" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd "c:\Users\AndreyPopov\dmtools"

Write-Host "Trying workaround: Include /rest/api/3 in JIRA_BASE_PATH" -ForegroundColor Yellow
Write-Host ""

# Try with /rest/api/3 in base path
$output1 = java `
    -DJIRA_BASE_PATH="https://vospr.atlassian.net/rest/api/3" `
    -DJIRA_EMAIL="andrey_popov@epam.com" `
    -DJIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF" `
    -DJIRA_AUTH_TYPE="basic" `
    -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" `
    mcp jira_get_my_profile 2>&1 | Out-String

Write-Host "Result with /rest/api/3:" -ForegroundColor Cyan
if ($output1 -match '"accountId"') {
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    $jsonStart = $output1.IndexOf('{"')
    if ($jsonStart -ge 0) {
        $jsonPart = $output1.Substring($jsonStart)
        $jsonResponse = $jsonPart | ConvertFrom-Json
        Write-Host "Name: $($jsonResponse.displayName)" -ForegroundColor White
        Write-Host "Email: $($jsonResponse.emailAddress)" -ForegroundColor White
    }
} else {
    Write-Host "❌ Failed" -ForegroundColor Red
    Write-Host $output1 | Select-String "error|401|message"
}

Write-Host "`n`nTrying with /rest/api/2:" -ForegroundColor Yellow
$output2 = java `
    -DJIRA_BASE_PATH="https://vospr.atlassian.net/rest/api/2" `
    -DJIRA_EMAIL="andrey_popov@epam.com" `
    -DJIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF" `
    -DJIRA_AUTH_TYPE="basic" `
    -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" `
    mcp jira_get_my_profile 2>&1 | Out-String

Write-Host "`nResult with /rest/api/2:" -ForegroundColor Cyan
if ($output2 -match '"accountId"') {
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    $jsonStart = $output2.IndexOf('{"')
    if ($jsonStart -ge 0) {
        $jsonPart = $output2.Substring($jsonStart)
        $jsonResponse = $jsonPart | ConvertFrom-Json
        Write-Host "Name: $($jsonResponse.displayName)" -ForegroundColor White
        Write-Host "Email: $($jsonResponse.emailAddress)" -ForegroundColor White
    }
} else {
    Write-Host "❌ Failed" -ForegroundColor Red
    Write-Host $output2 | Select-String "error|401|message"
}

Write-Host "`n`nIf one worked, update dmtools.env with:" -ForegroundColor Cyan
Write-Host "JIRA_BASE_PATH=https://vospr.atlassian.net/rest/api/3" -ForegroundColor Yellow
Write-Host "or" -ForegroundColor Gray
Write-Host "JIRA_BASE_PATH=https://vospr.atlassian.net/rest/api/2" -ForegroundColor Yellow

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

