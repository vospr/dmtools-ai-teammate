# Workflow Comparison: ai-teammate.yml

**Date:** January 2, 2026  
**Purpose:** Compare `ai-teammate.yml` from `vospr/dmtools-ai-teammate` vs `vospr/dmtools`

---

## Overview

| Aspect | dmtools-ai-teammate | vospr/dmtools |
|--------|---------------------|---------------|
| **Repository** | `vospr/dmtools-ai-teammate` | `vospr/dmtools` |
| **File Path** | `.github/workflows/ai-teammate.yml` | `.github/workflows/ai-teammate.yml` |
| **Lines of Code** | 112 | 119 |
| **Status** | Forked/copied version | Original/reference version |

---

## Detailed Comparison

### 1. Workflow Trigger

**Both workflows are IDENTICAL:**
```yaml
on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Path to config'
        required: true
      encoded_config:
        description: 'Encoded or JSON Agent Config'
        required: false
```

✅ **No differences**

---

### 2. Permissions

**Both workflows are IDENTICAL:**
```yaml
permissions:
  contents: write
  pull-requests: write
  actions: read
```

✅ **No differences**

---

### 3. Job Configuration

**Both workflows are IDENTICAL:**
```yaml
jobs:
  cursor-agent:
    runs-on: ubuntu-latest
    concurrency:
      group: cursor-agent-${{ inputs.config_file }}
      cancel-in-progress: false
```

✅ **No differences**

---

### 4. Steps Comparison

#### Step 1: Checkout Repository

**Both workflows are IDENTICAL:**
```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

✅ **No differences**

---

#### Step 2: Setup Java Environment

**Both workflows are IDENTICAL:**
```yaml
- name: Setup Java Environment
  uses: ./.github/actions/setup-java-only
  with:
    cache-key-suffix: '-cursor'
```

✅ **No differences**

---

#### Step 3: Install Cursor CLI

**Both workflows are IDENTICAL:**
- Same installation script
- Same PATH configuration
- Same verification logic

✅ **No differences**

---

#### Step 4: Install DMTools CLI

**⚠️ DIFFERENCE FOUND:**

**dmtools-ai-teammate:**
```yaml
- name: Install DMTools CLI
  run: |
    curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

**vospr/dmtools:**
```yaml
- name: Install DMTools CLI
  run: |
    curl -fsSL https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

**Key Difference:**
- **dmtools-ai-teammate:** Uses GitHub releases URL (`/releases/latest/download/install.sh`)
- **vospr/dmtools:** Uses raw content URL (`/raw.githubusercontent.com/.../main/install.sh`)

**Impact:** 
- Releases URL requires a published release
- Raw content URL works directly from the main branch

---

#### Step 5: Build and Install DMTools CLI from source

**Both workflows are IDENTICAL:**
```yaml
- name: Build and Install DMTools CLI from source
  run: |
    dmtools || echo "dmtools version failed"
    cursor-agent --version || echo "cursor-agent version failed"
```

✅ **No differences**

---

#### Step 6: Run AI Teammate

**⚠️ MULTIPLE DIFFERENCES FOUND:**

##### 6.1 Environment Variables - MODEL

**dmtools-ai-teammate:**
```yaml
MODEL: sonnet-4.5
```

**vospr/dmtools:**
```yaml
MODEL: sonnet-4
```

**Difference:** Model version (4.5 vs 4)

---

##### 6.2 Environment Variables - Jira Configuration

**dmtools-ai-teammate:**
```yaml
# Jira Configuration
JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
```

**vospr/dmtools:**
```yaml
# Jira Configuration
JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
JIRA_AUTH_TYPE: ${{ vars.JIRA_AUTH_TYPE }}
JIRA_CLEAR_CACHE: ${{ vars.JIRA_CLEAR_CACHE }}
JIRA_EXTRA_FIELDS: ${{ vars.JIRA_EXTRA_FIELDS }}
JIRA_EXTRA_FIELDS_PROJECT: ${{ vars.JIRA_EXTRA_FIELDS_PROJECT }}
JIRA_LOGGING_ENABLED: ${{ vars.JIRA_LOGGING_ENABLED }}
JIRA_WAIT_BEFORE_PERFORM: ${{ vars.JIRA_WAIT_BEFORE_PERFORM }}
```

**Difference:** `vospr/dmtools` has **5 additional Jira configuration variables:**
- `JIRA_CLEAR_CACHE`
- `JIRA_EXTRA_FIELDS`
- `JIRA_EXTRA_FIELDS_PROJECT`
- `JIRA_LOGGING_ENABLED`
- `JIRA_WAIT_BEFORE_PERFORM`

---

##### 6.3 Environment Variables - AI Service Configuration

**dmtools-ai-teammate:**
```yaml
# AI Service Configuration
GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
DEFAULT_LLM: "gemini"
```

**vospr/dmtools:**
```yaml
# AI Service Configuration
GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
GEMINI_DEFAULT_MODEL: ${{ vars.GEMINI_DEFAULT_MODEL }}
PROMPT_CHUNK_TOKEN_LIMIT: ${{ vars.PROMPT_CHUNK_TOKEN_LIMIT }}
```

**Differences:**
- **dmtools-ai-teammate:** Uses `DEFAULT_LLM: "gemini"` (hardcoded)
- **vospr/dmtools:** Uses `GEMINI_DEFAULT_MODEL` (from vars) and adds `PROMPT_CHUNK_TOKEN_LIMIT`

---

##### 6.4 Run Command

**Both workflows are IDENTICAL:**
```yaml
run: |
  echo "Using configuration: ${{ inputs.config_file }}"
  if [ -n "${ENCODED_CONFIG}" ]; then
    echo "Encoded config received (raw):"
    printf '%s\n' "${ENCODED_CONFIG}"
    dmtools run "${{ inputs.config_file }}" "${ENCODED_CONFIG}"
  else
    echo "No encoded config provided."
    dmtools run "${{ inputs.config_file }}"
  fi
```

✅ **No differences**

---

## Summary of Differences

### Critical Differences

1. **Install DMTools CLI URL** (Line 60)
   - **dmtools-ai-teammate:** `https://github.com/IstiN/dmtools/releases/latest/download/install.sh`
   - **vospr/dmtools:** `https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh`
   - **Impact:** Releases URL requires published releases; raw URL works from main branch

2. **MODEL Version** (Line 71)
   - **dmtools-ai-teammate:** `sonnet-4.5`
   - **vospr/dmtools:** `sonnet-4`
   - **Impact:** Different AI model versions

3. **Jira Configuration Variables** (Lines 75-83)
   - **dmtools-ai-teammate:** 4 variables
   - **vospr/dmtools:** 9 variables (5 additional)
   - **Impact:** More configuration options in vospr/dmtools

4. **AI Service Configuration** (Lines 91-92 vs 96-98)
   - **dmtools-ai-teammate:** `DEFAULT_LLM: "gemini"` (hardcoded)
   - **vospr/dmtools:** `GEMINI_DEFAULT_MODEL` (from vars) + `PROMPT_CHUNK_TOKEN_LIMIT`
   - **Impact:** More flexible configuration in vospr/dmtools

---

## Recommendations

### Option 1: Update dmtools-ai-teammate to Match vospr/dmtools

**Benefits:**
- ✅ More configuration options (Jira, Gemini)
- ✅ Uses raw content URL (works without releases)
- ✅ More flexible AI model configuration

**Changes Needed:**
1. Update install.sh URL to use raw content
2. Update MODEL to `sonnet-4` (or keep 4.5 if preferred)
3. Add 5 additional Jira configuration variables
4. Replace `DEFAULT_LLM` with `GEMINI_DEFAULT_MODEL` and add `PROMPT_CHUNK_TOKEN_LIMIT`

### Option 2: Keep Current Version

**Reasons:**
- ✅ Simpler configuration (fewer variables to manage)
- ✅ Uses newer model version (sonnet-4.5)
- ✅ May be intentionally simplified for specific use case

**Considerations:**
- ⚠️ Releases URL may fail if no releases are published
- ⚠️ Less flexible configuration options

---

## Code Differences Summary

| Line | dmtools-ai-teammate | vospr/dmtools | Type |
|------|---------------------|---------------|------|
| 60 | `releases/latest/download/install.sh` | `raw.githubusercontent.com/.../main/install.sh` | URL |
| 71 | `MODEL: sonnet-4.5` | `MODEL: sonnet-4` | Model version |
| 75-78 | 4 Jira vars | 9 Jira vars | Configuration |
| 91-92 | `DEFAULT_LLM: "gemini"` | `GEMINI_DEFAULT_MODEL` + `PROMPT_CHUNK_TOKEN_LIMIT` | AI config |

---

## Conclusion

The workflows are **mostly identical** with **4 key differences**:

1. **Install script URL** - Different source (releases vs raw content)
2. **Model version** - Different AI model (4.5 vs 4)
3. **Jira configuration** - More variables in vospr/dmtools
4. **AI configuration** - More flexible in vospr/dmtools

**Recommendation:** Consider updating `dmtools-ai-teammate` to match `vospr/dmtools` for better flexibility and compatibility, especially the install.sh URL change to use raw content instead of releases.

---

**Last Updated:** January 2, 2026
