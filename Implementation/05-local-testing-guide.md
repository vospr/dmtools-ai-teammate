# Local Testing Guide for AI Teammate Agent

This guide will walk you through testing your AI teammate agent locally before setting up GitHub Actions automation.

## Overview

**What We'll Test:**
- ✅ Agent configuration is valid
- ✅ AI can generate clarifying questions
- ✅ Questions are created as Jira sub-tickets
- ✅ Labels are added correctly
- ✅ JavaScript post-action works

**Testing Approach:**
We'll use **dmtools CLI directly** instead of Cursor CLI for simplicity in this learning setup.

---

## Prerequisites

Before testing, ensure you have:

- [ ] dmtools CLI installed and working
- [ ] `dmtools.env` configured with all credentials
- [ ] ATL project created in Jira with test tickets
- [ ] At least one "vague requirements" ticket (e.g., ATL-2)
- [ ] Agent configuration file created: `learning_questions.json`
- [ ] JavaScript action created: `createQuestionsSimple.js`

---

## Testing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Local Testing Flow                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Prepare Input                                           │
│     ├─ Read ticket from Jira (dmtools)                      │
│     ├─ Create instructions file                             │
│     └─ Set up test directory structure                      │
│                                                             │
│  2. AI Processing                                           │
│     ├─ Send ticket + instructions to Gemini                 │
│     ├─ Gemini analyzes requirements                         │
│     └─ Gemini generates JSON array of questions             │
│                                                             │
│  3. Parse Response                                          │
│     ├─ Read outputs/response.md                             │
│     ├─ Extract JSON array                                   │
│     └─ Validate question format                             │
│                                                             │
│  4. Create Sub-tickets                                      │
│     ├─ For each question in JSON array                      │
│     ├─ Create Jira sub-ticket                               │
│     └─ Link to parent ticket                                │
│                                                             │
│  5. Post-Processing                                         │
│     ├─ Add "ai_questions_asked" label                       │
│     ├─ Assign ticket for review                             │
│     └─ Return summary                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 1: Prepare Test Directory Structure

Create a working directory for your test:

```powershell
# Create test directory
New-Item -ItemType Directory -Path "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\test-run" -Force

cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\test-run"

# Create subdirectories
New-Item -ItemType Directory -Path "input" -Force
New-Item -ItemType Directory -Path "outputs" -Force
```

**Directory structure:**
```
test-run/
├── input/              # Input files for AI
│   ├── ticket-info.txt
│   └── instructions.md
├── outputs/            # AI-generated output
│   └── response.md
└── test-log.txt        # Testing log
```

---

## Step 2: Get Ticket Data from Jira

Retrieve the test ticket you want to process:

```powershell
# Replace ATL-2 with your actual test ticket key
$ticketKey = "ATL-2"

# Verify dmtools authentication first (optional but recommended)
Write-Host "Verifying Jira authentication..." -ForegroundColor Yellow
try {
    $currentUser = dmtools jira_get_my_profile | ConvertFrom-Json
    Write-Host "✅ Authenticated as: $($currentUser.displayName) ($($currentUser.emailAddress))" -ForegroundColor Green
} catch {
    Write-Host "❌ Authentication failed. Check your dmtools.env credentials." -ForegroundColor Red
    exit 1
}

# Get ticket data
Write-Host "`nRetrieving ticket: $ticketKey..." -ForegroundColor Yellow
try {
    $ticketData = dmtools jira_get_ticket $ticketKey
    
    # Save to file for reference
    $ticketData | Out-File "input/ticket-raw.json" -Encoding UTF8
    Write-Host "✅ Ticket data saved to input/ticket-raw.json" -ForegroundColor Green
    
    # Parse and display key info
    $ticket = $ticketData | ConvertFrom-Json
    Write-Host "`n=== Ticket Information ===" -ForegroundColor Cyan
    Write-Host "Key: $($ticket.key)" -ForegroundColor White
    Write-Host "Summary: $($ticket.fields.summary)" -ForegroundColor White
    Write-Host "Type: $($ticket.fields.issuetype.name)" -ForegroundColor White
    Write-Host "Status: $($ticket.fields.status.name)" -ForegroundColor White
    Write-Host "Priority: $($ticket.fields.priority.name)" -ForegroundColor White
    if ($ticket.fields.description) {
        $descPreview = $ticket.fields.description -replace '<[^>]+>', '' | Select-Object -First 1
        Write-Host "Description preview: $($descPreview.Substring(0, [Math]::Min(100, $descPreview.Length)))..." -ForegroundColor Gray
    }
    Write-Host "========================`n" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Failed to retrieve ticket: $_" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

**Expected Output:**
```
Verifying Jira authentication...
✅ Authenticated as: Andrey (andrey_popov@epam.com)

Retrieving ticket: ATL-2...
✅ Ticket data saved to input/ticket-raw.json

=== Ticket Information ===
Key: ATL-2
Summary: [Your ticket summary]
Type: Task
Status: To Do
Priority: Medium
Description preview: [First 100 chars of description]...
========================
```

**Troubleshooting:**

- **If authentication fails:**
  - Verify `dmtools.env` exists and contains valid `JIRA_API_TOKEN` and `JIRA_EMAIL`
  - Check that `JIRA_AUTH_TYPE=basic` (lowercase is fine - it's normalized automatically)
  - Run `dmtools jira_get_my_profile` to test authentication

- **If ticket retrieval fails:**
  - Verify the ticket key exists (e.g., `ATL-2`)
  - Check you have permission to view the ticket
  - Verify the project key matches (e.g., `ATL`)

- **If JSON parsing fails:**
  - Check that `dmtools` returned valid JSON
  - View `input/ticket-raw.json` to see the raw response

---

## Step 3: Create Instructions File

Create an instructions file that the AI will read:

**File:** `input/instructions.md`

```markdown
# AI Teammate Task: Generate Clarifying Questions

## Your Role
You are an Experienced Business Analyst with expertise in requirements analysis.

## Task
Analyze the Jira ticket below and generate clarifying questions for any unclear, vague, or ambiguous requirements.

## Ticket Information
**Key:** ATL-2
**Summary:** [Ticket summary will be here]
**Description:**
[Ticket description will be here]

## Instructions
1. Read the ticket description carefully
2. Identify vague terms, missing information, or ambiguous statements
3. Generate 2-5 specific, actionable clarifying questions
4. For each question, consider:
   - Functional requirements
   - Technical constraints
   - Acceptance criteria
   - Edge cases
   - Dependencies

## Output Format
You MUST output a valid JSON array to this file. Each question must be an object with:
- **summary** (string, max 120 characters): Short question summary
- **priority** (string): One of "Highest", "High", "Medium", "Low", "Lowest"
- **description** (string): Detailed question in Jira markdown format

## Example Output
```json
[
  {
    "summary": "What user roles can access this feature?",
    "priority": "High",
    "description": "The story mentions users but doesn't specify:\n* Which user roles should have access?\n* Are there any role-based permission differences?\n* Should admins have different capabilities?"
  },
  {
    "summary": "What is the expected error handling behavior?",
    "priority": "Medium",
    "description": "Please clarify:\n* What happens if the API call fails?\n* Should there be retry logic?\n* What error messages should users see?"
  }
]
```

## Important
- If requirements are perfectly clear, output: []
- Ensure JSON is valid (no trailing commas!)
- Keep descriptions concise but specific
- Write output to: outputs/response.md
```

Save this to: `c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\test-run\input\instructions.md`

---

## Step 4: Manually Build Complete Prompt

For testing, we'll build the complete prompt manually:

```powershell
# Get ticket info
$ticket = dmtools jira_get_ticket ATL-2 | ConvertFrom-Json

# Build prompt
$prompt = @"
You are an Experienced Business Analyst analyzing Jira tickets.

TICKET TO ANALYZE:
Key: $($ticket.key)
Summary: $($ticket.fields.summary)
Description:
$($ticket.fields.description)

YOUR TASK:
Generate 2-5 clarifying questions for any unclear requirements.

OUTPUT FORMAT (must be valid JSON array):
[
  {
    "summary": "Question summary (max 120 chars)",
    "priority": "High|Medium|Low",
    "description": "Detailed question in markdown"
  }
]

If everything is clear, output: []

Generate the JSON array now:
"@

# Save prompt for reference
$prompt | Out-File "input/complete-prompt.txt" -Encoding UTF8

echo "Prompt created. Length: $($prompt.Length) characters"
```

---

## Step 5: Call Gemini AI to Generate Questions

```powershell
# Send prompt to Gemini
echo "Calling Gemini AI..."

$response = dmtools gemini_ai_chat $prompt

# Save response
$response | Out-File "outputs/response.md" -Encoding UTF8

echo "Response saved to outputs/response.md"
echo ""
echo "=== AI Response ==="
echo $response
echo "=================="
```

---

## Step 6: Validate AI Response

Check if the response is valid JSON:

```powershell
# Read response
$responseContent = Get-Content "outputs/response.md" -Raw

# Try to extract JSON array
if ($responseContent -match '\[[\s\S]*\]') {
    $jsonString = $matches[0]
    echo "Found JSON array in response"
    
    try {
        $questions = $jsonString | ConvertFrom-Json
        echo "✅ Valid JSON!"
        echo "Number of questions: $($questions.Count)"
        
        # Display questions
        $questions | ForEach-Object -Begin { $i=1 } -Process {
            echo ""
            echo "Question $i:"
            echo "  Summary: $($_.summary)"
            echo "  Priority: $($_.priority)"
            echo "  Description: $($_.description)"
            $i++
        }
    } catch {
        echo "❌ Invalid JSON!"
        echo "Error: $_"
        echo ""
        echo "JSON string was:"
        echo $jsonString
    }
} else {
    echo "❌ No JSON array found in response"
    echo "Full response:"
    echo $responseContent
}
```

---

## Step 7: Test JavaScript Action (Dry Run)

Before actually creating tickets, let's understand what the script will do:

```powershell
# Display the action we're about to test
echo "=== JavaScript Action Test ==="
echo ""
echo "Script: createQuestionsSimple.js"
echo "Parent ticket: ATL-2"
echo "Questions to create: [from outputs/response.md]"
echo ""

# Parse questions from response
$responseContent = Get-Content "outputs/response.md" -Raw
$jsonMatch = $responseContent -match '\[[\s\S]*\]'
if ($jsonMatch) {
    $questions = $matches[0] | ConvertFrom-Json
    
    echo "The script will:"
    echo "1. Parse $($questions.Count) question(s) from response"
    echo "2. Create $($questions.Count) Jira sub-ticket(s):"
    
    $questions | ForEach-Object -Begin { $i=1 } -Process {
        echo "   - [Q$i] $($_.summary) (Priority: $($_.priority))"
        $i++
    }
    
    echo "3. Add label 'ai_questions_asked' to ATL-2"
    echo "4. Assign ATL-2 to initiator for review"
    echo ""
    
    $continue = Read-Host "Continue with actual ticket creation? (yes/no)"
    
    if ($continue -ne "yes") {
        echo "Aborted. No tickets were created."
        exit
    }
} else {
    echo "❌ Cannot parse questions from response"
    exit
}
```

---

## Step 8: Create Sub-tickets via dmtools

Now let's actually create the sub-tickets:

```powershell
echo "=== Creating Sub-tickets ==="
echo ""

# Read questions
$responseContent = Get-Content "outputs/response.md" -Raw
$jsonMatch = $responseContent -match '\[[\s\S]*\]'
$questions = $matches[0] | ConvertFrom-Json

$projectKey = "ATL"
$parentKey = "ATL-2"

$createdTickets = @()

$questions | ForEach-Object -Begin { $i=1 } -Process {
    $question = $_
    $summary = "[Q$i] $($question.summary)"
    
    # Truncate summary if too long
    if ($summary.Length > 120) {
        $summary = $summary.Substring(0, 117) + "..."
    }
    
    $description = $question.description + "`n`n---`n*Generated by AI Teammate*`n*Priority: $($question.priority)*"
    
    echo "Creating question $i..."
    echo "  Summary: $summary"
    
    try {
        # Build fields JSON
        $fields = @{
            summary = $summary
            description = $description
            issuetype = @{ name = "Sub-task" }
            parent = @{ key = $parentKey }
        }
        
        if ($question.priority) {
            $fields.priority = @{ name = $question.priority }
        }
        
        $fieldsJson = $fields | ConvertTo-Json -Depth 3
        
        # Create ticket
        $result = dmtools jira_create_ticket_with_json @"
{
  "project": "$projectKey",
  "fieldsJson": $fieldsJson
}
"@
        
        # Extract created key
        if ($result -match '[A-Z]+-\d+') {
            $createdKey = $matches[0]
            echo "  ✅ Created: $createdKey"
            $createdTickets += $createdKey
        } else {
            echo "  ⚠️ Created but key not found"
        }
        
    } catch {
        echo "  ❌ Failed: $_"
    }
    
    $i++
}

echo ""
echo "=== Summary ==="
echo "Created $($createdTickets.Count) sub-ticket(s)"
$createdTickets | ForEach-Object { echo "  - $_" }
```

---

## Step 9: Add Label and Assign Ticket

Complete the post-processing:

```powershell
echo ""
echo "=== Post-Processing ==="

# Add label
try {
    dmtools jira_add_label ATL-2 "ai_questions_asked"
    echo "✅ Added label 'ai_questions_asked' to ATL-2"
} catch {
    echo "❌ Failed to add label: $_"
}

# Get your account ID
$currentUser = dmtools jira_get_current_user | ConvertFrom-Json
$yourAccountId = $currentUser.accountId

echo "Your account ID: $yourAccountId"

# Assign ticket back to you
try {
    dmtools jira_assign_ticket @"
{
  "key": "ATL-2",
  "accountId": "$yourAccountId"
}
"@
    echo "✅ Assigned ATL-2 to $yourAccountId for review"
} catch {
    echo "❌ Failed to assign ticket: $_"
}

echo ""
echo "=== COMPLETE ==="
echo "Check Jira to verify:"
echo "1. ATL-2 has $($createdTickets.Count) sub-ticket(s)"
echo "2. ATL-2 has label 'ai_questions_asked'"
echo "3. ATL-2 is assigned to you"
```

---

## Step 10: Verify in Jira Web Interface

1. **Open Jira**
   - Navigate to: `https://yourcompany.atlassian.net/browse/ATL-2`

2. **Check Sub-tickets**
   - Look for "Sub-tasks" section
   - Verify questions appear as sub-tickets
   - Check priorities are set correctly

3. **Check Labels**
   - Look for "Labels" field
   - Should show `ai_questions_asked`

4. **Check Assignment**
   - Should be assigned to you

5. **Review Question Quality**
   - Are questions relevant?
   - Do they address actual ambiguities?
   - Is the markdown formatting correct?

---

## Troubleshooting

### Issue: No JSON Array in Response

**Symptom:**
```
❌ No JSON array found in response
```

**Cause:** AI didn't follow output format instructions

**Solutions:**
1. **Improve prompt:** Add more emphasis on JSON output
2. **Add examples:** Include more few-shot examples
3. **Explicitly request:** End prompt with "Output the JSON array now:"
4. **Check model:** Some models follow instructions better than others

**Try this improved prompt:**
```powershell
$betterPrompt = @"
OUTPUT ONLY A JSON ARRAY. DO NOT INCLUDE ANY OTHER TEXT.

Analyze this Jira ticket and generate clarifying questions.

Ticket: ATL-2
Description: [ticket description]

Output format (JSON array only, no markdown, no explanations):
[{"summary":"...", "priority":"High", "description":"..."}]

JSON array:
"@
```

### Issue: Invalid JSON (Parse Error)

**Common causes:**
- Trailing commas: `[{...},]`
- Unescaped quotes: `"description": "Use "quotes" carefully"`
- Missing commas between objects
- Extra text before/after JSON array

**Solution:**
```powershell
# Manual JSON cleanup
$responseContent = Get-Content "outputs/response.md" -Raw

# Remove markdown code blocks
$cleaned = $responseContent -replace '```json', '' -replace '```', ''

# Remove trailing commas
$cleaned = $cleaned -replace ',(\s*[\]}])', '$1'

# Try parsing
$cleaned | ConvertFrom-Json
```

### Issue: Sub-ticket Creation Fails

**Error:** `Field 'issuetype' is not valid`

**Cause:** Jira sub-task issue type name varies

**Solutions:**
1. Check issue type name in your Jira:
   ```powershell
   dmtools jira_get_issue_types ATL
   ```

2. Look for exact name (might be "Sub-task", "Subtask", or "Sub Task")

3. Update script to use correct name

### Issue: Permission Denied

**Error:** `403 Forbidden` when creating sub-tickets

**Causes:**
- User doesn't have permission to create sub-tasks
- Project doesn't allow sub-tasks

**Solutions:**
1. Check Jira permissions
2. Use regular tasks instead of sub-tasks (change `issuetype`)
3. Link tickets instead of parent-child relationship

### Issue: Priority Not Set

**Symptom:** Sub-tickets created but all have default priority

**Cause:** Priority name doesn't match Jira's priority scheme

**Solution:**
```powershell
# List available priorities
dmtools jira_get_priorities

# Use exact name from list
# Common names: "Highest", "High", "Medium", "Low", "Lowest"
```

---

## Complete Test Script

Here's a complete PowerShell script that runs the entire test:

**Save as:** `test-run/run-complete-test.ps1`

```powershell
# Complete AI Teammate Local Test Script

param(
    [string]$TicketKey = "ATL-2",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AI TEAMMATE LOCAL TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get ticket
Write-Host "Step 1: Retrieving ticket $TicketKey..." -ForegroundColor Yellow
try {
    $ticket = dmtools jira_get_ticket $TicketKey | ConvertFrom-Json
    Write-Host "✅ Ticket retrieved: $($ticket.fields.summary)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to retrieve ticket: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Build prompt
Write-Host ""
Write-Host "Step 2: Building AI prompt..." -ForegroundColor Yellow
$prompt = @"
You are a Business Analyst. Analyze this Jira ticket and generate clarifying questions.

TICKET:
Key: $($ticket.key)
Summary: $($ticket.fields.summary)
Description:
$($ticket.fields.description)

OUTPUT (JSON array only, no other text):
[{"summary":"question","priority":"High|Medium|Low","description":"details"}]

If everything is clear, output: []

JSON array:
"@

Write-Host "✅ Prompt created ($($prompt.Length) chars)" -ForegroundColor Green

# Step 3: Call AI
Write-Host ""
Write-Host "Step 3: Calling Gemini AI..." -ForegroundColor Yellow
try {
    $response = dmtools gemini_ai_chat $prompt
    Write-Host "✅ AI responded" -ForegroundColor Green
} catch {
    Write-Host "❌ AI call failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Parse response
Write-Host ""
Write-Host "Step 4: Parsing questions..." -ForegroundColor Yellow
if ($response -match '\[[\s\S]*\]') {
    try {
        $questions = $matches[0] | ConvertFrom-Json
        Write-Host "✅ Parsed $($questions.Count) question(s)" -ForegroundColor Green
        
        $questions | ForEach-Object -Begin { $i=1 } -Process {
            Write-Host "  Q$i: $($_.summary) [$($_.priority)]" -ForegroundColor Gray
            $i++
        }
    } catch {
        Write-Host "❌ Invalid JSON: $_" -ForegroundColor Red
        Write-Host "Response was: $response" -ForegroundColor Gray
        exit 1
    }
} else {
    Write-Host "❌ No JSON array found" -ForegroundColor Red
    exit 1
}

if ($questions.Count -eq 0) {
    Write-Host ""
    Write-Host "✅ No questions needed - requirements are clear!" -ForegroundColor Green
    exit 0
}

# Step 5: Create sub-tickets
if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN - Would create $($questions.Count) sub-ticket(s)" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Step 5: Creating sub-tickets..." -ForegroundColor Yellow
$projectKey = $TicketKey.Split('-')[0]
$createdTickets = @()

$questions | ForEach-Object -Begin { $i=1 } -Process {
    $summary = "[Q$i] $($_.summary)".Substring(0, [Math]::Min(120, "[Q$i] $($_.summary)".Length))
    
    try {
        $fields = @{
            summary = $summary
            description = $_.description
            issuetype = @{ name = "Sub-task" }
            parent = @{ key = $TicketKey }
            priority = @{ name = $_.priority }
        } | ConvertTo-Json -Depth 3
        
        $result = dmtools jira_create_ticket_with_json "{`"project`":`"$projectKey`",`"fieldsJson`":$fields}"
        
        if ($result -match '[A-Z]+-\d+') {
            Write-Host "  ✅ Created $($matches[0])" -ForegroundColor Green
            $createdTickets += $matches[0]
        }
    } catch {
        Write-Host "  ❌ Failed: $_" -ForegroundColor Red
    }
    $i++
}

# Step 6: Post-processing
Write-Host ""
Write-Host "Step 6: Post-processing..." -ForegroundColor Yellow
try {
    dmtools jira_add_label $TicketKey "ai_questions_asked"
    Write-Host "✅ Label added" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to add label: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Created: $($createdTickets.Count) sub-ticket(s)" -ForegroundColor Green
Write-Host "Check: https://yourcompany.atlassian.net/browse/$TicketKey" -ForegroundColor Cyan
```

**Run it:**
```powershell
# Dry run (no tickets created)
.\run-complete-test.ps1 -TicketKey ATL-2 -DryRun

# Actual run
.\run-complete-test.ps1 -TicketKey ATL-2
```

---

## Success Criteria

Your local test is successful if:

- [ ] ✅ Gemini AI responds with valid JSON array
- [ ] ✅ JSON contains 2-5 relevant questions
- [ ] ✅ Questions address actual ambiguities in ticket
- [ ] ✅ Sub-tickets are created in Jira
- [ ] ✅ Sub-tickets are linked to parent ticket
- [ ] ✅ Priorities are set correctly
- [ ] ✅ Label `ai_questions_asked` is added
- [ ] ✅ Ticket is assigned for review
- [ ] ✅ No errors in the process

---

## What's Next?

Once local testing is successful:

1. ✅ **Local AI agent works**
2. ✅ **Question generation is reliable**
3. ✅ **Jira integration works**

**→ Proceed to:** [06-github-actions-setup.md](06-github-actions-setup.md)

Set up GitHub Actions to automate this process.

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [04-jira-project-setup.md](04-jira-project-setup.md)  
**Next Step:** [06-github-actions-setup.md](06-github-actions-setup.md)

