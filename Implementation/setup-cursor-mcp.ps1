# ========================================
# Setup Cursor MCP Configuration for dmtools
# ========================================

$mcpConfigPath = "$env:USERPROFILE\.cursor\mcp.json"
$dmtoolsJar = "C:\Users\AndreyPopov\.dmtools\dmtools.jar"

Write-Host "Setting up Cursor MCP configuration for dmtools...`n" -ForegroundColor Cyan

# Ensure .cursor directory exists
$cursorDir = "$env:USERPROFILE\.cursor"
if (-not (Test-Path $cursorDir)) {
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
    Write-Host "Created .cursor directory" -ForegroundColor Green
}

# Check if mcp.json exists
$existingConfig = $null
if (Test-Path $mcpConfigPath) {
    Write-Host "Found existing mcp.json, reading..." -ForegroundColor Yellow
    try {
        $jsonContent = Get-Content $mcpConfigPath -Raw
        $existingConfig = $jsonContent | ConvertFrom-Json
        Write-Host "Existing configuration loaded" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not parse existing mcp.json" -ForegroundColor Yellow
    }
}

# Create dmtools MCP server configuration
# Use PowerShell wrapper to handle JSON-RPC properly
$wrapperPath = "C:\Users\AndreyPopov\.dmtools\bin\dmtools-mcp-wrapper.ps1"
$dmtoolsServerConfig = @{
    command = "powershell"
    args = @(
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        $wrapperPath
    )
    env = @{
        DMTOOLS_ENV = "c:\Users\AndreyPopov\dmtools\dmtools.env"
    }
}

# Build final configuration
$mcpConfig = @{
    mcpServers = @{}
}

# Add existing servers
if ($existingConfig -and $existingConfig.mcpServers) {
    $existingConfig.mcpServers.PSObject.Properties | ForEach-Object {
        $mcpConfig.mcpServers[$_.Name] = $_.Value
    }
}

# Add or update dmtools
$mcpConfig.mcpServers.dmtools = $dmtoolsServerConfig

# Save configuration
$jsonOutput = $mcpConfig | ConvertTo-Json -Depth 10
$jsonOutput | Out-File $mcpConfigPath -Encoding UTF8 -Force

Write-Host "`n✅ MCP configuration saved to: $mcpConfigPath" -ForegroundColor Green
Write-Host "`nConfiguration:" -ForegroundColor Cyan
Write-Host $jsonOutput -ForegroundColor Gray

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Restart Cursor IDE" -ForegroundColor White
Write-Host "2. Check Settings → Tools & Integrations → MCP Servers" -ForegroundColor White
Write-Host "3. Verify 'dmtools' shows as 'Connected'`n" -ForegroundColor White
