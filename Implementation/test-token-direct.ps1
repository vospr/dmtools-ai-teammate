# Direct Token Test with curl
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DIRECT JIRA TOKEN TEST (CURL)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$email = "andrey_popov@epam.com"
$token = "ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF"
$url = "https://vospr.atlassian.net/rest/api/3/myself"

Write-Host "Testing credentials:" -ForegroundColor Yellow
Write-Host "  Email: $email" -ForegroundColor Gray
Write-Host "  URL: $url" -ForegroundColor Gray
Write-Host "  Token: $($token.Substring(0,20))..." -ForegroundColor Gray
Write-Host ""

# Create base64 auth header
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${email}:${token}"))

Write-Host "Testing with curl..." -ForegroundColor Yellow

try {
    $response = curl.exe -s -H "Authorization: Basic $base64Auth" -H "Accept: application/json" $url 2>&1
    
    if ($response -match '"accountId"') {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "SUCCESS! Token is VALID" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        
        $jsonResponse = $response | ConvertFrom-Json
        Write-Host "Display Name: $($jsonResponse.displayName)" -ForegroundColor White
        Write-Host "Email: $($jsonResponse.emailAddress)" -ForegroundColor White
        Write-Host "Account ID: $($jsonResponse.accountId)" -ForegroundColor White
        
        # Save account ID
        $jsonResponse.accountId | Out-File "YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
        
        Write-Host "`n✅ The token works with direct curl" -ForegroundColor Green
        Write-Host "⚠️ But fails with DMTools - this suggests DMTools config issue" -ForegroundColor Yellow
        
    } elseif ($response -match '401') {
        Write-Host "`n========================================" -ForegroundColor Red
        Write-Host "FAILED: Token is INVALID or EXPIRED" -ForegroundColor Red
        Write-Host "========================================`n" -ForegroundColor Red
        Write-Host "Please regenerate token at:" -ForegroundColor Yellow
        Write-Host "https://id.atlassian.com/manage-profile/security/api-tokens" -ForegroundColor Cyan
        
    } else {
        Write-Host "`nResponse:" -ForegroundColor Yellow
        Write-Host $response
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

