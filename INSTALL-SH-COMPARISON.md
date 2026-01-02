# install.sh Comparison: IstiN/dmtools vs vospr/dmtools

**Date:** January 2, 2026  
**Purpose:** Compare the original `install.sh` from `IstiN/dmtools` with the modified version in `vospr/dmtools`

---

## URL Format Explanation

The two URLs you provided are actually the **same file**, just accessed through different interfaces:

1. **`https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh`**
   - **Raw content URL** - Returns the actual file content
   - Used for: `curl | bash` installations, direct downloads
   - Content-Type: `text/plain` or `application/octet-stream`

2. **`https://github.com/IstiN/dmtools/blob/main/install.sh`**
   - **GitHub web UI URL** - Shows the file in GitHub's web interface
   - Used for: Viewing in browser, syntax highlighting, line numbers
   - Content-Type: `text/html` (rendered page)

**Both URLs point to the same file** - the difference is just how GitHub serves it.

---

## Overview

| Aspect | IstiN/dmtools (Original) | vospr/dmtools (Modified) |
|--------|--------------------------|-------------------------|
| **Repository** | `IstiN/dmtools` | `vospr/dmtools` |
| **File Path** | `install.sh` | `install.sh` |
| **Lines of Code** | ~667 | ~667 |
| **Status** | Original/reference | Forked/modified version |

---

## Key Differences

### 1. Repository Configuration

**IstiN/dmtools (Original):**
```bash
# Configuration
REPO="IstiN/dmtools"
```

**vospr/dmtools (Modified):**
```bash
# Configuration
# Local source detection - check for local dmtools directory
echo "DEBUG: Checking DMTOOLS_LOCAL_SOURCE=$DMTOOLS_LOCAL_SOURCE"
if [ -n "$DMTOOLS_LOCAL_SOURCE" ] && [ -d "$DMTOOLS_LOCAL_SOURCE" ]; then
    LOCAL_SOURCE="$DMTOOLS_LOCAL_SOURCE"
    USE_LOCAL=true
    echo "DEBUG: Using LOCAL_SOURCE=$LOCAL_SOURCE, USE_LOCAL=$USE_LOCAL"
    ls -la "$LOCAL_SOURCE" 2>&1 | head -10 || echo "DEBUG: Cannot list LOCAL_SOURCE"
elif [ -d "$HOME/dmtools" ]; then
    LOCAL_SOURCE="$HOME/dmtools"
    USE_LOCAL=true
elif [ -d "/c/Users/AndreyPopov/dmtools" ]; then
    LOCAL_SOURCE="/c/Users/AndreyPopov/dmtools"
    USE_LOCAL=true
else
    USE_LOCAL=false
    LOCAL_SOURCE=""
    echo "DEBUG: No local source found, USE_LOCAL=false"
fi

# Repository configuration - use vospr/dmtools for releases, local for development
if [ "$USE_LOCAL" = true ]; then
    REPO="vospr/dmtools"  # For documentation/fallback URLs
else
    REPO="vospr/dmtools"
fi
```

**Key Differences:**
- **IstiN:** Simple hardcoded `REPO="IstiN/dmtools"`
- **vospr:** Dynamic repository with local source detection
- **vospr:** Adds `USE_LOCAL` and `LOCAL_SOURCE` variables
- **vospr:** Includes debug logging for local source detection
- **vospr:** Checks multiple local paths (`$DMTOOLS_LOCAL_SOURCE`, `$HOME/dmtools`, `/c/Users/AndreyPopov/dmtools`)

---

### 2. Usage Comments

**IstiN/dmtools (Original):**
```bash
# Usage: curl -fsSL https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh | bash
```

**vospr/dmtools (Modified):**
```bash
# Usage (local): ./install.sh
# Usage (remote): curl -fsSL https://raw.githubusercontent.com/vospr/dmtools/main/install.sh | bash
```

**Key Differences:**
- **IstiN:** Single usage line
- **vospr:** Two usage lines (local and remote)
- **vospr:** References `vospr/dmtools` instead of `IstiN/dmtools`

---

### 3. Local Source Detection

**IstiN/dmtools (Original):**
- ❌ No local source detection
- ❌ Always downloads from GitHub releases

**vospr/dmtools (Modified):**
- ✅ Extensive local source detection
- ✅ Checks `DMTOOLS_LOCAL_SOURCE` environment variable
- ✅ Falls back to `$HOME/dmtools` and `/c/Users/AndreyPopov/dmtools`
- ✅ Uses local JAR files from `build/libs/` directory
- ✅ Uses local `dmtools.sh` script if available

---

### 4. Download Logic - JAR File

**IstiN/dmtools (Original):**
```bash
# Download JAR
download_file "$jar_url" "$JAR_PATH" "DMTools JAR"
```

**vospr/dmtools (Modified):**
```bash
# Check for local JAR first (for local development)
if [ "$USE_LOCAL" = true ] && [ -n "$LOCAL_SOURCE" ]; then
    local local_jar=""
    # Try to find JAR in local build directory
    if [ -d "$LOCAL_SOURCE/build/libs" ]; then
        local_jar=$(find "$LOCAL_SOURCE/build/libs" -name "dmtools-*-all.jar" -o -name "*-all.jar" | head -1)
    fi
    
    if [ -n "$local_jar" ] && [ -f "$local_jar" ]; then
        progress "Using local JAR from: $local_jar"
        cp "$local_jar" "$JAR_PATH"
        info "Copied local JAR to $JAR_PATH"
    else
        # Fallback to download
        download_file "$jar_url" "$JAR_PATH" "DMTools JAR"
    fi
else
    # Download JAR
    download_file "$jar_url" "$JAR_PATH" "DMTools JAR"
fi
```

**Key Differences:**
- **IstiN:** Always downloads from GitHub
- **vospr:** Checks for local JAR first, then downloads if not found

---

### 5. Download Logic - Shell Script

**IstiN/dmtools (Original):**
```bash
# Download shell script - try multiple methods
# Method 1: Try redirect-based URL (standard GitHub release URL)
if download_file "$script_url" "$SCRIPT_PATH" "DMTools shell script" "true"; then
    # Success with redirect URL
    chmod +x "$SCRIPT_PATH"
    return 0
fi

# Method 2: Try GitHub API to get direct asset URL
# Method 3: Fallback to repository main branch
```

**vospr/dmtools (Modified):**
```bash
# Download shell script - try multiple methods
# Method 0: Check local source FIRST (before any downloads)
if [ "$USE_LOCAL" = true ] && [ -n "$LOCAL_SOURCE" ] && [ -f "$LOCAL_SOURCE/dmtools.sh" ]; then
    progress "Using local dmtools.sh from: $LOCAL_SOURCE/dmtools.sh"
    cp "$LOCAL_SOURCE/dmtools.sh" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    return 0
fi

# Method 1: Try redirect-based URL (standard GitHub release URL)
# Method 2: Try GitHub API to get direct asset URL
# Method 3: Fallback to repository main branch (also checks local)
```

**Key Differences:**
- **IstiN:** 3 download methods (redirect URL, API, repository)
- **vospr:** 4 methods (local first, then 3 download methods)
- **vospr:** Prioritizes local files before any network downloads

---

### 6. Debug Logging

**IstiN/dmtools (Original):**
- ❌ No debug logging
- ❌ Minimal output

**vospr/dmtools (Modified):**
- ✅ Extensive debug logging:
  - `echo "DEBUG: Checking DMTOOLS_LOCAL_SOURCE=$DMTOOLS_LOCAL_SOURCE"`
  - `echo "DEBUG: Using LOCAL_SOURCE=$LOCAL_SOURCE, USE_LOCAL=$USE_LOCAL"`
  - `ls -la "$LOCAL_SOURCE" 2>&1 | head -10`
  - `echo "DEBUG download_script_from_repo: USE_LOCAL=$USE_LOCAL, LOCAL_SOURCE=$LOCAL_SOURCE"`
  - `echo "DEBUG: Checking for file: $LOCAL_SOURCE/dmtools.sh"`

---

### 7. download_script_from_repo Function

**IstiN/dmtools (Original):**
```bash
download_script_from_repo() {
    local version="$1"
    local script_url="https://raw.githubusercontent.com/${REPO}/main/dmtools.sh"
    
    progress "dmtools.sh not found in release assets, downloading from repository..."
    
    if download_file "$script_url" "$SCRIPT_PATH" "DMTools shell script (from repository)" "true"; then
        # Validate it's actually a shell script
        if ! head -n 1 "$SCRIPT_PATH" 2>/dev/null | grep -q "^#!/bin/bash"; then
            warn "Downloaded file doesn't appear to be a valid shell script. Trying alternative source..."
            rm -f "$SCRIPT_PATH"
            return 1
        fi
        return 0
    fi
    
    return 1
}
```

**vospr/dmtools (Modified):**
```bash
download_script_from_repo() {
    local version="$1"
    local script_url="https://raw.githubusercontent.com/${REPO}/main/dmtools.sh"
    
    # Debug: Log local source check
    echo "DEBUG download_script_from_repo: USE_LOCAL=$USE_LOCAL, LOCAL_SOURCE=$LOCAL_SOURCE"
    echo "DEBUG: Checking for file: $LOCAL_SOURCE/dmtools.sh"
    if [ -n "$LOCAL_SOURCE" ]; then
        ls -la "$LOCAL_SOURCE/dmtools.sh" 2>&1 || echo "DEBUG: File not found or not accessible"
    fi
    
    # Check local source first
    if [ "$USE_LOCAL" = true ] && [ -n "$LOCAL_SOURCE" ] && [ -f "$LOCAL_SOURCE/dmtools.sh" ]; then
        progress "Using local dmtools.sh from repository..."
        cp "$LOCAL_SOURCE/dmtools.sh" "$SCRIPT_PATH"
        return 0
    else
        echo "DEBUG: Local file check failed - USE_LOCAL=$USE_LOCAL, LOCAL_SOURCE=$LOCAL_SOURCE, file exists: $([ -f "$LOCAL_SOURCE/dmtools.sh" ] && echo 'yes' || echo 'no')"
    fi
    
    progress "dmtools.sh not found in release assets, downloading from repository..."
    
    # ... rest of function same as IstiN version
}
```

**Key Differences:**
- **IstiN:** Only downloads from repository
- **vospr:** Checks local source first, then downloads
- **vospr:** Adds debug logging for troubleshooting

---

### 8. Error Messages

**IstiN/dmtools (Original):**
```bash
error "Failed to download dmtools.sh from all available sources:
  1. GitHub release redirect URL: $script_url
  2. GitHub API asset URL: ${api_asset_url:-'(not available)'}
  3. Repository main branch: https://raw.githubusercontent.com/${REPO}/main/dmtools.sh
  ...
And place it at: $SCRIPT_PATH"
```

**vospr/dmtools (Modified):**
```bash
error "Failed to download dmtools.sh from all available sources:
  1. GitHub release redirect URL: $script_url
  2. GitHub API asset URL: ${api_asset_url:-'(not available)'}
  3. Repository main branch: https://raw.githubusercontent.com/${REPO}/main/dmtools.sh
  ...
Or if developing locally:
  cp $LOCAL_SOURCE/dmtools.sh $SCRIPT_PATH
  chmod +x $SCRIPT_PATH
  
And place it at: $SCRIPT_PATH"
```

**Key Differences:**
- **vospr:** Adds instructions for local development
- **vospr:** Mentions `LOCAL_SOURCE` variable

---

### 9. Post-Installation Instructions

**IstiN/dmtools (Original):**
```bash
echo "For more information, visit: https://github.com/${REPO}"
```

**vospr/dmtools (Modified):**
```bash
if [ "$USE_LOCAL" = true ]; then
    echo "For more information, visit: ${LOCAL_SOURCE}"
    echo "  Local development: cd ${LOCAL_SOURCE} && ./gradlew shadowJar"
else
    echo "For more information, visit: https://github.com/${REPO}"
fi
```

**Key Differences:**
- **IstiN:** Always shows GitHub URL
- **vospr:** Shows local path if using local source, GitHub URL otherwise
- **vospr:** Adds Gradle build command for local development

---

## Summary of Differences

| Feature | IstiN/dmtools | vospr/dmtools |
|---------|--------------|---------------|
| **Repository** | `IstiN/dmtools` | `vospr/dmtools` |
| **Local Source Detection** | ❌ No | ✅ Yes (extensive) |
| **Debug Logging** | ❌ No | ✅ Yes (multiple DEBUG statements) |
| **Local JAR Support** | ❌ No | ✅ Yes (checks `build/libs/`) |
| **Local Script Support** | ❌ No | ✅ Yes (checks local `dmtools.sh`) |
| **Download Priority** | Always GitHub | Local first, then GitHub |
| **Error Messages** | Standard | Enhanced with local dev instructions |
| **Post-Install Info** | GitHub URL only | Local path or GitHub URL |

---

## Code Differences Summary

| Line Range | IstiN/dmtools | vospr/dmtools | Type |
|------------|---------------|---------------|------|
| 4 | `IstiN/dmtools` | `vospr/dmtools` | Repository URL |
| 16-41 | Simple `REPO="IstiN/dmtools"` | Local source detection + `REPO="vospr/dmtools"` | Configuration |
| 432-466 | No local check | Local source check before download | Function logic |
| 468-549 | No local JAR check | Local JAR check before download | Function logic |
| 614-636 | GitHub URL only | Conditional (local path or GitHub URL) | Post-install |

---

## Recommendations

### Option 1: Keep vospr Version (Recommended for Local Development)

**Benefits:**
- ✅ Supports local development workflow
- ✅ Reduces dependency on GitHub releases
- ✅ Better for CI/CD with local files
- ✅ Debug logging helps troubleshoot issues

**Use Cases:**
- Local development and testing
- CI/CD pipelines with bundled files
- Offline installations
- Custom builds

### Option 2: Use IstiN Version (Recommended for Production)

**Benefits:**
- ✅ Simpler code (no local detection logic)
- ✅ Always uses latest from GitHub
- ✅ No debug noise in output
- ✅ Standard installation process

**Use Cases:**
- Standard user installations
- Production deployments
- Public distribution

### Option 3: Hybrid Approach

**Combine best of both:**
- Keep local source detection (vospr feature)
- Remove debug logging for production (IstiN approach)
- Make local detection optional via environment variable
- Use IstiN as base, add vospr features conditionally

---

## Conclusion

The **vospr version** is an **enhanced fork** of the IstiN version with:

1. **Local source detection** - Prioritizes local files over downloads
2. **Debug logging** - Helps troubleshoot installation issues
3. **Repository change** - Uses `vospr/dmtools` instead of `IstiN/dmtools`
4. **Enhanced error messages** - Includes local development instructions

**The two URLs you provided are the same file** - they just use different GitHub interfaces:
- `raw.githubusercontent.com` = Raw file content (for scripts)
- `github.com/.../blob/...` = Web UI (for viewing)

**Recommendation:** Keep the vospr version for your workflow since it supports local file detection, which is essential for your GitHub Actions workflow that uses files from the `releases/` directory.

---

**Last Updated:** January 2, 2026
