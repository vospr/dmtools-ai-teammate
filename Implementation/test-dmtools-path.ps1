# ========================================
# Test dmtools PATH Configuration
# ========================================
# This script reloads PATH and tests if dmtools command works
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DMTOOLS PATH CONFIGURATION TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check current PATH
Write-Host "[1/4] Checking current PATH..." -ForegroundColor Yellow
$currentPath = $env:PATH -split ';'
$dmtoolsInPath = $currentPath | Where-Object { $_ -like '*dmtools*' }

if ($dmtoolsInPath) {
    Write-Host "   ✅ Found in current session PATH:" -ForegroundColor Green
    $dmtoolsInPath | ForEach-Object { Write-Host "      $_" -ForegroundColor Cyan }
} else {
    Write-Host "   ⚠️  NOT in current session PATH (will reload)" -ForegroundColor Yellow
}

# Step 2: Reload PATH from User environment variables
Write-Host "`n[2/4] Reloading PATH from User environment variables..." -ForegroundColor Yellow
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$systemPath = [Environment]::GetEnvironmentVariable("Path", "Process")

# Combine all PATH sources (User + Machine + System)
$reloadedPath = ($userPath, $machinePath, $systemPath) -join ';'
$env:PATH = $reloadedPath

Write-Host "   ✅ PATH reloaded" -ForegroundColor Green

# Step 3: Verify dmtools is now in PATH
Write-Host "`n[3/4] Verifying dmtools in reloaded PATH..." -ForegroundColor Yellow
$reloadedPathEntries = $env:PATH -split ';'
$dmtoolsInReloadedPath = $reloadedPathEntries | Where-Object { $_ -like '*dmtools*' }

if ($dmtoolsInReloadedPath) {
    Write-Host "   ✅ Found in reloaded PATH:" -ForegroundColor Green
    $dmtoolsInReloadedPath | ForEach-Object { Write-Host "      $_" -ForegroundColor Cyan }
} else {
    Write-Host "   ❌ NOT found in reloaded PATH" -ForegroundColor Red
    Write-Host "   Expected: C:\Users\AndreyPopov\.dmtools\bin" -ForegroundColor Yellow
    Write-Host "`n   Please run Step 2.4 to add dmtools to PATH" -ForegroundColor Yellow
    exit 1
}

# Step 4: Test dmtools command
Write-Host "`n[4/4] Testing dmtools command..." -ForegroundColor Yellow

# Test 1: Check if command is discoverable
Write-Host "   Testing command discovery..." -ForegroundColor Gray
$dmtoolsPath = where.exe dmtools 2>&1
if ($LASTEXITCODE -eq 0 -and $dmtoolsPath) {
    Write-Host "   ✅ Command found: $dmtoolsPath" -ForegroundColor Green
} else {
    Write-Host "   ❌ Command NOT found" -ForegroundColor Red
    exit 1
}

# Test 2: Try to run dmtools --version
Write-Host "   Testing 'dmtools --version'..." -ForegroundColor Gray
try {
    $versionOutput = & dmtools --version 2>&1 | Out-String
    if ($versionOutput -match 'DMTools|version') {
        Write-Host "   ✅ Command executed successfully!" -ForegroundColor Green
        Write-Host "`n   Output:" -ForegroundColor Cyan
        Write-Host $versionOutput -ForegroundColor White
    } else {
        Write-Host "   ⚠️  Command executed but output unexpected:" -ForegroundColor Yellow
        Write-Host $versionOutput -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Command execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ PATH CONFIGURATION TEST PASSED" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "The dmtools command is now working in this PowerShell session!" -ForegroundColor Green
Write-Host "You can use 'dmtools --version' or 'dmtools list' to test further.`n" -ForegroundColor Gray
