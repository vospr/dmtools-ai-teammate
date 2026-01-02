# Continue DMTools Setup After Java Installation

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFYING JAVA INSTALLATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Refresh environment variables
$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Test Java
Write-Host "Testing Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1
    Write-Host "SUCCESS: Java is installed!" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor Cyan
    Write-Host ""
    
    # Now build dmtools
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "BUILDING DMTOOLS" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Navigating to dmtools directory..." -ForegroundColor Yellow
    cd "c:\Users\AndreyPopov\dmtools"
    
    Write-Host "Running dmtools installation script..." -ForegroundColor Yellow
    Write-Host "This may take 3-5 minutes...`n" -ForegroundColor Yellow
    
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "TESTING DMTOOLS" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Add dmtools to PATH for this session
    $env:PATH += ";c:\Users\AndreyPopov\dmtools"
    
    # Test dmtools
    Write-Host "Testing dmtools CLI..." -ForegroundColor Yellow
    dmtools --version
    
    Write-Host "`nSUCCESS: dmtools is ready!" -ForegroundColor Green
    Write-Host "`nNow running credentials test...`n" -ForegroundColor Cyan
    
    # Run credentials test
    cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
    powershell -ExecutionPolicy Bypass -File .\test-credentials-simple.ps1
    
} catch {
    Write-Host "ERROR: Java installation verification failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPlease ensure:" -ForegroundColor Yellow
    Write-Host "1. Java installer completed successfully" -ForegroundColor White
    Write-Host "2. You selected 'Add to PATH' and 'Set JAVA_HOME'" -ForegroundColor White
    Write-Host "3. You restarted PowerShell after installation`n" -ForegroundColor White
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

