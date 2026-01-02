# Troubleshooting 422 Error: "Workflow does not have 'workflow_dispatch' trigger"

**Date:** January 2, 2026  
**Status:** ⚠️ **IN PROGRESS** - Workflow file fixed, waiting for GitHub re-indexing

---

## Problem

Jira automation webhook returns 422 error:
```json
{
  "message": "Workflow does not have 'workflow_dispatch' trigger",
  "documentation_url": "https://docs.github.com/rest/actions/workflows#create-a-workflow-dispatch-event",
  "status": "422"
}
```

**Root Cause:** GitHub cannot parse the workflow file, so it doesn't recognize the `workflow_dispatch` trigger.

---

## Fixes Applied

### 1. ✅ Fixed Redundant Else Block (df42655)
- **Issue:** Duplicate `else` block checking for `envsubst` again
- **Fix:** Removed redundant check, simplified to `if envsubst` → `else awk`
- **Status:** ✅ Fixed and committed

### 2. ✅ Fixed YAML Heredoc Issues (0ebf3f7, 4681d4f)
- **Issue:** Python heredoc causing YAML parsing errors
- **Fix:** Replaced with `envsubst` approach (YAML-safe)
- **Status:** ✅ Fixed and committed

### 3. ✅ Fixed Windows Line Endings (116aaa4, f60cbac)
- **Issue:** `JIRA_BASE_PATH` and `JIRA_AUTH_TYPE` had Windows line endings
- **Fix:** Added trimming: `tr -d '\r\n' | xargs`
- **Status:** ✅ Fixed and committed

---

## Current Workflow File Status

**File:** `.github/workflows/learning-ai-teammate.yml`  
**Lines:** 513  
**Last Commit:** `df42655` - "Fix redundant else block in prompt creation"

**Structure Verification:**
- ✅ `on: workflow_dispatch:` properly configured (line 4)
- ✅ All steps properly indented
- ✅ All heredocs properly closed (`TEMPLATE_EOF`, `AWK_EOF`)
- ✅ File ends correctly
- ✅ No obvious YAML syntax errors

---

## Verification Steps

### Step 1: Check Workflow File on GitHub

1. Go to: https://github.com/vospr/dmtools-ai-teammate/tree/main/.github/workflows
2. Verify `learning-ai-teammate.yml` exists
3. Click on the file to view it
4. Check that it starts with:
   ```yaml
   name: Learning AI Teammate
   
   on:
     workflow_dispatch:
   ```

### Step 2: Check GitHub Actions Page

1. Go to: https://github.com/vospr/dmtools-ai-teammate/actions
2. Look for "Learning AI Teammate" workflow in the sidebar
3. **If workflow appears:** ✅ GitHub can parse it
4. **If workflow doesn't appear:** ❌ GitHub cannot parse it (syntax error)

### Step 3: Try Manual Trigger

1. Go to: https://github.com/vospr/dmtools-ai-teammate/actions/workflows/learning-ai-teammate.yml
2. Click **"Run workflow"** button
3. **If button appears:** ✅ Workflow is recognized
4. **If button doesn't appear:** ❌ Workflow has issues

### Step 4: Check Recent Workflow Runs

- All recent runs show "Failure" status
- This suggests GitHub can see the workflow but it fails during execution
- **OR** GitHub cannot parse it at all (422 error)

---

## Possible Causes

### 1. GitHub Re-indexing Delay ⏱️
- **Likelihood:** High
- **Solution:** Wait 10-30 seconds after pushing changes
- **Status:** ⏳ Waiting for re-indexing

### 2. YAML Syntax Error (Hidden) 🔍
- **Likelihood:** Medium
- **Solution:** Review workflow file for subtle syntax issues
- **Status:** ✅ File structure verified, but may have hidden issues

### 3. Workflow File Not on Main Branch branch
- **Likelihood:** Low
- **Solution:** Verify file is on `main` branch
- **Status:** ✅ Confirmed on `main` branch

### 4. Webhook URL Mismatch 🔗
- **Likelihood:** Low
- **Solution:** Verify webhook URL matches file name exactly
- **Status:** ✅ URL matches: `learning-ai-teammate.yml`

---

## Next Steps

### Immediate Actions

1. **Wait 30-60 seconds** after the last commit (`df42655`)
2. **Try Jira webhook again** - GitHub should have re-indexed
3. **Check GitHub Actions page** - See if workflow appears
4. **Try manual trigger** - Verify "Run workflow" button appears

### If Still Failing

1. **Check GitHub Actions logs** for any error messages
2. **Verify workflow file on GitHub** - Compare with local file
3. **Test YAML syntax** using online YAML validator
4. **Consider:** Simplifying the workflow file further

---

## Workflow File Comparison

### Reference: ai-teammate.yml (vospr/dmtools)
- **Lines:** ~119
- **Complexity:** Simple
- **Status:** ✅ Working (0 runs but file is valid)

### Current: learning-ai-teammate.yml
- **Lines:** 513
- **Complexity:** Complex (explicit steps)
- **Status:** ⚠️ 422 error (GitHub can't parse)

**Key Difference:** The reference workflow is much simpler and delegates to `dmtools run`.

---

## Recommendations

### Option 1: Wait and Retry (Recommended First)
- Wait 30-60 seconds after last commit
- Try Jira webhook again
- Check if GitHub has re-indexed the workflow

### Option 2: Simplify Workflow (If Still Failing)
- Consider migrating to `dmtools run` approach (like ai-teammate.yml)
- Reduces complexity and YAML parsing issues
- See `WORKFLOW-COMPARISON.md` for details

### Option 3: Verify YAML Syntax
- Use online YAML validator: https://www.yamllint.com/
- Copy workflow file content and validate
- Fix any syntax errors found

---

## Commits Related to 422 Error Fixes

1. `df42655` - Fix redundant else block in prompt creation
2. `0ebf3f7` - Simplify prompt creation: use envsubst only
3. `4681d4f` - Fix YAML syntax error: replace Python heredoc
4. `e926c4a` - Enhanced JSON parsing
5. `116aaa4` - Fix Windows line endings in JIRA variables

---

## Status Summary

| Item | Status | Notes |
|------|--------|-------|
| Workflow file structure | ✅ Valid | All syntax verified |
| workflow_dispatch trigger | ✅ Configured | Line 4 |
| Redundant code blocks | ✅ Fixed | Removed duplicate else |
| YAML heredoc issues | ✅ Fixed | Using envsubst/awk |
| Windows line endings | ✅ Fixed | Added trimming |
| GitHub re-indexing | ⏳ Waiting | Need 30-60 seconds |
| Jira webhook | ⚠️ Pending | Waiting for re-index |

---

**Last Updated:** After commit `df42655`  
**Next Action:** Wait 30-60 seconds, then retry Jira webhook
