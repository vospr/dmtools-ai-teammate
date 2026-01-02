# Troubleshooting Guide - AI Teammate System

Comprehensive troubleshooting guide for common issues in the DMTools AI Teammate system.

## Overview

This guide covers:
- ✅ Common issues at each layer
- ✅ Diagnostic commands
- ✅ Step-by-step solutions
- ✅ Prevention strategies

---

## Troubleshooting Framework

### The Five Layers

```
┌─────────────────────────────────────────────────────────┐
│ Layer 5: Jira Results (Sub-tickets, Labels)            │
│ Layer 4: JavaScript Actions (createQuestionsSimple.js) │
│ Layer 3: AI Processing (Gemini API)                    │
│ Layer 2: Integration (dmtools CLI, APIs)               │
│ Layer 1: Infrastructure (Credentials, Network)         │
└─────────────────────────────────────────────────────────┘
```

**Debugging Strategy:**
1. Start at Layer 1 (infrastructure)
2. Work up through layers
3. Verify each layer before moving up

---

## Layer 1: Infrastructure Issues

### Issue 1.1: Credentials Not Working

**Symptoms:**
```
Error: 401 Unauthorized
Error: Authentication failed
Error: Invalid API key
```

**Diagnosis:**
```powershell
# Test Jira credentials
curl -u "your@email.com:YOUR_TOKEN" \
  "https://yourcompany.atlassian.net/rest/api/3/myself"

# Test Gemini API key
curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_KEY"

# Check environment variables (GitHub Actions)
echo $JIRA_EMAIL
echo $JIRA_BASE_PATH
```

**Solutions:**

**For Jira:**
1. Verify email matches Atlassian account
2. Regenerate API token: [https://id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
3. Check for extra spaces when copying token
4. Ensure base path has NO trailing slash

**For Gemini:**
1. Verify key starts with `AIza`
2. Check key is enabled in Google Cloud Console
3. Ensure billing is set up (even for free tier)

### Issue 1.2: Network Connectivity

**Symptoms:**
```
Error: ECONNREFUSED
Error: Connection timed out
Error: Network is unreachable
```

**Diagnosis:**
```powershell
# Test connectivity
Test-NetConnection -ComputerName yourcompany.atlassian.net -Port 443
Test-NetConnection -ComputerName generativelanguage.googleapis.com -Port 443

# Check firewall
ping yourcompany.atlassian.net
```

**Solutions:**
1. Check corporate firewall settings
2. Verify VPN is connected (if required)
3. Check proxy settings
4. Contact IT if ports are blocked

### Issue 1.3: dmtools CLI Not Found

**Symptoms:**
```
dmtools: command not found
'dmtools' is not recognized as an internal or external command
```

**Diagnosis:**
```powershell
# Check if dmtools exists
which dmtools
Get-Command dmtools

# Check PATH
$env:PATH -split ';' | Select-String "dmtools"
```

**Solutions:**

**Windows:**
```powershell
# Add to PATH temporarily
$env:PATH += ";c:\Users\AndreyPopov\dmtools"

# Add permanently via System Properties
# Control Panel → System → Advanced → Environment Variables
```

**Linux/Mac (GitHub Actions):**
```bash
export PATH="$HOME/.dmtools/bin:$PATH"
```

---

## Layer 2: Integration Issues

### Issue 2.1: dmtools Cannot Load Configuration

**Symptoms:**
```
Error: JIRA_BASE_PATH not set
Error: Required environment variable missing
```

**Diagnosis:**
```powershell
# Check if dmtools.env exists
Test-Path "c:\Users\AndreyPopov\dmtools\dmtools.env"

# Check environment variables are loaded
dmtools --help
```

**Solutions:**

**Local (PowerShell):**
```powershell
# Load environment variables manually
Get-Content "c:\Users\AndreyPopov\dmtools\dmtools.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}
```

**GitHub Actions:**
```yaml
# Ensure env vars are set in workflow
env:
  JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
  JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
  JIRA_BASE_PATH: ${{ vars.JIRA_BASE_PATH }}
```

### Issue 2.2: Jira API Errors

**Error: "Field 'issuetype' is invalid"**

**Cause:** Sub-task issue type name doesn't match

**Solution:**
```powershell
# List issue types for your project
dmtools jira_get_issue_types ATL

# Use exact name (might be "Sub-task", "Subtask", or "Sub Task")
```

**Error: "Field 'priority' is invalid"**

**Cause:** Priority name doesn't match Jira's priority scheme

**Solution:**
```powershell
# List available priorities
dmtools jira_get_priorities

# Use exact names: "Highest", "High", "Medium", "Low", "Lowest"
```

**Error: "Parent issue not found"**

**Cause:** Ticket key is wrong or parent doesn't exist

**Solution:**
```powershell
# Verify parent ticket exists
dmtools jira_get_ticket ATL-2
```

### Issue 2.3: GitHub Actions Workflow Not Triggering

**Symptoms:**
- Jira automation runs but GitHub workflow doesn't start
- No workflow runs appear in Actions tab

**Diagnosis:**
```bash
# Check workflow file syntax
cat .github/workflows/learning-ai-teammate.yml

# Test webhook manually
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ghp_YOUR_TOKEN" \
  "https://api.github.com/repos/YOUR_ORG/REPO/actions/workflows/learning-ai-teammate.yml/dispatches" \
  -d '{"ref":"main","inputs":{"ticket_key":"ATL-2"}}'
```

**Solutions:**
1. Verify workflow file name matches webhook URL
2. Check branch name (`main` vs `master`)
3. Ensure GitHub token has `workflow` scope
4. Check GitHub Actions is enabled for repository

---

## Layer 3: AI Processing Issues

### Issue 3.1: Gemini Returns No JSON

**Symptoms:**
```
❌ No JSON array found in response
AI response: "Sure, I'd be happy to help! Here are some questions..."
```

**Cause:** AI didn't follow output format instructions

**Solutions:**

**Improve prompt:**
```
CRITICAL: Your response must be ONLY a JSON array. No other text.

Example:
[{"summary":"...", "priority":"High", "description":"..."}]

If no questions needed, output: []

Start JSON array now:
```

**Use explicit JSON mode (if supported):**
```json
{
  "model": "gemini-2.0-flash-exp",
  "response_mime_type": "application/json"
}
```

### Issue 3.2: Invalid JSON in Response

**Symptoms:**
```
❌ Invalid JSON
Error: Unexpected token at position 45
```

**Common JSON errors:**
```json
// ❌ Trailing comma
[{"summary":"Q1","priority":"High"},]

// ✅ No trailing comma
[{"summary":"Q1","priority":"High"}]

// ❌ Unescaped quotes
{"description": "Use "quotes" carefully"}

// ✅ Escaped quotes
{"description": "Use \"quotes\" carefully"}
```

**Solutions:**

**Manual cleanup script:**
```powershell
$response = Get-Content "outputs/response.md" -Raw

# Remove markdown code blocks
$cleaned = $response -replace '```json', '' -replace '```', ''

# Remove trailing commas before } or ]
$cleaned = $cleaned -replace ',(\s*[\]}])', '$1'

# Try parsing
$cleaned | ConvertFrom-Json
```

### Issue 3.3: AI Generates Too Many Questions

**Symptoms:**
- AI generates 10+ questions
- Questions are too generic

**Solutions:**

**Update prompt to be more specific:**
```
Generate 2-5 CRITICAL questions only.
Focus on:
- Missing functional requirements
- Unclear acceptance criteria
- Technical constraints not specified

Skip questions about:
- General best practices
- Standard implementation details
- Obvious requirements
```

**Add filtering in post-processing:**
```javascript
// Filter to top 5 by priority
questions = questions
  .sort((a, b) => priorityScore(b.priority) - priorityScore(a.priority))
  .slice(0, 5);
```

---

## Layer 4: JavaScript Action Issues

### Issue 4.1: Action Syntax Errors

**Symptoms:**
```
SyntaxError: Unexpected token
ReferenceError: jira_create_ticket_with_json is not defined
```

**Diagnosis:**
```javascript
// Test JavaScript locally
node createQuestionsSimple.js
```

**Solutions:**
1. Check for typos in function names
2. Ensure dmtools functions are available in execution context
3. Verify JSON.parse() is used correctly

### Issue 4.2: Sub-tickets Not Created

**Symptoms:**
- Script runs without errors
- But no sub-tickets appear in Jira

**Debug logging:**
```javascript
function processQuestionTickets(response, parentKey) {
    console.log('=== DEBUG: Process Questions ===');
    console.log('Response length:', response.length);
    console.log('Parent key:', parentKey);
    
    const questions = parseQuestionsResponse(response);
    console.log('Parsed questions:', questions.length);
    
    questions.forEach((q, i) => {
        console.log(`Question ${i+1}:`, JSON.stringify(q));
    });
    
    // ... rest of function
}
```

**Check dmtools command:**
```javascript
// Log actual command being executed
console.log('Creating ticket with command:');
console.log('dmtools jira_create_ticket_with_json', JSON.stringify(params));
```

### Issue 4.3: Priority/Fields Not Set

**Symptoms:**
- Sub-tickets created but have wrong priority
- Custom fields missing

**Solution:**
```javascript
// Ensure field names match Jira exactly
const fieldsJson = {
    summary: summary,
    description: description,
    issuetype: { name: 'Sub-task' }, // Case-sensitive!
    parent: { key: parentKey },
    priority: { name: 'High' } // Must be exact Jira priority name
};
```

---

## Layer 5: Jira Results Issues

### Issue 5.1: Labels Not Added

**Symptoms:**
- Workflow completes successfully
- But label not visible in Jira

**Diagnosis:**
```powershell
# Check if label exists
dmtools jira_get_ticket ATL-2 | ConvertFrom-Json | Select-Object -ExpandProperty fields | Select-Object -ExpandProperty labels
```

**Solutions:**
1. Verify label name matches exactly (case-sensitive)
2. Check user has permission to add labels
3. Wait 30 seconds and refresh Jira (caching)

### Issue 5.2: Ticket Not Assigned

**Symptoms:**
- Workflow says "assigned for review"
- But ticket still shows old assignee

**Diagnosis:**
```powershell
# Check current assignee
dmtools jira_get_ticket ATL-2 | ConvertFrom-Json | Select-Object -ExpandProperty fields | Select-Object -ExpandProperty assignee
```

**Solutions:**
1. Verify account ID is correct
2. Check user is active in Jira
3. Ensure user has access to the project

---

## Common Workflow Errors

### Error: "GitHub Actions: 'dmtools': command not found"

**Full error:**
```
/home/runner/work/_temp/xxx.sh: line 5: dmtools: command not found
```

**Solution:**
```yaml
# Add PATH export before using dmtools
- name: Install dmtools
  run: |
    curl -fsSL https://github.com/IstiN/dmtools/releases/latest/download/install.sh | bash
    echo "$HOME/.dmtools/bin" >> $GITHUB_PATH

# Then in subsequent steps:
- name: Use dmtools
  run: |
    export PATH="$HOME/.dmtools/bin:$PATH"
    dmtools --version
```

### Error: "Jira automation: Webhook returned 422"

**Full error:**
```
Web request failed
Status: 422
Message: Workflow not found
```

**Causes:**
1. Workflow filename doesn't match URL
2. Workflow is in wrong branch
3. Workflow file has syntax errors

**Solution:**
```bash
# Verify workflow file exists
ls -la .github/workflows/learning-ai-teammate.yml

# Check workflow is valid
cat .github/workflows/learning-ai-teammate.yml | grep "name:"

# Ensure file is pushed to correct branch
git branch
git log --oneline -5
```

---

## Performance Issues

### Issue: Workflow Takes Too Long

**Symptoms:**
- Workflow takes 5+ minutes
- Times out before completion

**Optimizations:**

**1. Cache dependencies:**
```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '11'
    cache: 'gradle' # Cache Gradle dependencies
```

**2. Reduce AI context:**
- Send only ticket description, not full history
- Limit token count in prompt

**3. Parallel execution:**
```yaml
jobs:
  process-question-1:
    runs-on: ubuntu-latest
    steps: [...]
  
  process-question-2:
    runs-on: ubuntu-latest
    steps: [...]
```

---

## Debugging Tools

### Tool 1: Verbose Logging

**Enable in workflow:**
```yaml
- name: Run with debug logging
  env:
    ACTIONS_STEP_DEBUG: true
    ACTIONS_RUNNER_DEBUG: true
  run: |
    set -x # Enable bash debugging
    dmtools jira_get_ticket ATL-2
```

### Tool 2: Artifact Inspection

**Download artifacts after workflow:**
```yaml
- name: Upload debug artifacts
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: debug-logs
    path: |
      *.log
      *.json
      *.md
```

### Tool 3: Manual Step Execution

**Test individual steps locally:**
```powershell
# Step 1: Get ticket
$ticket = dmtools jira_get_ticket ATL-2
$ticket | Out-File "ticket.json"

# Step 2: Build prompt
$prompt = "..."
$prompt | Out-File "prompt.txt"

# Step 3: Call AI
$response = dmtools gemini_ai_chat (Get-Content "prompt.txt" -Raw)
$response | Out-File "response.md"

# Step 4: Parse JSON
$json = (Get-Content "response.md" -Raw) -match '\[[\s\S]*\]'
$questions = $matches[0] | ConvertFrom-Json

# Step 5: Create sub-ticket
# ... etc
```

---

## Prevention Strategies

### 1. Input Validation

**Validate before processing:**
```javascript
function validateQuestion(question) {
    if (!question.summary || question.summary.length > 120) {
        throw new Error('Invalid summary');
    }
    if (!['Highest','High','Medium','Low','Lowest'].includes(question.priority)) {
        throw new Error('Invalid priority');
    }
    if (!question.description) {
        throw new Error('Missing description');
    }
    return true;
}
```

### 2. Health Checks

**Add health check step to workflow:**
```yaml
- name: Health Check
  run: |
    echo "Checking dmtools..."
    dmtools --version || exit 1
    
    echo "Checking Jira..."
    dmtools jira_get_current_user || exit 1
    
    echo "Checking Gemini..."
    dmtools gemini_ai_chat "test" || exit 1
```

### 3. Rate Limiting

**Prevent API overuse:**
```javascript
// Add delay between API calls
async function createWithDelay(ticket, delay) {
    await new Promise(resolve => setTimeout(resolve, delay));
    return jira_create_ticket_with_json(ticket);
}
```

### 4. Retry Logic

**Retry failed API calls:**
```javascript
function retryOnFailure(fn, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            return fn();
        } catch (error) {
            if (i === maxRetries - 1) throw error;
            console.log(`Retry ${i+1}/${maxRetries}...`);
            // Wait before retry (exponential backoff)
            sleep(Math.pow(2, i) * 1000);
        }
    }
}
```

---

## Emergency Procedures

### Procedure 1: Disable Automation

**If automation is creating too many tickets or errors:**

1. Go to Jira → Project Settings → Automation
2. Find rule: "AI Teammate - Generate Clarifying Questions"
3. Toggle switch to **OFF**
4. Add label `ai_disabled` to prevent manual triggers

### Procedure 2: Rollback Workflow

**If workflow is broken:**

```bash
# Revert to previous working version
git revert HEAD
git push origin main

# Or temporarily disable workflow
mv .github/workflows/learning-ai-teammate.yml \
   .github/workflows/learning-ai-teammate.yml.disabled
git commit -m "Temporarily disable AI teammate"
git push
```

### Procedure 3: Clean Up Failed Tickets

**If many invalid sub-tickets were created:**

```powershell
# Search for AI-generated sub-tickets
$tickets = dmtools jira_search_by_jql "parent = ATL-2 AND created > -1d" "key"

# Review and delete if needed
# (Be careful! Deletion is permanent)
```

---

## Getting Help

### Where to Look

1. **GitHub Actions logs:** Most detailed information
2. **Jira automation audit log:** Webhook responses
3. **dmtools documentation:** `c:\Users\AndreyPopov\dmtools\docs\`
4. **This guide:** Common issues and solutions

### Information to Collect

When asking for help, provide:
- Ticket key being processed
- Error message (exact text)
- GitHub Actions workflow run URL
- Jira automation audit log entry
- dmtools version: `dmtools --version`

---

## Success Criteria

Your setup is fully working if:

- [ ] ✅ All credentials are valid
- [ ] ✅ dmtools CLI works in all environments
- [ ] ✅ Jira API calls succeed
- [ ] ✅ Gemini API responds with valid JSON
- [ ] ✅ Sub-tickets are created correctly
- [ ] ✅ Labels are added
- [ ] ✅ No errors in GitHub Actions logs
- [ ] ✅ No errors in Jira automation logs

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [07-jira-automation-setup.md](07-jira-automation-setup.md)  
**Next Step:** [00-learning-summary.md](00-learning-summary.md)

