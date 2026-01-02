# Test if Java can see environment variables
Write-Host "Testing if Java sees environment variables..." -ForegroundColor Cyan

cd "c:\Users\AndreyPopov\dmtools"

# Load from dmtools.env
Get-Content "dmtools.env" | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -match '='
} | ForEach-Object {
    $parts = $_ -split '=', 2
    if ($parts.Length -eq 2) {
        [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
    }
}

Write-Host "`nPowerShell sees:" -ForegroundColor Yellow
Write-Host "  JIRA_EMAIL: $env:JIRA_EMAIL" -ForegroundColor Gray
Write-Host "  JIRA_API_TOKEN length: $($env:JIRA_API_TOKEN.Length)" -ForegroundColor Gray

Write-Host "`nTesting with System Properties (bypassing env vars):" -ForegroundColor Yellow
$result = java `
    -DJIRA_EMAIL="andrey_popov@epam.com" `
    -DJIRA_API_TOKEN="ATATT3xFfGF08ZskLytXpxAV3MVNdo0pC50_S-zken_QKGnhiQsaUvlgvGzV0lozxEsVsr02zJR8pZCc8bva9mUgUBqHEu2Q1zzan5bmdLfRWnVEq_dfuD9VKwDcvvW5JXSSPhW6WBFyN1r52TFCvKuTbFhZR2n-pNQkoiPIEILTXZ4wn3FBuOg=00EA90FF" `
    -DJIRA_BASE_PATH="https://vospr.atlassian.net" `
    -DJIRA_AUTH_TYPE="basic" `
    -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" `
    mcp jira_get_my_profile 2>&1 | Out-String

if ($result -match '"accountId"') {
    Write-Host "SUCCESS with System Properties!" -ForegroundColor Green
} else {
    Write-Host "FAILED with System Properties" -ForegroundColor Red
    if ($result -match 'https://[^/]+/rest/api/([^/]+)/') {
        Write-Host "API Version: $($matches[1])" -ForegroundColor Gray
    }
}

Write-Host "`nPress any key..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

