# ========================================
# Test MCP Server Capabilities
# ========================================
# This script verifies that dmtools MCP server is working correctly
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "MCP SERVER CAPABILITIES TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$dmtoolsJar = "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
$testResults = @()

# Test 1: List all MCP tools
Write-Host "[1/4] Testing 'mcp list' command..." -ForegroundColor Yellow
try {
    $listOutput = java -jar $dmtoolsJar mcp list 2>&1 | Out-String
    
    # Check if output contains tools JSON
    if ($listOutput -match '"tools"') {
        Write-Host "   ✅ MCP list command works!" -ForegroundColor Green
        
        # Try to parse JSON and count tools
        try {
            $jsonStart = $listOutput.IndexOf('{')
            if ($jsonStart -ge 0) {
                $jsonPart = $listOutput.Substring($jsonStart)
                $jsonObj = $jsonPart | ConvertFrom-Json
                $toolCount = $jsonObj.tools.Count
                Write-Host "   ✅ Found $toolCount MCP tools" -ForegroundColor Green
                $testResults += @{Test="List Tools"; Status="PASS"; Details="$toolCount tools found"}
            } else {
                $testResults += @{Test="List Tools"; Status="PASS"; Details="Tools found (JSON parsing skipped)"}
            }
        } catch {
            Write-Host "   ⚠️  Tools found but JSON parsing failed (this is OK)" -ForegroundColor Yellow
            $testResults += @{Test="List Tools"; Status="PASS"; Details="Tools found"}
        }
    } else {
        Write-Host "   ❌ MCP list command failed or returned unexpected output" -ForegroundColor Red
        $testResults += @{Test="List Tools"; Status="FAIL"; Details="No tools found"}
    }
} catch {
    Write-Host "   ❌ Error executing MCP list: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="List Tools"; Status="FAIL"; Details=$_.Exception.Message}
}

# Test 2: Check for specific key tools
Write-Host "`n[2/4] Checking for key MCP tools..." -ForegroundColor Yellow
$keyTools = @(
    "jira_get_ticket",
    "jira_search_by_jql",
    "confluence_contents_by_urls",
    "gemini_ai_chat",
    "figma_get_screen_source"
)

$foundTools = 0
foreach ($tool in $keyTools) {
    try {
        $toolOutput = java -jar $dmtoolsJar mcp list 2>&1 | Out-String
        if ($toolOutput -match $tool) {
            Write-Host "   ✅ Found: $tool" -ForegroundColor Green
            $foundTools++
        } else {
            Write-Host "   ⚠️  Missing: $tool" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Error checking $tool" -ForegroundColor Red
    }
}

if ($foundTools -eq $keyTools.Count) {
    Write-Host "   ✅ All key tools found!" -ForegroundColor Green
    $testResults += @{Test="Key Tools"; Status="PASS"; Details="$foundTools/$($keyTools.Count) tools found"}
} else {
    Write-Host "   ⚠️  Found $foundTools/$($keyTools.Count) key tools" -ForegroundColor Yellow
    $testResults += @{Test="Key Tools"; Status="PARTIAL"; Details="$foundTools/$($keyTools.Count) tools found"}
}

# Test 3: Test tool help/info (if available)
Write-Host "`n[3/4] Testing tool information retrieval..." -ForegroundColor Yellow
try {
    # Try to get help for a specific tool
    $helpOutput = java -jar $dmtoolsJar mcp jira_get_ticket 2>&1 | Out-String
    
    if ($helpOutput -match 'error|Error|required|parameter') {
        Write-Host "   ✅ Tool responds (showing expected error for missing parameters)" -ForegroundColor Green
        $testResults += @{Test="Tool Execution"; Status="PASS"; Details="Tool responds correctly"}
    } else {
        Write-Host "   ⚠️  Unexpected response from tool" -ForegroundColor Yellow
        $testResults += @{Test="Tool Execution"; Status="UNKNOWN"; Details="Unexpected response"}
    }
} catch {
    Write-Host "   ⚠️  Could not test tool execution" -ForegroundColor Yellow
    $testResults += @{Test="Tool Execution"; Status="SKIP"; Details="Test skipped"}
}

# Test 4: Verify MCP protocol compliance
Write-Host "`n[4/4] Verifying MCP protocol compliance..." -ForegroundColor Yellow
try {
    $listOutput = java -jar $dmtoolsJar mcp list 2>&1 | Out-String
    
    $protocolChecks = @{
        "JSON format" = $listOutput -match '\{.*"tools".*\}'
        "Tools array" = $listOutput -match '"tools"\s*:\s*\['
        "Tool names" = $listOutput -match '"name"\s*:'
        "Tool descriptions" = $listOutput -match '"description"\s*:'
    }
    
    $passedChecks = ($protocolChecks.Values | Where-Object { $_ -eq $true }).Count
    $totalChecks = $protocolChecks.Count
    
    Write-Host "   Protocol checks: $passedChecks/$totalChecks passed" -ForegroundColor $(if($passedChecks -eq $totalChecks){"Green"}else{"Yellow"})
    
    foreach ($check in $protocolChecks.GetEnumerator()) {
        $status = if ($check.Value) { "✅" } else { "❌" }
        Write-Host "      $status $($check.Key)" -ForegroundColor $(if($check.Value){"Green"}else{"Red"})
    }
    
    $testResults += @{Test="MCP Protocol"; Status=if($passedChecks -eq $totalChecks){"PASS"}else{"PARTIAL"}; Details="$passedChecks/$totalChecks checks passed"}
} catch {
    Write-Host "   ❌ Error verifying protocol: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="MCP Protocol"; Status="FAIL"; Details=$_.Exception.Message}
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
    Write-Host "`n✅ MCP Server is working correctly!" -ForegroundColor Green
} elseif ($allPassed -gt 0) {
    Write-Host "`n⚠️  MCP Server is partially working. Check details above." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ MCP Server is not working. Check configuration." -ForegroundColor Red
}

Write-Host "`nFor manual testing, see the commands below:`n" -ForegroundColor Gray
