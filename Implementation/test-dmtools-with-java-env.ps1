# Test DMTools with Java system properties
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DMTOOLS TEST WITH JAVA PROPERTIES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd "c:\Users\AndreyPopov\dmtools"

$jiraBasePath = "https://vospr.atlassian.net"
$jiraEmail = "andrey_popov@epam.com"
$jiraToken = "ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF"
$jiraAuthType = "basic"

Write-Host "Testing with Java system properties..." -ForegroundColor Yellow
Write-Host "This bypasses PowerShell environment variables" -ForegroundColor Gray
Write-Host ""

$result = java `
    -DJIRA_BASE_PATH="$jiraBasePath" `
    -DJIRA_EMAIL="$jiraEmail" `
    -DJIRA_API_TOKEN="$jiraToken" `
    -DJIRA_AUTH_TYPE="$jiraAuthType" `
    -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" `
    mcp jira_get_my_profile 2>&1 | Out-String

if ($result -match '"accountId"') {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "SUCCESS! DMTools Connected to Jira" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    $jsonStart = $result.IndexOf('{"')
    if ($jsonStart -ge 0) {
        $jsonPart = $result.Substring($jsonStart)
        $jsonResponse = $jsonPart | ConvertFrom-Json
        
        Write-Host "Display Name: $($jsonResponse.displayName)" -ForegroundColor White
        Write-Host "Email: $($jsonResponse.emailAddress)" -ForegroundColor White
        Write-Host "Account ID: $($jsonResponse.accountId)" -ForegroundColor White
        
        $jsonResponse.accountId | Out-File "YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
    }
    
    Write-Host "`n✅ SOLUTION FOUND: Use Java system properties (-D flags)" -ForegroundColor Green
    
} elseif ($result -match '401') {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "STILL FAILED with Java properties" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    Write-Host "Checking if dmtools.env format is the issue..." -ForegroundColor Yellow
    
} else {
    Write-Host "`nResult:" -ForegroundColor Yellow
    Write-Host $result
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

