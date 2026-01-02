# DMTools Authentication Architecture Analysis

**Date:** December 31, 2025  
**Repository:** `dmtools-original` (cloned from https://github.com/vospr/dmtools)  
**Issue:** 401 Authentication errors when using `dmtools.jar` CLI commands

---

## Executive Summary

**Root Cause Identified:** ⚠️ **Static Initialization Timing Issue**

The `BasicJiraClient` class uses a **static initialization block** that runs when the class is first loaded. This happens **before** the working directory is properly set or before `DMTOOLS_ENV` system property is fully processed, causing credential loading to fail.

---

## Architecture Overview

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    CLI Command Execution                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. dmtools.cmd executes:                                   │
│     java -DDMTOOLS_ENV="path" -jar dmtools.jar mcp <cmd>   │
│                                                             │
│  2. JobRunner.main() receives args                         │
│     → Detects "mcp" command                                │
│     → Creates McpCliHandler                                 │
│                                                             │
│  3. McpCliHandler.createClientInstances()                  │
│     → Calls BasicJiraClient.getInstance()                  │
│                                                             │
│  4. BasicJiraClient class loading triggers:                │
│     → STATIC BLOCK executes (class initialization)         │
│     → Creates PropertyReader                                │
│     → Calls propertyReader.getJiraBasePath()               │
│     → Calls propertyReader.getJiraLoginPassToken()         │
│                                                             │
│  5. PropertyReader.getValue() chain:                        │
│     → Checks Java system properties (-D flags)             │
│     → Checks config.properties (classpath)                  │
│     → Calls loadEnvFileProperties()                        │
│                                                             │
│  6. loadEnvFileProperties() priority order:                 │
│     Priority 0: DMTOOLS_ENV (system property/env var)     │
│     Priority 1: Project root/dmtools.env                   │
│     Priority 2: Current working directory/dmtools.env      │
│                                                             │
│  7. CommandLineUtils.loadEnvironmentFromFile()              │
│     → Parses dmtools.env file                              │
│     → Returns Map<String, String>                          │
│                                                             │
│  8. BasicJiraClient static fields initialized:              │
│     BASE_PATH = propertyReader.getJiraBasePath()           │
│     TOKEN = Base64(email:token) or JIRA_LOGIN_PASS_TOKEN   │
│                                                             │
│  9. getInstance() checks:                                  │
│     if (BASE_PATH == null) return null                     │
│     else create new BasicJiraClient()                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Root Cause Analysis

### Problem 1: Static Initialization Timing

**Location:** `BasicJiraClient.java` lines 52-76

```java
static {
    PropertyReader propertyReader = new PropertyReader();
    BASE_PATH = propertyReader.getJiraBasePath();
    // ... rest of initialization
}
```

**Issue:**
- Static blocks execute when the class is **first loaded**, not when `getInstance()` is called
- At class load time, the working directory might not be set correctly
- The `DMTOOLS_ENV` system property might not be accessible yet
- File path resolution might fail silently

**Evidence:**
- `PropertyReader` logs show `[PropertyReader] DMTOOLS_ENV not set` in some cases
- `BASE_PATH` ends up as `null`, causing `getInstance()` to return `null`
- This leads to "client is null" errors or 401 authentication failures

---

### Problem 2: Working Directory Context

**Location:** `PropertyReader.java` lines 137-153

```java
// Priority 2: Fall back to current working directory
String currentDir = System.getProperty("user.dir");
if (currentDir != null && !currentDir.equals(root.toString())) {
    Path envFile = Paths.get(currentDir, "dmtools.env");
    // ...
}
```

**Issue:**
- `user.dir` might not be the directory where `dmtools.env` is located
- When `dmtools.cmd` changes directory, Java's `user.dir` might not reflect this
- The `dmtools.env` file is at `c:\Users\AndreyPopov\dmtools\dmtools.env`
- But `user.dir` might be `C:\` or another location

---

### Problem 3: System Property vs Environment Variable

**Location:** `PropertyReader.java` lines 79-119

```java
// Priority 0: Check DMTOOLS_ENV (system property first, then environment variable)
String dmtoolsEnvPath = System.getProperty("DMTOOLS_ENV");
if (dmtoolsEnvPath == null || dmtoolsEnvPath.trim().isEmpty()) {
    dmtoolsEnvPath = System.getenv("DMTOOLS_ENV");
}
```

**Issue:**
- `dmtools.cmd` passes `-DDMTOOLS_ENV="path"` as system property
- But if the path has spaces or special characters, it might not be parsed correctly
- Environment variable inheritance in batch scripts can be unreliable

---

## Current Configuration

### dmtools.env Location
- **Path:** `c:\Users\AndreyPopov\dmtools\dmtools.env`
- **Format:** ✅ Correct (KEY=VALUE format)
- **Content:** ✅ Has `JIRA_BASE_PATH`, `JIRA_EMAIL`, `JIRA_API_TOKEN`

### dmtools.cmd Configuration
- **JAR Path:** `C:\Users\AndreyPopov\.dmtools\dmtools.jar`
- **DMTOOLS_ENV:** Set to `c:\Users\AndreyPopov\dmtools\dmtools.env`
- **System Property:** Passed as `-DDMTOOLS_ENV="path"`

---

## Solution Steps

### Solution 1: Ensure DMTOOLS_ENV System Property is Set Correctly (Recommended)

**Step 1.1: Verify System Property Format**

The system property must be passed correctly. Update `dmtools.cmd`:

```batch
REM Current (may have issues with quotes):
java -DDMTOOLS_ENV="%DMTOOLS_ENV%" -jar "%DMTOOLS_JAR%" mcp %*

REM Better approach (use absolute path, no quotes needed if no spaces):
set DMTOOLS_ENV=c:\Users\AndreyPopov\dmtools\dmtools.env
java -DDMTOOLS_ENV=%DMTOOLS_ENV% -jar "%DMTOOLS_JAR%" mcp %*
```

**Step 1.2: Add Debug Logging**

Modify `PropertyReader.java` to add more verbose logging:

```java
// In loadEnvFileProperties(), add:
System.out.println("[PropertyReader] System property DMTOOLS_ENV: " + System.getProperty("DMTOOLS_ENV"));
System.out.println("[PropertyReader] Environment variable DMTOOLS_ENV: " + System.getenv("DMTOOLS_ENV"));
System.out.println("[PropertyReader] user.dir: " + System.getProperty("user.dir"));
```

**Step 1.3: Rebuild JAR**

```powershell
cd "c:\Users\AndreyPopov\dmtools"
.\gradlew.bat shadowJar
```

**Step 1.4: Test**

```powershell
cd "c:\Users\AndreyPopov\dmtools"
java -DDMTOOLS_ENV="c:\Users\AndreyPopov\dmtools\dmtools.env" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile
```

---

### Solution 2: Fix Working Directory Issue

**Step 2.1: Ensure Working Directory is Set Before Class Loading**

Modify `dmtools.cmd` to set working directory explicitly:

```batch
REM Set working directory to where dmtools.env is located
if defined DMTOOLS_ENV (
    for %%F in ("%DMTOOLS_ENV%") do set DMTOOLS_ENV_DIR=%%~dpF
    if defined DMTOOLS_ENV_DIR (
        cd /d "%DMTOOLS_ENV_DIR%"
        REM Now execute Java with working directory set
        java -DDMTOOLS_ENV="%DMTOOLS_ENV%" -jar "%DMTOOLS_JAR%" mcp %*
    )
)
```

**Step 2.2: Alternative - Use Absolute Path in PropertyReader**

Modify `PropertyReader.java` to handle absolute paths better:

```java
// In loadEnvFileProperties(), after getting DMTOOLS_ENV:
if (dmtoolsEnvPath != null && !dmtoolsEnvPath.trim().isEmpty()) {
    Path envFile = Paths.get(dmtoolsEnvPath.trim());
    // Convert to absolute path if relative
    if (!envFile.isAbsolute()) {
        envFile = Paths.get(System.getProperty("user.dir")).resolve(envFile).normalize();
    }
    // ... rest of code
}
```

---

### Solution 3: Lazy Initialization (Best Long-Term Fix)

**Step 3.1: Refactor BasicJiraClient to Use Lazy Initialization**

Instead of static initialization, use instance-based initialization:

```java
// Remove static block, move to instance initialization
public static TrackerClient<? extends ITicket> getInstance() throws IOException {
    if (instance == null) {
        PropertyReader propertyReader = new PropertyReader();
        String basePath = propertyReader.getJiraBasePath();
        if (basePath == null || basePath.isEmpty()) {
            return null;
        }
        String token = getToken(propertyReader);
        instance = new BasicJiraClient(basePath, token);
    }
    return instance;
}

private static String getToken(PropertyReader propertyReader) {
    String jiraLoginPassToken = propertyReader.getJiraLoginPassToken();
    if (jiraLoginPassToken == null || jiraLoginPassToken.isEmpty()) {
        String email = propertyReader.getJiraEmail();
        String token = propertyReader.getJiraApiToken();
        if (email != null && token != null) {
            String credentials = email.trim() + ":" + token.trim();
            return Base64.getEncoder().encodeToString(credentials.getBytes());
        }
    }
    return jiraLoginPassToken;
}
```

**Step 3.2: Update Constructor**

```java
public BasicJiraClient(String basePath, String token) throws IOException {
    super(basePath, token, -1);
    PropertyReader propertyReader = new PropertyReader();
    // Set other properties from PropertyReader
    String authType = propertyReader.getJiraAuthType();
    if (authType != null) {
        setAuthType(authType);
    }
    // ... rest of initialization
}
```

---

### Solution 4: Add Explicit Credential Validation

**Step 4.1: Add Validation in PropertyReader**

```java
public String getJiraBasePath() {
    String value = getValue("JIRA_BASE_PATH");
    if (value == null || value.isEmpty()) {
        System.err.println("[ERROR] JIRA_BASE_PATH is not set!");
        System.err.println("[ERROR] Checked locations:");
        System.err.println("  - System property DMTOOLS_ENV: " + System.getProperty("DMTOOLS_ENV"));
        System.err.println("  - Environment variable DMTOOLS_ENV: " + System.getenv("DMTOOLS_ENV"));
        System.err.println("  - user.dir: " + System.getProperty("user.dir"));
    }
    return value;
}
```

---

## Recommended Implementation Order

### Phase 1: Quick Fix (Immediate)

1. ✅ **Update `dmtools.cmd`** to ensure `DMTOOLS_ENV` is passed correctly
2. ✅ **Add debug logging** to `PropertyReader.java`
3. ✅ **Rebuild JAR** with `gradlew shadowJar`
4. ✅ **Test** with verbose output

### Phase 2: Robust Fix (Short-term)

1. ✅ **Fix working directory** handling in `dmtools.cmd`
2. ✅ **Improve path resolution** in `PropertyReader.java`
3. ✅ **Add validation** and error messages
4. ✅ **Rebuild and test**

### Phase 3: Architecture Fix (Long-term)

1. ✅ **Refactor to lazy initialization** (remove static blocks)
2. ✅ **Add proper error handling** and user-friendly messages
3. ✅ **Add unit tests** for credential loading
4. ✅ **Rebuild and test**

---

## Detailed Implementation Steps

### Step 1: Update dmtools.cmd

**File:** `C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd`

**Current Code (lines 69-76):**
```batch
REM Execute dmtools with "mcp" prefix and all arguments passed through
REM Pass DMTOOLS_ENV as system property if set (Java reads this more reliably)
if defined DMTOOLS_ENV (
    java -DDMTOOLS_ENV="%DMTOOLS_ENV%" -jar "%DMTOOLS_JAR%" mcp %*
) else (
    REM Fall back to environment variable inheritance
    java -jar "%DMTOOLS_JAR%" mcp %*
)
```

**Updated Code:**
```batch
REM Ensure DMTOOLS_ENV is always set to absolute path
if not defined DMTOOLS_ENV (
    set DMTOOLS_ENV=c:\Users\AndreyPopov\dmtools\dmtools.env
)

REM Convert to absolute path if relative
for %%F in ("%DMTOOLS_ENV%") do set DMTOOLS_ENV_ABS=%%~fF

REM Set working directory to dmtools.env location for fallback
for %%F in ("%DMTOOLS_ENV_ABS%") do (
    set DMTOOLS_ENV_DIR=%%~dpF
    cd /d "%%~dpF"
)

REM Execute with explicit system property (no quotes needed if path has no spaces)
REM Use absolute path to avoid any path resolution issues
java -DDMTOOLS_ENV=%DMTOOLS_ENV_ABS% -jar "%DMTOOLS_JAR%" mcp %*
```

---

### Step 2: Enhance PropertyReader Logging

**File:** `c:\Users\AndreyPopov\dmtools\dmtools-core\src\main\java\com\github\istin\dmtools\common\utils\PropertyReader.java`

**Add to `loadEnvFileProperties()` method (after line 84):**

```java
// Enhanced debugging
System.out.println("[PropertyReader] ===== Credential Loading Debug =====");
System.out.println("[PropertyReader] System property DMTOOLS_ENV: " + System.getProperty("DMTOOLS_ENV"));
System.out.println("[PropertyReader] Environment variable DMTOOLS_ENV: " + System.getenv("DMTOOLS_ENV"));
System.out.println("[PropertyReader] user.dir: " + System.getProperty("user.dir"));
System.out.println("[PropertyReader] Current thread: " + Thread.currentThread().getName());
```

**Add to `getValue()` method (after line 222, before calling `loadEnvFileProperties()`):**

```java
// Debug: Show what we're looking for
if (propertyKey.startsWith("JIRA_")) {
    System.out.println("[PropertyReader] Looking for property: " + propertyKey);
}
```

---

### Step 3: Improve Path Resolution

**File:** `c:\Users\AndreyPopov\dmtools\dmtools-core\src\main\java\com\github\istin\dmtools\common\utils\PropertyReader.java`

**Update `loadEnvFileProperties()` method (around line 85-115):**

```java
if (dmtoolsEnvPath != null && !dmtoolsEnvPath.trim().isEmpty()) {
    Path envFile = Paths.get(dmtoolsEnvPath.trim());
    
    // Convert to absolute path if relative
    if (!envFile.isAbsolute()) {
        String currentDir = System.getProperty("user.dir");
        if (currentDir != null) {
            envFile = Paths.get(currentDir).resolve(envFile).normalize();
            System.out.println("[PropertyReader] Converted relative path to absolute: " + envFile);
        }
    }
    
    System.out.println("[PropertyReader] DMTOOLS_ENV found: " + dmtoolsEnvPath);
    System.out.println("[PropertyReader] Resolved path: " + envFile.toAbsolutePath());
    System.out.println("[PropertyReader] Path exists: " + Files.exists(envFile));
    System.out.println("[PropertyReader] Path is regular file: " + Files.isRegularFile(envFile));
    
    logger.info("DMTOOLS_ENV found (system property or env var): {}", dmtoolsEnvPath);
    if (Files.exists(envFile) && Files.isRegularFile(envFile)) {
        try {
            Map<String, String> envVars = CommandLineUtils.loadEnvironmentFromFile(envFile.toString());
            if (!envVars.isEmpty()) {
                envVars.forEach(envFileProps::setProperty);
                System.out.println("[PropertyReader] SUCCESS: Loaded " + envVars.size() + " properties from: " + envFile);
                System.out.println("[PropertyReader] JIRA_BASE_PATH=" + envFileProps.getProperty("JIRA_BASE_PATH"));
                System.out.println("[PropertyReader] JIRA_EMAIL=" + envFileProps.getProperty("JIRA_EMAIL"));
                System.out.println("[PropertyReader] JIRA_API_TOKEN present=" + (envFileProps.getProperty("JIRA_API_TOKEN") != null ? "YES" : "NO"));
                logger.info("SUCCESS: Loaded {} properties from dmtools.env via DMTOOLS_ENV: {}", envVars.size(), envFile);
                logger.info("JIRA_BASE_PATH={}, JIRA_EMAIL={}, JIRA_API_TOKEN present={}", 
                        envFileProps.getProperty("JIRA_BASE_PATH"),
                        envFileProps.getProperty("JIRA_EMAIL"),
                        envFileProps.getProperty("JIRA_API_TOKEN") != null ? "YES" : "NO");
                return;
            } else {
                System.out.println("[PropertyReader] WARNING: DMTOOLS_ENV file exists but is empty");
                logger.warn("DMTOOLS_ENV file exists but is empty or could not be parsed: {}", envFile);
            }
        } catch (Exception e) {
            System.out.println("[PropertyReader] ERROR loading DMTOOLS_ENV: " + e.getMessage());
            e.printStackTrace(); // Add stack trace for debugging
            logger.error("Failed to load dmtools.env from DMTOOLS_ENV path {}: {}", envFile, e.getMessage(), e);
        }
    } else {
        System.out.println("[PropertyReader] WARNING: DMTOOLS_ENV file not found: " + envFile);
        System.out.println("[PropertyReader] Absolute path checked: " + envFile.toAbsolutePath());
        logger.warn("DMTOOLS_ENV specified but file not found: {}", envFile);
    }
}
```

---

### Step 4: Rebuild dmtools.jar

**Commands:**

```powershell
# Navigate to dmtools source directory
cd "c:\Users\AndreyPopov\dmtools"

# Clean previous build (optional)
.\gradlew.bat clean

# Build shadow JAR (includes all dependencies)
.\gradlew.bat shadowJar

# Copy to installation directory
Copy-Item "dmtools-core\build\libs\dmtools-core-all.jar" -Destination "C:\Users\AndreyPopov\.dmtools\dmtools.jar" -Force

# Verify JAR was created
Test-Path "C:\Users\AndreyPopov\.dmtools\dmtools.jar"
```

---

### Step 5: Test Authentication

**Test Command:**

```powershell
# Test with explicit DMTOOLS_ENV
cd "c:\Users\AndreyPopov\dmtools"
java -DDMTOOLS_ENV="c:\Users\AndreyPopov\dmtools\dmtools.env" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile

# Test via dmtools.cmd wrapper
dmtools jira_get_my_profile
```

**Expected Output:**
- Should see `[PropertyReader]` debug messages
- Should see `SUCCESS: Loaded X properties`
- Should see Jira user profile JSON

---

## Alternative: Use Direct API Calls (Current Workaround)

**Status:** ✅ **Working** - This is the current approach being used

**Advantages:**
- ✅ Bypasses all JAR authentication issues
- ✅ Direct control over API calls
- ✅ Easy to debug
- ✅ Fast execution

**Disadvantages:**
- ❌ Requires rewriting all `dmtools` commands
- ❌ More verbose code
- ❌ No reuse of dmtools.jar logic

**Recommendation:** Fix the JAR authentication (Solutions 1-4) for long-term maintainability, but continue using direct API calls as workaround until fixed.

---

## Verification Checklist

After implementing fixes:

- [ ] `dmtools.cmd` passes `DMTOOLS_ENV` correctly
- [ ] `PropertyReader` logs show file is found
- [ ] `PropertyReader` logs show properties are loaded
- [ ] `BasicJiraClient.getInstance()` returns non-null
- [ ] `dmtools jira_get_my_profile` returns user data (not 401)
- [ ] `dmtools gemini_ai_chat "test"` works (not 403)
- [ ] All MCP tools work via `dmtools` CLI

---

## Files to Modify

1. **`C:\Users\AndreyPopov\.dmtools\bin\dmtools.cmd`**
   - Update system property passing
   - Fix working directory handling

2. **`c:\Users\AndreyPopov\dmtools\dmtools-core\src\main\java\com\github\istin\dmtools\common\utils\PropertyReader.java`**
   - Add debug logging
   - Improve path resolution
   - Add error messages

3. **`c:\Users\AndreyPopov\dmtools\dmtools-core\src\main\java\com\github\istin\dmtools\atlassian\jira\BasicJiraClient.java`** (Optional - Phase 3)
   - Refactor static initialization to lazy initialization

---

## Build and Test Script

**Save as:** `fix-and-test.ps1`

```powershell
# Fix and Test DMTools Authentication

Write-Host "=== Step 1: Update dmtools.cmd ===" -ForegroundColor Cyan
# (Manual edit required)

Write-Host "`n=== Step 2: Update PropertyReader.java ===" -ForegroundColor Cyan
# (Manual edit required)

Write-Host "`n=== Step 3: Rebuild JAR ===" -ForegroundColor Cyan
cd "c:\Users\AndreyPopov\dmtools"
.\gradlew.bat shadowJar

Write-Host "`n=== Step 4: Copy JAR ===" -ForegroundColor Cyan
Copy-Item "dmtools-core\build\libs\dmtools-core-all.jar" -Destination "C:\Users\AndreyPopov\.dmtools\dmtools.jar" -Force

Write-Host "`n=== Step 5: Test Authentication ===" -ForegroundColor Cyan
cd "c:\Users\AndreyPopov\dmtools"
java -DDMTOOLS_ENV="c:\Users\AndreyPopov\dmtools\dmtools.env" -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" mcp jira_get_my_profile

Write-Host "`n=== Done ===" -ForegroundColor Green
```

---

## Expected Outcomes

### Success Indicators

1. ✅ `[PropertyReader] SUCCESS: Loaded X properties` appears in output
2. ✅ `JIRA_BASE_PATH`, `JIRA_EMAIL`, `JIRA_API_TOKEN` are all loaded
3. ✅ `BasicJiraClient.getInstance()` returns a valid instance
4. ✅ `dmtools jira_get_my_profile` returns user JSON (not 401)
5. ✅ All other `dmtools` commands work

### Failure Indicators

1. ❌ `[PropertyReader] DMTOOLS_ENV not set` (system property not passed)
2. ❌ `[PropertyReader] WARNING: DMTOOLS_ENV file not found` (path resolution failed)
3. ❌ `[PropertyReader] WARNING: DMTOOLS_ENV file exists but is empty` (parsing failed)
4. ❌ `BASE_PATH == null` in `BasicJiraClient.getInstance()` (returns null)
5. ❌ 401 errors persist (credentials not loaded)

---

## Next Steps

1. **Immediate:** Implement Solution 1 (update `dmtools.cmd` and add logging)
2. **Short-term:** Implement Solution 2 (fix working directory)
3. **Long-term:** Implement Solution 3 (lazy initialization refactor)

**Priority:** Start with Solution 1, as it's the quickest fix with highest probability of success.

---

**Document Created:** December 31, 2025  
**Based On:** Analysis of `dmtools-original` repository and current `dmtools` installation
