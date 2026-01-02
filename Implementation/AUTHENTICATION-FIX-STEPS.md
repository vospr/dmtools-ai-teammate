# DMTools Authentication Fix - Step-by-Step Guide

**Date:** December 31, 2025  
**Issue:** 401 Authentication errors with `dmtools.jar` CLI commands  
**Root Cause:** Static initialization timing - credentials loaded before working directory is set

---

## Quick Summary

**Problem:** `BasicJiraClient` uses a static block that runs when the class loads, but at that time:
- Working directory might not be set correctly
- `DMTOOLS_ENV` system property might not be accessible
- File path resolution fails silently

**Solution:** Fix the credential loading path and add proper error handling.

---

## Step-by-Step Fix

### Step 1: Update dmtools.cmd (5 minutes)

**File:** `C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd`

**Replace lines 69-76 with:**

```batch
REM Ensure DMTOOLS_ENV is always set to absolute path
if not defined DMTOOLS_ENV (
    set DMTOOLS_ENV=c:\Users\AndreyPopov\dmtools\dmtools.env
)

REM Convert to absolute path (handles relative paths)
for %%F in ("%DMTOOLS_ENV%") do set DMTOOLS_ENV_ABS=%%~fF

REM Set working directory to dmtools.env location
for %%F in ("%DMTOOLS_ENV_ABS%") do (
    cd /d "%%~dpF"
)

REM Execute with explicit absolute path
java -DDMTOOLS_ENV=%DMTOOLS_ENV_ABS% -jar "%DMTOOLS_JAR%" mcp %*
```

**Why:** Ensures absolute path is used and working directory is set before Java starts.

---

### Step 2: Add Debug Logging to PropertyReader (10 minutes)

**File:** `c:\Users\AndreyPopov\dmtools\dmtools-core\src\main\java\com\github\istin\dmtools\common\utils\PropertyReader.java`

**Add after line 84 (inside `loadEnvFileProperties()` method):**

```java
// Enhanced debugging for credential loading
System.out.println("[PropertyReader] ===== Credential Loading Debug =====");
System.out.println("[PropertyReader] System property DMTOOLS_ENV: " + System.getProperty("DMTOOLS_ENV"));
System.out.println("[PropertyReader] Environment variable DMTOOLS_ENV: " + System.getenv("DMTOOLS_ENV"));
System.out.println("[PropertyReader] user.dir: " + System.getProperty("user.dir"));
```

**Add after line 86 (after creating Path object):**

```java
// Convert to absolute path if relative
if (!envFile.isAbsolute()) {
    String currentDir = System.getProperty("user.dir");
    if (currentDir != null) {
        envFile = Paths.get(currentDir).resolve(envFile).normalize();
        System.out.println("[PropertyReader] Converted relative path to absolute: " + envFile);
    }
}

System.out.println("[PropertyReader] Resolved path: " + envFile.toAbsolutePath());
System.out.println("[PropertyReader] Path exists: " + Files.exists(envFile));
System.out.println("[PropertyReader] Path is regular file: " + Files.isRegularFile(envFile));
```

**Why:** Provides visibility into what's happening during credential loading.

---

### Step 3: Rebuild dmtools.jar (5 minutes)

**Run in PowerShell:**

```powershell
cd "c:\Users\AndreyPopov\dmtools"
.\gradlew.bat shadowJar

# Copy to installation directory
Copy-Item "dmtools-core\build\libs\dmtools-core-all.jar" -Destination "C:\Users\AndreyPopov\.dmtools\dmtools.jar" -Force

Write-Host "✅ JAR rebuilt and copied" -ForegroundColor Green
```

**Why:** Applies the code changes to the executable JAR.

---

### Step 4: Test Authentication (2 minutes)

**Test Command:**

```powershell
# Test with explicit path
cd "c:\Users\AndreyPopov\dmtools"
java -DDMTOOLS_ENV="c:\Users\AndreyPopov\dmtools\dmtools.env" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
```

**Expected Output:**
```
[PropertyReader] ===== Credential Loading Debug =====
[PropertyReader] System property DMTOOLS_ENV: c:\Users\AndreyPopov\dmtools\dmtools.env
[PropertyReader] Resolved path: c:\Users\AndreyPopov\dmtools\dmtools.env
[PropertyReader] Path exists: true
[PropertyReader] SUCCESS: Loaded X properties from: c:\Users\AndreyPopov\dmtools\dmtools.env
[PropertyReader] JIRA_BASE_PATH=https://vospr.atlassian.net
[PropertyReader] JIRA_EMAIL=andrey_popov@epam.com
[PropertyReader] JIRA_API_TOKEN present=YES
{
  "accountId": "712020:...",
  "displayName": "Andrey",
  ...
}
```

**If you see 401 error:** Check the debug output to see where credential loading failed.

---

### Step 5: Test via dmtools.cmd Wrapper (1 minute)

**Test Command:**

```powershell
dmtools jira_get_my_profile
```

**Expected:** Same successful output as Step 4.

---

## Troubleshooting

### Issue: Still Getting 401 Error

**Check:**
1. ✅ Debug output shows `SUCCESS: Loaded X properties`
2. ✅ `JIRA_BASE_PATH`, `JIRA_EMAIL`, `JIRA_API_TOKEN` are all present
3. ✅ `BASE_PATH` is not null in `BasicJiraClient.getInstance()`

**If properties are loaded but still 401:**
- Verify token hasn't expired
- Check token format (no extra spaces/newlines)
- Verify email matches token owner

### Issue: "DMTOOLS_ENV file not found"

**Check:**
1. ✅ Path in `dmtools.cmd` is correct
2. ✅ File exists at that path
3. ✅ No permission issues reading the file

**Fix:** Use absolute path in `DMTOOLS_ENV` system property.

### Issue: "File exists but is empty"

**Check:**
1. ✅ File has content (not 0 bytes)
2. ✅ File format is correct (KEY=VALUE, one per line)
3. ✅ No encoding issues (should be UTF-8)

**Fix:** Verify file content and format.

---

## Alternative: Quick Test Without Rebuild

If you want to test the fix without rebuilding, you can modify the existing JAR's behavior by:

1. **Setting environment variable explicitly:**
   ```powershell
   $env:DMTOOLS_ENV = "c:\Users\AndreyPopov\dmtools\dmtools.env"
   cd "c:\Users\AndreyPopov\dmtools"
   java -DDMTOOLS_ENV="$env:DMTOOLS_ENV" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
   ```

2. **Using absolute path in system property:**
   ```powershell
   java -DDMTOOLS_ENV="c:\Users\AndreyPopov\dmtools\dmtools.env" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
   ```

---

## Success Criteria

✅ **Fixed when:**
- `dmtools jira_get_my_profile` returns user JSON (not 401)
- `dmtools gemini_ai_chat "test"` returns AI response (not 403)
- All `dmtools` CLI commands work
- Debug output shows credentials loaded successfully

---

## Estimated Time

- **Step 1:** 5 minutes (edit batch file)
- **Step 2:** 10 minutes (edit Java file)
- **Step 3:** 5 minutes (rebuild JAR)
- **Step 4:** 2 minutes (test)
- **Step 5:** 1 minute (verify)

**Total:** ~25 minutes

---

## Next Steps After Fix

Once authentication is working:

1. ✅ Remove debug logging (or keep for troubleshooting)
2. ✅ Test all integrations (Jira, Confluence, Gemini, GitHub, Figma)
3. ✅ Update testing guide to use `dmtools` CLI commands
4. ✅ Document the fix for future reference

---

**Quick Reference:** See `DMTOOLS-AUTHENTICATION-ANALYSIS.md` for detailed architecture analysis.
