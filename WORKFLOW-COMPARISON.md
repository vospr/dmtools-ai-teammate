# Workflow Comparison: ai-teammate.yml vs learning-ai-teammate.yml

**Date:** January 2, 2026  
**Purpose:** Compare the reference workflow from `vospr/dmtools` with the current implementation

---

## Overview

| Aspect | ai-teammate.yml (vospr/dmtools) | learning-ai-teammate.yml (current) |
|--------|----------------------------------|-----------------------------------|
| **Repository** | `vospr/dmtools` | `vospr/dmtools-ai-teammate` |
| **Purpose** | Generic AI teammate using config files | Specific learning questions workflow |
| **Approach** | Uses `dmtools run` with agent config | Step-by-step CLI commands |
| **Complexity** | Simple (delegates to dmtools) | Detailed (explicit steps) |
| **Dependencies** | Cursor CLI + dmtools | dmtools only |

---

## Detailed Comparison

### 1. Workflow Trigger

**ai-teammate.yml:**
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

**learning-ai-teammate.yml:**
```yaml
on:
  workflow_dispatch:
    inputs:
      ticket_key:
        description: 'Jira ticket key to process (e.g., ATL-2)'
        required: true
        type: string
      config_file:
        description: 'Path to agent config (relative to repo root)'
        required: false
        type: string
        default: 'agents/learning_questions.json'
```

**Key Differences:**
- `ai-teammate.yml`: Generic - accepts any config file path
- `learning-ai-teammate.yml`: Specific - requires ticket_key, config_file is optional with default

---

### 2. Installation Approach

**ai-teammate.yml:**
```yaml
- name: Install DMTools CLI
  run: |
    curl -fsSL https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

**learning-ai-teammate.yml:**
```yaml
- name: Install dmtools CLI
  env:
    DMTOOLS_LOCAL_SOURCE: ${{ github.workspace }}/releases
  run: |
    # Extensive verification and local file detection
    # Uses local install.sh and local JAR/script files
    # Multiple fallback methods
```

**Key Differences:**
- `ai-teammate.yml`: Simple - downloads from GitHub releases
- `learning-ai-teammate.yml`: Complex - prefers local files, extensive verification, fallback methods

---

### 3. Execution Model

**ai-teammate.yml:**
```yaml
- name: Run AI Teammate
  run: |
    if [ -n "${ENCODED_CONFIG}" ]; then
      dmtools run "${{ inputs.config_file }}" "${ENCODED_CONFIG}"
    else
      dmtools run "${{ inputs.config_file }}"
    fi
```

**learning-ai-teammate.yml:**
```yaml
# Multiple explicit steps:
- Get Ticket Information
- Build AI Prompt
- Call Gemini AI
- Parse Questions
- Create Sub-tickets
- Add Label
```

**Key Differences:**
- `ai-teammate.yml`: **Delegates to dmtools** - uses `dmtools run` with config file
- `learning-ai-teammate.yml`: **Explicit steps** - calls dmtools CLI commands directly

---

### 4. Error Handling

**ai-teammate.yml:**
- Minimal error handling
- Relies on dmtools internal error handling
- No fallback methods

**learning-ai-teammate.yml:**
- Extensive error handling:
  - Multiple JSON extraction fallback methods (jq → grep → Python)
  - Robust variable substitution (envsubst → awk)
  - Windows line ending fixes
  - Debug output and validation at each step

---

### 5. Dependencies

**ai-teammate.yml:**
- ✅ Cursor CLI (`cursor-agent`)
- ✅ dmtools CLI
- ✅ Java (via reusable action)

**learning-ai-teammate.yml:**
- ✅ dmtools CLI only
- ✅ Java 23
- ❌ No Cursor CLI dependency

---

### 6. Configuration

**ai-teammate.yml:**
- Uses agent config files (JSON)
- Supports encoded config
- More flexible - can run any agent config

**learning-ai-teammate.yml:**
- Hardcoded prompt template
- Specific to learning questions use case
- Less flexible but more explicit

---

### 7. Permissions

**ai-teammate.yml:**
```yaml
permissions:
  contents: write
  pull-requests: write
  actions: read
```

**learning-ai-teammate.yml:**
```yaml
permissions:
  contents: read
  actions: read
```

**Key Differences:**
- `ai-teammate.yml`: Can create PRs and modify contents (for Cursor agent)
- `learning-ai-teammate.yml`: Read-only (only processes tickets)

---

## Advantages of Each Approach

### ai-teammate.yml Advantages

1. **Simplicity:** Much simpler - delegates to dmtools
2. **Flexibility:** Can run any agent config file
3. **Maintainability:** Less code to maintain
4. **Reusability:** Works with any agent configuration
5. **Uses dmtools features:** Leverages `dmtools run` command

### learning-ai-teammate.yml Advantages

1. **Explicitness:** Clear step-by-step process
2. **Error Handling:** Robust fallback methods
3. **Debugging:** Extensive logging and validation
4. **No External Dependencies:** Doesn't require Cursor CLI
5. **Local File Support:** Uses local dmtools files from repository
6. **Specific Use Case:** Optimized for learning questions workflow

---

## Recommendations

### Option 1: Migrate to ai-teammate.yml Approach (Recommended for Flexibility)

**Benefits:**
- ✅ Simpler workflow file
- ✅ Can reuse for other agent configs
- ✅ Less maintenance
- ✅ Uses dmtools built-in features

**Requirements:**
- Need to create proper agent config file (`agents/learning_questions.json`)
- Need to ensure `dmtools run` command works correctly
- May need Cursor CLI (if required by agent config)

**Migration Steps:**
1. Create/verify `agents/learning_questions.json` config file
2. Test `dmtools run agents/learning_questions.json` locally
3. Simplify workflow to use `dmtools run` approach
4. Keep error handling improvements if needed

### Option 2: Keep learning-ai-teammate.yml (Recommended for Current Use Case)

**Benefits:**
- ✅ Already working with extensive error handling
- ✅ No Cursor CLI dependency
- ✅ Explicit and debuggable
- ✅ Optimized for specific use case

**Improvements to Consider:**
- Extract common patterns to reusable actions
- Add support for config file parameter (like ai-teammate.yml)
- Consider using `dmtools run` for some steps if it simplifies code

### Option 3: Hybrid Approach

**Combine best of both:**
- Use `dmtools run` for main execution (like ai-teammate.yml)
- Keep robust error handling from learning-ai-teammate.yml
- Add config file support while keeping ticket_key input
- Remove Cursor CLI dependency if not needed

---

## Code Comparison

### Installation Step

**ai-teammate.yml (Simple):**
```yaml
- name: Install DMTools CLI
  run: |
    curl -fsSL https://raw.githubusercontent.com/IstiN/dmtools/main/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH
```

**learning-ai-teammate.yml (Complex):**
```yaml
- name: Install dmtools CLI
  env:
    DMTOOLS_LOCAL_SOURCE: ${{ github.workspace }}/releases
  run: |
    # 50+ lines of verification, local file detection, fallback methods
```

### Execution Step

**ai-teammate.yml (Simple):**
```yaml
- name: Run AI Teammate
  run: |
    dmtools run "${{ inputs.config_file }}" "${ENCODED_CONFIG}"
```

**learning-ai-teammate.yml (Complex):**
```yaml
# 6 separate steps:
- Get Ticket Information (30+ lines)
- Build AI Prompt (50+ lines)
- Call Gemini AI
- Parse Questions
- Create Sub-tickets (40+ lines)
- Add Label
```

---

## Conclusion

**Current State:**
- `learning-ai-teammate.yml` is more explicit and has better error handling
- `ai-teammate.yml` is simpler and more flexible

**Recommendation:**
- **For now:** Keep `learning-ai-teammate.yml` as it's working and has robust error handling
- **Future:** Consider migrating to `dmtools run` approach if you want to support multiple agent configs
- **Best of both:** Extract error handling patterns and consider using `dmtools run` for main execution while keeping explicit steps for debugging

---

## Next Steps

1. ✅ **Current workflow is working** - Keep it as is
2. 🔄 **Consider:** Test if `dmtools run agents/learning_questions.json` works for your use case
3. 🔄 **Consider:** Create reusable GitHub Actions for common patterns
4. 📝 **Document:** Keep both approaches documented for future reference
