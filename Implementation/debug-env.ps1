# Debug Environment Variables
Write-Host "Debugging environment variable loading..." -ForegroundColor Cyan
Write-Host ""

cd "c:\Users\AndreyPopov\dmtools"

# Load environment
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

Write-Host "Checking Jira environment variables:" -ForegroundColor Yellow
Write-Host "JIRA_BASE_PATH: $env:JIRA_BASE_PATH" -ForegroundColor White
Write-Host "JIRA_EMAIL: $env:JIRA_EMAIL" -ForegroundColor White
Write-Host "JIRA_AUTH_TYPE: $env:JIRA_AUTH_TYPE" -ForegroundColor White

$tokenLength = if ($env:JIRA_API_TOKEN) { $env:JIRA_API_TOKEN.Length } else { 0 }
Write-Host "JIRA_API_TOKEN length: $tokenLength characters" -ForegroundColor White

if ($tokenLength -eq 0) {
    Write-Host "ERROR: JIRA_API_TOKEN is NOT set!" -ForegroundColor Red
} elseif ($tokenLength -lt 50) {
    Write-Host "WARNING: Token seems too short (should be ~150 characters)" -ForegroundColor Yellow
} else {
    Write-Host "Token first 20 chars: $($env:JIRA_API_TOKEN.Substring(0,20))..." -ForegroundColor Green
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

