# ========================================
# Test and Configure Cursor MCP Integration
# ========================================
# This script validates and configures dmtools MCP server for Cursor IDE
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CURSOR MCP CONFIGURATION TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$mcpConfigPath = "$env:USERPROFILE\.cursor\mcp.json"
$dmtoolsJar = "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
$dmtoolsCmd = "C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd"

# Test 1: Check if mcp.json exists
Write-Host "[1/5] Checking for Cursor MCP configuration..." -ForegroundColor Yellow
if (Test-Path $mcpConfigPath) {
    Write-Host "   ✅ mcp.json found at: $mcpConfigPath" -ForegroundColor Green
    try {
        $config = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
        Write-Host "   ✅ Valid JSON configuration" -ForegroundColor Green
        
        # Check if dmtools is configured
        if ($config.PSObject.Properties.Name -contains "dmtools") {
            Write-Host "   ✅ dmtools MCP server is configured" -ForegroundColor Green
            Write-Host "   Configuration:" -ForegroundColor Cyan
            $config.dmtools | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
        } else {
            Write-Host "   ⚠️  dmtools MCP server NOT configured" -ForegroundColor Yellow
            Write-Host "   Current servers: $($config.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ❌ Invalid JSON in mcp.json: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ mcp.json NOT found at: $mcpConfigPath" -ForegroundColor Red
    Write-Host "   Will create it..." -ForegroundColor Yellow
}

# Test 2: Check dmtools installation
Write-Host "`n[2/5] Checking dmtools installation..." -ForegroundColor Yellow
if (Test-Path $dmtoolsJar) {
    $jarSize = (Get-Item $dmtoolsJar).Length / 1MB
    Write-Host "   ✅ dmtools.jar found ($([math]::Round($jarSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "   ❌ dmtools.jar NOT found" -ForegroundColor Red
}

if (Test-Path $dmtoolsCmd) {
    Write-Host "   ✅ dmtools.cmd wrapper found" -ForegroundColor Green
} else {
    Write-Host "   ❌ dmtools.cmd wrapper NOT found" -ForegroundColor Red
}

# Test 3: Test MCP list command
Write-Host "`n[3/5] Testing MCP list command..." -ForegroundColor Yellow
try {
    $output = java -jar $dmtoolsJar mcp list 2>&1 | Out-String
    if ($output -match '"tools"') {
        Write-Host "   ✅ MCP list command works" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  MCP list command returned unexpected output" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ MCP list command failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Create/Update MCP configuration
Write-Host "`n[4/5] Creating/Updating MCP configuration..." -ForegroundColor Yellow

# Ensure .cursor directory exists
$cursorDir = "$env:USERPROFILE\.cursor"
if (-not (Test-Path $cursorDir)) {
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
    Write-Host "   ✅ Created .cursor directory" -ForegroundColor Green
}

# Create MCP configuration
$mcpConfig = @{
    mcpServers = @{
        dmtools = @{
            command = "java"
            args = @(
                "-jar",
                $dmtoolsJar,
                "mcp"
            )
            env = @{
                DMTOOLS_ENV = "c:\Users\AndreyPopov\dmtools\dmtools.env"
            }
        }
    }
}

# If mcp.json exists, merge with existing config
if (Test-Path $mcpConfigPath) {
    try {
        $existingConfig = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
        
        # Preserve existing servers
        if ($existingConfig.mcpServers) {
            $existingServers = @{}
            $existingConfig.mcpServers.PSObject.Properties | ForEach-Object {
                $existingServers[$_.Name] = $_.Value
            }
            
            # Add dmtools if not already present
            if (-not $existingServers.dmtools) {
                $existingServers.dmtools = @{
                    command = "java"
                    args = @(
                        "-jar",
                        $dmtoolsJar,
                        "mcp"
                    )
                    env = @{
                        DMTOOLS_ENV = "c:\Users\AndreyPopov\dmtools\dmtools.env"
                    }
                }
            } else {
                Write-Host "   ℹ️  dmtools already configured, updating..." -ForegroundColor Cyan
                $existingServers.dmtools = @{
                    command = "java"
                    args = @(
                        "-jar",
                        $dmtoolsJar,
                        "mcp"
                    )
                    env = @{
                        DMTOOLS_ENV = "c:\Users\AndreyPopov\dmtools\dmtools.env"
                    }
                }
            }
            
            $mcpConfig.mcpServers = $existingServers
        }
    } catch {
        Write-Host "   ⚠️  Could not read existing config, creating new one" -ForegroundColor Yellow
    }
}

# Save configuration
try {
    $jsonConfig = $mcpConfig | ConvertTo-Json -Depth 10
    $jsonConfig | Out-File $mcpConfigPath -Encoding UTF8 -Force
    Write-Host "   ✅ MCP configuration saved to: $mcpConfigPath" -ForegroundColor Green
    Write-Host "`n   Configuration:" -ForegroundColor Cyan
    Write-Host $jsonConfig -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Failed to save configuration: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Verify configuration
Write-Host "`n[5/5] Verifying configuration..." -ForegroundColor Yellow
if (Test-Path $mcpConfigPath) {
    try {
        $verifyConfig = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
        if ($verifyConfig.mcpServers.dmtools) {
            Write-Host "   ✅ dmtools MCP server configured correctly" -ForegroundColor Green
            Write-Host "   Command: $($verifyConfig.mcpServers.dmtools.command) $($verifyConfig.mcpServers.dmtools.args -join ' ')" -ForegroundColor Gray
        } else {
            Write-Host "   ❌ dmtools not found in configuration" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Configuration verification failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Configuration file not found after creation" -ForegroundColor Red
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "MCP Configuration File: $mcpConfigPath" -ForegroundColor White
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Restart Cursor IDE to load the new MCP configuration" -ForegroundColor Gray
Write-Host "2. In Cursor, check Settings → Tools & Integrations → MCP Servers" -ForegroundColor Gray
Write-Host "3. Verify 'dmtools' appears in the list and shows as 'Connected'" -ForegroundColor Gray
Write-Host "4. Test by using '@dmtools' in Cursor chat or command palette" -ForegroundColor Gray
Write-Host ""
