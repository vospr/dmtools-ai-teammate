@echo off
echo ========================================
echo Setting up Cursor MCP Configuration
echo ========================================
echo.

REM Create .cursor directory if it doesn't exist
if not exist "%USERPROFILE%\.cursor" (
    mkdir "%USERPROFILE%\.cursor"
    echo Created .cursor directory
)

REM Create mcp.json with dmtools configuration
echo Creating mcp.json configuration...
powershell -Command "$config = @{ mcpServers = @{ dmtools = @{ command = 'java'; args = @('-jar', 'C:\Users\AndreyPopov\.dmtools\dmtools.jar', 'mcp'); env = @{ DMTOOLS_ENV = 'c:\Users\AndreyPopov\dmtools\dmtools.env' } } } }; $config | ConvertTo-Json -Depth 10 | Out-File '%USERPROFILE%\.cursor\mcp.json' -Encoding UTF8"

if exist "%USERPROFILE%\.cursor\mcp.json" (
    echo.
    echo SUCCESS! MCP configuration created.
    echo Location: %USERPROFILE%\.cursor\mcp.json
    echo.
    echo Next Steps:
    echo 1. Restart Cursor IDE
    echo 2. Check Settings -^> Tools ^& Integrations -^> MCP Servers
    echo 3. Verify 'dmtools' shows as 'Connected'
) else (
    echo.
    echo ERROR: Failed to create mcp.json
    echo Please run setup-cursor-mcp.ps1 instead
)

pause
