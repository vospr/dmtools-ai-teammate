@echo off
echo ===================================
echo DMTools Simple Test
echo ===================================
echo.

cd /d "c:\Users\AndreyPopov\dmtools"

echo [1/3] Testing Java...
java -version
if %ERRORLEVEL% NEQ 0 (
    echo FAILED: Java not working
    pause
    exit /b 1
)
echo.

echo [2/3] Testing dmtools JAR...
if not exist "C:\Users\AndreyPopov\.dmtools\dmtools.jar" (
    echo FAILED: JAR not found
    pause
    exit /b 1
)
echo SUCCESS: JAR exists
echo.

echo [3/3] Testing MCP list (saving to tools-list.txt)...
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp list > tools-list.txt 2>&1
echo Output saved to: c:\Users\AndreyPopov\dmtools\tools-list.txt
echo.

echo Opening output file...
notepad tools-list.txt

pause

