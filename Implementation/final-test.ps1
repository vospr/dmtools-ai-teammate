# Final comprehensive test
Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "FINAL JIRA API TEST" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# Check JAR timestamp
$jar = Get-Item "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
Write-Host "JAR Info:" -ForegroundColor Yellow
Write-Host "  Last Modified: $($jar.LastWriteTime)" -ForegroundColor Gray
Write-Host "  Size: $([math]::Round($jar.Length/1MB, 2)) MB" -ForegroundColor Gray
Write-Host ""

cd "c:\Users\AndreyPopov\dmtools"

Write-Host "Loading environment..." -ForegroundColor Yellow
Get-Content "dmtools.env" | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -match '='
} | ForEach-Object {
    $parts = $_ -split '=', 2
    if ($parts.Length -eq 2) {
        [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
    }
}
Write-Host "Environment loaded`n" -ForegroundColor Green

Write-Host "Testing Jira API..." -ForegroundColor Yellow
Write-Host "(This may take 10-30 seconds)...`n" -ForegroundColor Gray

$result = java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile 2>&1 | Out-String

# Check what URL was actually called
if ($result -match 'https://[^/]+/rest/api/([^/]+)/') {
    $apiVersion = $matches[1]
    Write-Host "API Version Used: $apiVersion" -ForegroundColor $(if($apiVersion -eq '3'){'Green'}elseif($apiVersion -eq 'latest'){'Red'}else{'Yellow'})
}

if ($result -match '"accountId"') {
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "SUCCESS! JIRA CONNECTED!" -ForegroundColor Green
    Write-Host "==================================`n" -ForegroundColor Green
    
    $jsonStart = $result.IndexOf('{"')
    if ($jsonStart -ge 0) {
        $jsonPart = $result.Substring($jsonStart)
        $jsonResponse = $jsonPart | ConvertFrom-Json
        
        Write-Host "Your Jira Profile:" -ForegroundColor Cyan
        Write-Host "  Name: $($jsonResponse.displayName)" -ForegroundColor White
        Write-Host "  Email: $($jsonResponse.emailAddress)" -ForegroundColor White
        Write-Host "  Account ID: $($jsonResponse.accountId)" -ForegroundColor White
        
        $jsonResponse.accountId | Out-File "YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
        Write-Host "`nAccount ID saved!`n" -ForegroundColor Green
    }
} else {
    Write-Host "`n==================================" -ForegroundColor Red
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "==================================`n" -ForegroundColor Red
    
    if ($result -match '"message"\s*:\s*"([^"]+)"') {
        Write-Host "Error: $($matches[1])" -ForegroundColor Yellow
    }
    
    Write-Host "`nFull output saved to: test-failure.log" -ForegroundColor Gray
    $result | Out-File "test-failure.log" -Encoding UTF8
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

