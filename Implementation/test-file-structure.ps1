# ========================================
# Test File Structure (Step 5)
# ========================================
# This script validates that all required files and directories exist
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FILE STRUCTURE VALIDATION TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$testResults = @()

# Source Directory
$sourceDir = "c:\Users\AndreyPopov\dmtools"
$installDir = "C:\Users\AndreyPopov\.dmtools"

# Test 1: Source Directory Exists
Write-Host "[1/6] Checking source directory..." -ForegroundColor Yellow
if (Test-Path $sourceDir) {
    Write-Host "   ✅ Source directory exists: $sourceDir" -ForegroundColor Green
    $testResults += @{Test="Source Directory"; Status="PASS"; Details=$sourceDir}
} else {
    Write-Host "   ❌ Source directory NOT found: $sourceDir" -ForegroundColor Red
    $testResults += @{Test="Source Directory"; Status="FAIL"; Details="Not found"}
}

# Test 2: Key Source Directories
Write-Host "`n[2/6] Checking key source directories..." -ForegroundColor Yellow
$requiredDirs = @(
    "dmtools-server",
    "dmtools-core",
    "dmtools-automation",
    "dmtools-mcp-annotations",
    "dmtools-annotation-processor",
    "build",
    "gradle"
)

$foundDirs = 0
foreach ($dir in $requiredDirs) {
    $dirPath = Join-Path $sourceDir $dir
    if (Test-Path $dirPath) {
        Write-Host "   ✅ $dir/" -ForegroundColor Green
        $foundDirs++
    } else {
        Write-Host "   ⚠️  $dir/ (not found)" -ForegroundColor Yellow
    }
}

if ($foundDirs -eq $requiredDirs.Count) {
    Write-Host "   ✅ All required directories found!" -ForegroundColor Green
    $testResults += @{Test="Source Directories"; Status="PASS"; Details="$foundDirs/$($requiredDirs.Count) found"}
} else {
    Write-Host "   ⚠️  Found $foundDirs/$($requiredDirs.Count) required directories" -ForegroundColor Yellow
    $testResults += @{Test="Source Directories"; Status="PARTIAL"; Details="$foundDirs/$($requiredDirs.Count) found"}
}

# Test 3: Key Source Files
Write-Host "`n[3/6] Checking key source files..." -ForegroundColor Yellow
$requiredFiles = @(
    "build.gradle",
    "settings.gradle",
    "gradlew.bat",
    "dmtools.env",
    "dmtools.env.example",
    "README.md"
)

$foundFiles = 0
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $sourceDir $file
    if (Test-Path $filePath) {
        $size = (Get-Item $filePath).Length
        Write-Host "   ✅ $file ($([math]::Round($size/1KB, 1)) KB)" -ForegroundColor Green
        $foundFiles++
    } else {
        Write-Host "   ❌ $file (not found)" -ForegroundColor Red
    }
}

if ($foundFiles -eq $requiredFiles.Count) {
    Write-Host "   ✅ All required files found!" -ForegroundColor Green
    $testResults += @{Test="Source Files"; Status="PASS"; Details="$foundFiles/$($requiredFiles.Count) found"}
} else {
    Write-Host "   ⚠️  Found $foundFiles/$($requiredFiles.Count) required files" -ForegroundColor Yellow
    $testResults += @{Test="Source Files"; Status="PARTIAL"; Details="$foundFiles/$($requiredFiles.Count) found"}
}

# Test 4: Installation Directory
Write-Host "`n[4/6] Checking installation directory..." -ForegroundColor Yellow
if (Test-Path $installDir) {
    Write-Host "   ✅ Installation directory exists: $installDir" -ForegroundColor Green
    $testResults += @{Test="Installation Directory"; Status="PASS"; Details=$installDir}
} else {
    Write-Host "   ❌ Installation directory NOT found: $installDir" -ForegroundColor Red
    $testResults += @{Test="Installation Directory"; Status="FAIL"; Details="Not found"}
}

# Test 5: Installation Files
Write-Host "`n[5/6] Checking installation files..." -ForegroundColor Yellow
$installFiles = @(
    @{Path="dmtools.jar"; MinSizeMB=70; Description="Main JAR file"},
    @{Path="bin\dmtools.cmd"; MinSizeKB=1; Description="Command wrapper"}
)

$foundInstallFiles = 0
foreach ($file in $installFiles) {
    $filePath = Join-Path $installDir $file.Path
    if (Test-Path $filePath) {
        $item = Get-Item $filePath
        $sizeMB = [math]::Round($item.Length / 1MB, 2)
        $sizeKB = [math]::Round($item.Length / 1KB, 1)
        
        if ($file.MinSizeMB) {
            if ($sizeMB -ge $file.MinSizeMB) {
                Write-Host "   ✅ $($file.Path) ($sizeMB MB) - $($file.Description)" -ForegroundColor Green
                $foundInstallFiles++
            } else {
                Write-Host "   ⚠️  $($file.Path) ($sizeMB MB) - Size seems small" -ForegroundColor Yellow
            }
        } else {
            if ($sizeKB -ge $file.MinSizeKB) {
                Write-Host "   ✅ $($file.Path) ($sizeKB KB) - $($file.Description)" -ForegroundColor Green
                $foundInstallFiles++
            } else {
                Write-Host "   ⚠️  $($file.Path) ($sizeKB KB) - Size seems small" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "   ❌ $($file.Path) (not found)" -ForegroundColor Red
    }
}

if ($foundInstallFiles -eq $installFiles.Count) {
    Write-Host "   ✅ All installation files found!" -ForegroundColor Green
    $testResults += @{Test="Installation Files"; Status="PASS"; Details="$foundInstallFiles/$($installFiles.Count) found"}
} else {
    Write-Host "   ⚠️  Found $foundInstallFiles/$($installFiles.Count) installation files" -ForegroundColor Yellow
    $testResults += @{Test="Installation Files"; Status="PARTIAL"; Details="$foundInstallFiles/$($installFiles.Count) found"}
}

# Test 6: Configuration File
Write-Host "`n[6/6] Checking configuration file..." -ForegroundColor Yellow
$configFile = Join-Path $sourceDir "dmtools.env"
if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    $hasJira = $content -match 'JIRA_'
    $hasGemini = $content -match 'GEMINI_'
    $hasCredentials = $hasJira -and $hasGemini
    
    if ($hasCredentials) {
        Write-Host "   ✅ dmtools.env exists and contains credentials" -ForegroundColor Green
        $testResults += @{Test="Configuration File"; Status="PASS"; Details="Contains credentials"}
    } else {
        Write-Host "   ⚠️  dmtools.env exists but may be missing credentials" -ForegroundColor Yellow
        $testResults += @{Test="Configuration File"; Status="PARTIAL"; Details="File exists but credentials incomplete"}
    }
} else {
    Write-Host "   ❌ dmtools.env NOT found" -ForegroundColor Red
    Write-Host "   Expected location: $configFile" -ForegroundColor Yellow
    $testResults += @{Test="Configuration File"; Status="FAIL"; Details="Not found"}
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

foreach ($result in $testResults) {
    $statusColor = switch ($result.Status) {
        "PASS" { "Green" }
        "PARTIAL" { "Yellow" }
        "FAIL" { "Red" }
        default { "Gray" }
    }
    Write-Host "$($result.Test): " -NoNewline -ForegroundColor White
    Write-Host $result.Status -ForegroundColor $statusColor -NoNewline
    Write-Host " - $($result.Details)" -ForegroundColor Gray
}

$allPassed = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$totalTests = $testResults.Count

Write-Host "`nOverall: $allPassed/$totalTests tests passed" -ForegroundColor $(if($allPassed -eq $totalTests){"Green"}elseif($allPassed -gt 0){"Yellow"}else{"Red"})

if ($allPassed -eq $totalTests) {
    Write-Host "`n✅ File structure is correct!" -ForegroundColor Green
    Write-Host "All required files and directories are in place.`n" -ForegroundColor Gray
} elseif ($allPassed -gt 0) {
    Write-Host "`n⚠️  File structure is mostly correct. Check details above.`n" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ File structure is incomplete. Please complete installation steps.`n" -ForegroundColor Red
}
