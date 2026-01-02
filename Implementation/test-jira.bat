@echo off
echo ===================================
echo DMTools Jira Connection Test
echo ===================================
echo.

cd /d "c:\Users\AndreyPopov\dmtools"

echo Setting environment variables from dmtools.env...
for /f "usebackq tokens=1,* delims==" %%a in ("dmtools.env") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        if not "%%a"=="" (
            set "%%a=%%b"
        )
    )
)

echo.
echo Testing Jira connection...
echo This may take 10-30 seconds...
echo.

java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile > jira-test-result.txt 2>&1

echo.
echo Result saved to: c:\Users\AndreyPopov\dmtools\jira-test-result.txt
echo Opening result file...
notepad jira-test-result.txt

pause

