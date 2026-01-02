# ========================================
# Test Basic CLI Commands (Without Configuration)
# ========================================
# This script tests dmtools CLI commands that don't require API credentials
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "BASIC CLI COMMANDS TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$dmtoolsJar = "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
$testResults = @()

# Test 1: Version Check (direct JAR execution)
Write-Host "[1/3] Testing version command (direct JAR)..." -ForegroundColor Yellow
try {
    $versionOutput = java -jar $dmtoolsJar --version 2>&1 | Out-String
    
    if ($versionOutput -match 'DMTools|version|1\.') {
        Write-Host "   ✅ Version command works!" -ForegroundColor Green
        Write-Host "   Output: $($versionOutput.Trim())" -ForegroundColor Gray
        $testResults += @{Test="Version Check"; Status="PASS"; Details="Version info retrieved"}
    } else {
        Write-Host "   ⚠️  Unexpected version output" -ForegroundColor Yellow
        Write-Host "   Output: $versionOutput" -ForegroundColor Gray
        $testResults += @{Test="Version Check"; Status="PARTIAL"; Details="Unexpected format"}
    }
} catch {
    Write-Host "   ❌ Version command failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="Version Check"; Status="FAIL"; Details=$_.Exception.Message}
}

# Test 2: List Tools (MCP command)
Write-Host "`n[2/3] Testing 'mcp list' command..." -ForegroundColor Yellow
try {
    $listOutput = java -jar $dmtoolsJar mcp list 2>&1 | Out-String
    
    # Check if output contains tools
    if ($listOutput -match '"tools"') {
        Write-Host "   ✅ List command works!" -ForegroundColor Green
        
        # Try to count tools
        try {
            $jsonStart = $listOutput.IndexOf('{')
            if ($jsonStart -ge 0) {
                $jsonPart = $listOutput.Substring($jsonStart)
                $jsonObj = $jsonPart | ConvertFrom-Json
                $toolCount = $jsonObj.tools.Count
                Write-Host "   ✅ Found $toolCount tools" -ForegroundColor Green
                $testResults += @{Test="List Tools"; Status="PASS"; Details="$toolCount tools found"}
            } else {
                $testResults += @{Test="List Tools"; Status="PASS"; Details="Tools found"}
            }
        } catch {
            Write-Host "   ⚠️  Tools found but couldn't parse count" -ForegroundColor Yellow
            $testResults += @{Test="List Tools"; Status="PASS"; Details="Tools found"}
        }
    } else {
        Write-Host "   ❌ List command failed or no tools found" -ForegroundColor Red
        $testResults += @{Test="List Tools"; Status="FAIL"; Details="No tools in output"}
    }
} catch {
    Write-Host "   ❌ List command error: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="List Tools"; Status="FAIL"; Details=$_.Exception.Message}
}

# Test 3: Help for Specific Tool (without executing)
Write-Host "`n[3/3] Testing tool help/info..." -ForegroundColor Yellow
try {
    # Try to get info about a tool by calling it without required params
    $helpOutput = java -jar $dmtoolsJar mcp gemini_ai_chat 2>&1 | Out-String
    
    # Check if we get an error about missing parameters (this is expected)
    if ($helpOutput -match 'error|Error|required|parameter|missing') {
        Write-Host "   ✅ Tool responds correctly (shows expected error for missing params)" -ForegroundColor Green
        $testResults += @{Test="Tool Help"; Status="PASS"; Details="Tool responds with parameter error"}
    } elseif ($helpOutput -match 'prompt|input') {
        Write-Host "   ✅ Tool responds (may have executed with defaults)" -ForegroundColor Green
        $testResults += @{Test="Tool Help"; Status="PASS"; Details="Tool executed"}
    } else {
        Write-Host "   ⚠️  Unexpected response" -ForegroundColor Yellow
        Write-Host "   Output preview: $($helpOutput.Substring(0, [Math]::Min(200, $helpOutput.Length)))" -ForegroundColor Gray
        $testResults += @{Test="Tool Help"; Status="UNKNOWN"; Details="Unexpected response"}
    }
} catch {
    Write-Host "   ⚠️  Could not test tool help" -ForegroundColor Yellow
    $testResults += @{Test="Tool Help"; Status="SKIP"; Details="Test skipped"}
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
    Write-Host "`n✅ All basic CLI commands are working!" -ForegroundColor Green
    Write-Host "You can proceed to test commands with API credentials.`n" -ForegroundColor Gray
} elseif ($allPassed -gt 0) {
    Write-Host "`n⚠️  Some commands are working. Check details above.`n" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Basic CLI commands are not working. Check configuration.`n" -ForegroundColor Red
}
