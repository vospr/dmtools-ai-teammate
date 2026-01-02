# Jira Project Setup Guide for AI Teammate Learning

This guide will walk you through creating a simple Jira project with test tickets specifically designed for learning AI teammate automation.

**Note:** This guide uses direct PowerShell API calls (`Invoke-RestMethod`) instead of `dmtools.jar` CLI commands due to authentication issues with the Java application. All API calls have been tested and confirmed working. See [03-mcp-connection-test.md](03-mcp-connection-test.md) for details on the workaround approach.

## Overview

**What You'll Create:**
- ✅ A new Jira project (key: ATL - AI Teammate Learning)
- ✅ 3-5 test stories with different characteristics
- ✅ Optional: AI Teammate user account for assignment triggers
- ✅ Custom labels for automation tracking

**Time Required:** 15-20 minutes

---

## Important: API Call Approach

**This guide uses direct PowerShell API calls** instead of `dmtools.jar` CLI commands due to authentication issues with the Java application. All commands have been tested and confirmed working.

**Why Direct API Calls?**
- ✅ **Reliable:** Bypasses dmtools.jar authentication issues
- ✅ **Debuggable:** Easy to see request/response details
- ✅ **Fast:** No Java process overhead
- ✅ **Windows Native:** Works perfectly in PowerShell

**All API calls follow this pattern:**
1. Load credentials from `dmtools.env`
2. Create Basic Auth header
3. Make API call using `Invoke-RestMethod`
4. Display results

**For simpler ticket creation:** Consider using the **Web Interface (Option A)** for most tickets, and use API calls only when needed for automation.

---

## Step 1: Create New Jira Project

### Option A: Using Jira Web Interface (Recommended for Beginners)

1. **Log in to Jira**
   - Open: `https://yourcompany.atlassian.net`
   - Log in with your credentials

2. **Create Project**
   - Click **"Projects"** in the top navigation
   - Click **"Create project"**
   
3. **Choose Template**
   - Select **"Scrum"** or **"Kanban"** (either works fine)
   - For learning: **"Kanban"** is simpler
   - Click **"Use template"**

4. **Configure Project**
   - **Project name:** `AI Teammate Learning`
   - **Key:** `ATL` (auto-filled, but verify)
   - **Access:** Choose based on your preference
     - **Open:** Anyone in your organization can access
     - **Private:** Only invited users can access (recommended for learning)
   - Click **"Create"**

5. **Verify Creation**
   - You should see your new project board
   - URL format: `https://yourcompany.atlassian.net/jira/software/projects/ATL/board`

### Option B: Using Direct API Calls (Advanced)

**Note:** Project creation via API requires Jira admin permissions and is complex. **Recommended: Use Web Interface (Option A)** instead.

If you have admin permissions and want to use the API:

```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Get your account ID first
$myself = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/myself" -Headers @{
    Authorization = "Basic $auth"
    Accept = "application/json"
}

# Create project (requires admin permissions)
# Note: Use leadAccountId (not lead) for GDPR strict mode
# Template is optional - omit if template doesn't exist in your instance
$projectBody = @{
    key = "ATL"
    name = "AI Teammate Learning"
    projectTypeKey = "software"
    leadAccountId = $myself.accountId
} | ConvertTo-Json

$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/project" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $projectBody

Write-Host "✅ Project created: $($response.key) - $($response.id)" -ForegroundColor Green
$response | ConvertTo-Json -Depth 10
```

**Important Notes:** 
- This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application. This workaround has been tested and confirmed working.
- Use `leadAccountId` (not `lead`) for GDPR strict mode compliance.
- Project template is optional - omit `projectTemplateKey` if the template doesn't exist in your Jira instance.
- **Verified:** Project "AI Teammate Learning" (ATL) was successfully created using this method on December 31, 2025.

---

## Step 2: Create Test Stories

We'll create several test stories with different characteristics to test various AI teammate capabilities.

### Story 1: Simple Clear Requirements (Baseline)

**Create via Web Interface:**
1. Click **"Create"** button (top menu)
2. Fill in:
   - **Project:** AI Teammate Learning (ATL)
   - **Issue Type:** Story
   - **Summary:** `User login functionality`
   - **Description:**
     ```
     As a user, I want to be able to log in to the application using my email and password.

     Acceptance Criteria:
     - Login form with email and password fields
     - "Remember me" checkbox
     - "Forgot password" link
     - Error message for invalid credentials
     - Redirect to dashboard after successful login
     
     Technical Notes:
     - Use JWT for authentication
     - Password must be hashed with bcrypt
     - Session timeout: 30 minutes
     ```
3. Click **"Create"**

**Create via Direct API Call:**
```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Create ticket
$ticketBody = @{
    fields = @{
        project = @{ key = "ATL" }
        summary = "User login functionality"
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "As a user, I want to be able to log in to the application using my email and password." }
                    )
                },
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "Acceptance Criteria:" }
                    )
                },
                @{
                    type = "bulletList"
                    content = @(
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Login form with email and password fields" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "\"Remember me\" checkbox" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "\"Forgot password\" link" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Error message for invalid credentials" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Redirect to dashboard after successful login" }) }) }
                    )
                },
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "Technical Notes:" }
                    )
                },
                @{
                    type = "bulletList"
                    content = @(
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Use JWT for authentication" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Password must be hashed with bcrypt" }) }) }
                        @{ type = "listItem"; content = @(@{ type = "paragraph"; content = @(@{ type = "text"; text = "Session timeout: 30 minutes" }) }) }
                    )
                }
            )
        }
        issuetype = @{ name = "Story" }
        priority = @{ name = "High" }
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/issue" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $ticketBody

Write-Host "✅ Ticket created: $($response.key)" -ForegroundColor Green
$response | ConvertTo-Json -Depth 10
```

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application. For simpler plain text descriptions, see the alternative below.

### Story 2: Vague Requirements (For Question Generation)

This story intentionally has unclear requirements to test the AI's ability to generate clarifying questions.

**Summary:** `Implement dashboard analytics`

**Description:**
```
We need analytics on the dashboard. Users should be able to see their data and metrics.

Show some charts and graphs that look good. Make it useful for business decisions.

The dashboard should be fast and work well on mobile too.
```

**Create via Web Interface:**
1. Click **"Create"**
2. Project: ATL, Type: Story
3. Copy summary and description above
4. Priority: Medium
5. Click **"Create"**

**Create via Direct API Call:**
```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Create ticket with plain text description (simpler format)
$ticketBody = @{
    fields = @{
        project = @{ key = "ATL" }
        summary = "Implement dashboard analytics"
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "We need analytics on the dashboard. Users should be able to see their data and metrics." }
                    )
                },
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "Show some charts and graphs that look good. Make it useful for business decisions." }
                    )
                },
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = "The dashboard should be fast and work well on mobile too." }
                    )
                }
            )
        }
        issuetype = @{ name = "Story" }
        priority = @{ name = "Medium" }
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/issue" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $ticketBody

Write-Host "✅ Ticket created: $($response.key)" -ForegroundColor Green
$response | ConvertTo-Json -Depth 10
```

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI. The description format uses Jira's document format. For simpler plain text, you can use the web interface instead.

### Story 3: Technical Story with Attachments

**Summary:** `API rate limiting implementation`

**Description:**
```
Implement rate limiting for our REST API to prevent abuse.

Requirements:
- Limit: 100 requests per minute per API key
- Return 429 status code when limit exceeded
- Include retry-after header
- Different limits for authenticated vs anonymous users

Technical Approach:
- Use Redis for distributed rate limiting
- Token bucket algorithm
- Configuration via environment variables
```

**Additional Step:** After creating, attach a file:
1. Create a simple text file: `rate-limiting-config.txt` with content:
   ```
   RATE_LIMIT_REQUESTS_PER_MINUTE=100
   RATE_LIMIT_BURST=150
   RATE_LIMIT_STORAGE=redis
   ```
2. Open the ticket in Jira
3. Click **"Attach"** or drag the file to add it

### Story 4: Story with Links/References

**Summary:** `Integrate third-party payment gateway`

**Description:**
```
Integrate Stripe payment gateway for processing customer payments.

Reference Documentation:
- Stripe API: https://stripe.com/docs/api
- PCI Compliance: https://stripe.com/docs/security
- Webhook Setup: https://stripe.com/docs/webhooks

Requirements:
- Support credit card payments
- Handle recurring subscriptions
- Process refunds
- Webhook for payment status updates
- Store minimal payment data (PCI compliance)

Dependencies:
- Requires SSL certificate setup (see SECURITY-101)
- Database schema changes needed
```

### Story 5: Epic with Sub-tasks (Optional, Advanced)

**Summary:** `User profile management system`

**Description:**
```
Comprehensive user profile management system with CRUD operations.

This is an epic that should be broken down into smaller tasks.

Features needed:
- View profile
- Edit profile (name, email, avatar)
- Change password
- Privacy settings
- Delete account
- Export user data (GDPR compliance)
```

**After creating:** Convert to Epic (if your Jira supports it) or just use it as a regular story.

---

## Step 3: Verify Tickets via Direct API Calls

Test that you can query the tickets you just created using direct PowerShell API calls:

### List All Tickets in Project

**Complete Command (Copy-Paste Ready):**

```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Search for tickets in ATL project
$jql = "project = ATL ORDER BY created DESC"
$body = @{
    jql = $jql
    fields = @("key", "summary", "status", "priority")
    maxResults = 50
} | ConvertTo-Json

$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/search" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $body

Write-Host "Found $($response.total) tickets:" -ForegroundColor Green
$response.issues | ForEach-Object {
    Write-Host "  $($_.key): $($_.fields.summary) [$($_.fields.status.name)]"
}
$response | ConvertTo-Json -Depth 10
```

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application. This workaround has been tested and confirmed working.

**Expected output:**
```json
{
  "issues": [
    {
      "key": "ATL-1",
      "fields": {
        "summary": "User login functionality",
        "status": {"name": "To Do"},
        "priority": {"name": "High"}
      }
    },
    {
      "key": "ATL-2",
      "fields": {
        "summary": "Implement dashboard analytics",
        "status": {"name": "To Do"},
        "priority": {"name": "Medium"}
      }
    },
    ...
  ]
}
```

### Get Specific Ticket Details

**Complete Command (Copy-Paste Ready):**

```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Replace ATL-2 with the key of your vague requirements story
$ticketKey = "ATL-2"

$response = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/${ticketKey}" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
    }

Write-Host "Ticket: $($response.key)" -ForegroundColor Green
Write-Host "Summary: $($response.fields.summary)" -ForegroundColor Green
Write-Host "Status: $($response.fields.status.name)" -ForegroundColor Green
Write-Host "`nDescription:" -ForegroundColor Yellow
$response.fields.description | ConvertTo-Json -Depth 10
$response | ConvertTo-Json -Depth 10
```

**Verify:** The description contains the vague requirements we'll use for testing question generation.

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application.

---

## Step 4: Create AI Teammate User (Optional but Recommended)

Creating a dedicated "AI Teammate" user allows you to trigger automation by assigning tickets to this user.

### Why Create a Separate User?

**Benefits:**
- Clear audit trail (shows AI made changes, not you)
- Automation trigger (assign to AI → workflow starts)
- Separate from your personal account
- Can be easily disabled if needed

### Option A: Create Full Jira User (Requires Admin)

1. **Go to User Management**
   - Click **Settings** (⚙️) → **Products** → **Jira user management**
   - OR navigate to: `https://admin.atlassian.com/s/your-site/users`

2. **Invite User**
   - Click **"Invite users"**
   - Email: Use an email you control (e.g., `aiteammate+yourcompany@gmail.com`)
   - Role: Basic or similar
   - Click **"Invite"**

3. **Complete Setup**
   - Check your email for the invitation
   - Accept and set up the account
   - Display name: `AI Teammate Bot`
   - Profile picture: Upload a robot icon (optional)

4. **Add to Project**
   - Go to ATL project settings
   - **Project settings** → **People**
   - Add the AI Teammate user with appropriate role

### Option B: Use Service Account/Bot (Advanced)

Some Atlassian plans support bot users. Check your plan documentation.

### Option C: Use Your Account (Simplest)

For learning purposes, you can skip creating a separate user and just use your own account. The automation will still work, but you won't get the clear separation of concerns.

**Workaround:** Create custom labels like `ai_processing` to trigger automation instead of using assignee.

---

## Step 5: Set Up Custom Labels

Create custom labels for tracking AI processing status:

### Labels to Create

1. **`ai_questions_asked`** - Questions have been generated
2. **`ai_description_updated`** - Description has been enhanced
3. **`ai_processing`** - Currently being processed
4. **`needs_human_review`** - AI completed, human review needed

### How to Add Labels

Labels are created automatically when you first use them. To pre-create:

1. Open any ticket (e.g., ATL-1)
2. Click on the **Labels** field
3. Type: `ai_questions_asked` and press Enter
4. Repeat for other labels
5. Remove all labels from the ticket (we'll add them via automation)

### Verify Labels via Direct API Call

**Complete Command (Copy-Paste Ready):**

```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Add a label to test
$ticketKey = "ATL-1"
$labelToAdd = "ai_processing"

# Get current ticket to see existing labels
$ticket = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/${ticketKey}?fields=labels" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
    }

$currentLabels = if ($ticket.fields.labels) { $ticket.fields.labels } else { @() }
$newLabels = $currentLabels + $labelToAdd

# Update ticket with new label
$updateBody = @{
    fields = @{
        labels = $newLabels
    }
} | ConvertTo-Json

Invoke-RestMethod -Method PUT -Uri "${basePath}/rest/api/3/issue/${ticketKey}" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $updateBody | Out-Null

Write-Host "✅ Label '$labelToAdd' added to $ticketKey" -ForegroundColor Green

# Get ticket and verify label was added
$updatedTicket = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/${ticketKey}?fields=labels,summary" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
    }

Write-Host "`nTicket: $($updatedTicket.key) - $($updatedTicket.fields.summary)" -ForegroundColor Green
Write-Host "Labels: $($updatedTicket.fields.labels -join ', ')" -ForegroundColor Yellow
```

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application.

---

## Step 6: Configure Board Columns (Optional)

Customize your Kanban board columns to include AI processing stages:

### Recommended Columns

1. **To Do** - New stories not yet processed
2. **AI Processing** - Stories being analyzed by AI teammate
3. **Ready for Review** - AI completed, needs human review
4. **In Development** - Being implemented
5. **Done** - Completed

### Option A: Create Custom Field (Category Type)

**Note:** Custom field creation via API requires admin permissions. The API endpoint may not be available for all Jira instances.

**Via Jira UI (Recommended):**
1. Go to **Settings** (⚙️) → **Issues** → **Custom fields**
2. Click **Create custom field**
3. Select **Select List (single choice)** or **Select List (cascading)**
4. Name: `AI Processing Stage`
5. Add options:
   - To Do
   - AI Processing
   - Ready for Review
   - In Development
   - Done
6. Add to ATL project screens

**Via API (May require admin):**
```powershell
# Note: This typically requires admin permissions and may not work via API
# Use Jira UI instead (Option A above)
```

### Option B: Use Status Field (Alternative)

Use Jira's built-in Status field and create custom statuses:

1. Go to **Settings** (⚙️) → **Issues** → **Statuses**
2. Create new statuses:
   - **AI Processing** (if not exists)
   - **Ready for Review** (if not exists)
3. Go to your ATL board
4. Click **Board** → **Board settings** → **Columns**
5. Map statuses to columns:
   - **To Do** column → "To Do" status
   - **AI Processing** column → "AI Processing" status
   - **Ready for Review** column → "Ready for Review" status
   - **In Development** column → "In Progress" status
   - **Done** column → "Done" status

### Option C: Use Labels (Temporary Workaround)

Until custom field/statuses are created, use labels to track stages:
- `ai_processing` - Currently being processed
- `ready_for_review` - AI completed, needs review
- `in_development` - Being implemented

**Current Implementation:** Labels are being used as a workaround (see Step 5).

---

## Step 7: Test Data Scenarios

Here's what each test story is designed to test:

| Ticket | Scenario | AI Agent Test |
|--------|----------|---------------|
| **ATL-1** | Clear requirements | Should confirm requirements are clear, minimal questions |
| **ATL-2** | Vague requirements | Should generate 5-10 clarifying questions |
| **ATL-3** | Technical with attachments | Should read attachment, ask about configuration |
| **ATL-4** | Contains links | Should validate links, ask about external dependencies |
| **ATL-5** | Epic to break down | Should suggest breaking into sub-tasks |

---

## Step 8: Create Sample Test Ticket for Immediate Testing

Create one more ticket specifically for your first AI agent test run:

**Summary:** `[TEST] Process this ticket with AI teammate`

**Description:**
```
This is a test ticket for AI teammate automation.

User Story:
As a customer, I want to receive email notifications when my order status changes.

Current Description:
- Notification should be sent
- Include order details
- Maybe add tracking link?

Questions I expect AI to ask:
- Which order statuses trigger notifications?
- What specific order details should be included?
- Should there be an option to opt-out?
- What's the email template format?
- Are there any rate limiting considerations?

This ticket will be used to test the AI question generation agent.
```

**Labels:** Add `test_ticket`

**Create via Direct API Call:**
```powershell
# Load credentials from dmtools.env
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Create test ticket
$descriptionText = @"
This is a test ticket for AI teammate automation.

User Story:
As a customer, I want to receive email notifications when my order status changes.

Current Description:
- Notification should be sent
- Include order details
- Maybe add tracking link?

Questions I expect AI to ask:
- Which order statuses trigger notifications?
- What specific order details should be included?
- Should there be an option to opt-out?
- What's the email template format?
- Are there any rate limiting considerations?

This ticket will be used to test the AI question generation agent.
"@

$ticketBody = @{
    fields = @{
        project = @{ key = "ATL" }
        summary = "[TEST] Process this ticket with AI teammate"
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{ type = "text"; text = $descriptionText }
                    )
                }
            )
        }
        issuetype = @{ name = "Story" }
        priority = @{ name = "Medium" }
        labels = @("test_ticket")
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/issue" `
    -Headers @{
        Authorization = "Basic $auth"
        Accept = "application/json"
        "Content-Type" = "application/json"
    } `
    -Body $ticketBody

Write-Host "✅ Test ticket created: $($response.key)" -ForegroundColor Green
Write-Host "Note this ticket key for your first agent test!" -ForegroundColor Yellow
$response | ConvertTo-Json -Depth 10
```

**Note:** This uses direct PowerShell API calls instead of `dmtools` CLI due to authentication issues with the Java application.

**Note the ticket key** (e.g., ATL-6) - you'll use this for your first agent test.

---

## Verification Checklist

Before proceeding to agent configuration, verify:

### ✅ Project Setup
- [x] Project **ATL** (AI Teammate Learning) is created
- [x] Project ID: 10036
- [x] Project Key: ATL
- [x] Project URL: `https://vospr.atlassian.net/jira/software/projects/ATL`

### ✅ Test Stories Created
- [x] **ATL-1**: User login functionality (Clear requirements) - Priority: High
- [x] **ATL-2**: Implement dashboard analytics (Vague requirements) - Priority: Medium - Label: `ai_questions_asked`
- [x] **ATL-3**: API rate limiting implementation (Technical with attachments) - Priority: High - Label: `ai_processing` - Attachment: `rate-limiting-config.txt`
- [x] **ATL-4**: Integrate third-party payment gateway (Contains links) - Priority: High - Label: `ai_description_updated`
- [x] **ATL-5**: User profile management system (Epic to break down) - Priority: Medium - Label: `needs_human_review`
- [x] **ATL-6**: [TEST] Process this ticket with AI teammate (Test ticket) - Priority: Medium - Label: `test_ticket`

### ✅ Custom Labels Setup
- [x] `ai_questions_asked` - Applied to ATL-2 (Vague requirements scenario)
- [x] `ai_processing` - Applied to ATL-3 (Technical scenario)
- [x] `ai_description_updated` - Applied to ATL-4 (Links scenario)
- [x] `needs_human_review` - Applied to ATL-5 (Epic scenario)
- [x] `test_ticket` - Applied to ATL-6 (Test ticket)

### ✅ API Access
- [x] Can retrieve tickets via direct PowerShell API calls (see Step 3)
- [x] Can get individual ticket details via direct PowerShell API calls
- [x] Can update tickets (labels, status, etc.)

### ✅ Board Columns / Custom Field
- [ ] Custom field "AI Processing Stage" created (requires admin permissions)
  - **Note:** Custom field creation via API requires admin access. Alternative: Use Jira's built-in Status field and create custom statuses:
    - To Do (default status)
    - AI Processing (create custom status via Jira UI)
    - Ready for Review (create custom status via Jira UI)
    - In Development (create custom status via Jira UI)
    - Done (default status)
  - **Workaround:** Use labels to track AI processing stages until custom field/statuses are created

### ✅ Test Scenarios Ready
- [x] Clear requirements ticket (ATL-1) - Baseline for comparison
- [x] Vague requirements ticket (ATL-2) - For question generation testing
- [x] Technical ticket with attachment (ATL-3) - For attachment reading testing
- [x] Ticket with links (ATL-4) - For link validation testing
- [x] Epic ticket (ATL-5) - For breakdown suggestion testing
- [x] Test ticket (ATL-6) - For immediate AI agent testing

### ⚠️ Optional Items
- [ ] AI Teammate user created (or using your own account)
- [ ] Custom statuses created for board columns (requires admin access)
- [ ] Board columns configured to match AI processing stages

---

## Verification Summary

**Status:** ✅ **All Core Items Complete**

**Completed:**
- ✅ Project ATL created and verified
- ✅ All 6 test tickets created with appropriate labels
- ✅ Custom labels applied according to test scenarios
- ✅ Test ticket (ATL-6) ready for immediate testing
- ✅ API access verified and working

**Pending (Optional/Admin Required):**
- ⚠️ Custom field for board columns (requires admin permissions - use Status field as alternative)
- ⚠️ Custom statuses for board columns (can be created via Jira UI)
- ⚠️ AI Teammate user (optional - can use your account)

**Ready to Proceed:** ✅ Yes - All core setup complete. You can proceed to agent configuration.

---

## Understanding Jira Issue Types

### Story
- User-facing feature or functionality
- Has acceptance criteria
- Provides value to end users
- Used for most AI teammate testing

### Task
- Technical work without direct user value
- Examples: "Upgrade database", "Refactor code"

### Bug
- Something that's broken
- Has steps to reproduce
- Expected vs actual behavior

### Epic
- Large body of work spanning multiple sprints
- Contains multiple stories/tasks
- Example: "User Authentication System"

For learning purposes, focus on **Stories** as they have rich descriptions and acceptance criteria that work well with AI analysis.

---

## Best Practices for Test Tickets

### Good Test Ticket Characteristics

✅ **Clear user story format:** "As a [role], I want [feature], so that [benefit]"
✅ **Acceptance criteria:** Specific, testable conditions
✅ **Technical notes:** Architecture, dependencies, constraints
✅ **Context:** Links to related tickets, documentation, designs

### Intentional Ambiguities for Testing

For testing question generation, include:
- ❓ Vague adjectives: "nice", "good", "fast", "user-friendly"
- ❓ Missing specifics: "show data" without saying which data
- ❓ Unstated assumptions: "users should see metrics" without defining metrics
- ❓ Unclear scope: "implement analytics" without boundaries

---

## Advanced: Jira Project Structure

**Current Project Structure (Verified):**

```
AI Teammate Learning (ATL) - Project ID: 10036
├── Tickets (6 total)
│   ├── ATL-1: User login functionality
│   │   └── Type: Task | Priority: High | Labels: None (Clear requirements baseline)
│   ├── ATL-2: Implement dashboard analytics
│   │   └── Type: Task | Priority: Medium | Labels: ai_questions_asked (Vague requirements)
│   ├── ATL-3: API rate limiting implementation
│   │   └── Type: Task | Priority: High | Labels: ai_processing | Attachment: rate-limiting-config.txt
│   ├── ATL-4: Integrate third-party payment gateway
│   │   └── Type: Task | Priority: High | Labels: ai_description_updated (Contains links)
│   ├── ATL-5: User profile management system
│   │   └── Type: Task | Priority: Medium | Labels: needs_human_review (Epic to break down)
│   └── ATL-6: [TEST] Process this ticket with AI teammate
│       └── Type: Task | Priority: Medium | Labels: test_ticket
├── Custom Labels (Created and Applied)
│   ├── ai_questions_asked (ATL-2)
│   ├── ai_processing (ATL-3)
│   ├── ai_description_updated (ATL-4)
│   ├── needs_human_review (ATL-5)
│   └── test_ticket (ATL-6)
├── Attachments
│   └── rate-limiting-config.txt (attached to ATL-3)
└── Users
    └── You (Admin/Developer) - Account ID: 712020:9bccb0d5-3074-42f1-8d6e-54d564d50a5f
```

**Test Scenarios Mapping:**
- **ATL-1**: Clear requirements → Baseline (no special label)
- **ATL-2**: Vague requirements → `ai_questions_asked` (should generate questions)
- **ATL-3**: Technical with attachments → `ai_processing` (should read attachment)
- **ATL-4**: Contains links → `ai_description_updated` (should validate links)
- **ATL-5**: Epic to break down → `needs_human_review` (should suggest breakdown)
- **ATL-6**: Test ticket → `test_ticket` (for immediate testing)

---

## What's Next?

Now that your Jira project is set up:

1. ✅ **Project ATL created**
2. ✅ **Test tickets ready**
3. ✅ **Labels configured**
4. ✅ **Test scenario planned**

**→ Proceed to:** [05-create-learning-agent.md](05-create-learning-agent.md)

Create the AI agent configuration that will process these tickets and generate clarifying questions.

---

## Troubleshooting

### Issue: Can't Create Project

**Cause:** Insufficient permissions

**Solution:**
- Request Jira admin permissions
- OR ask your Jira admin to create the project for you
- OR use an existing test project

### Issue: API Create Ticket Fails

**Error:** `Field 'project' is required` or `400 Bad Request`

**Solution:**
```powershell
# Load credentials
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Check project key exists
$body = @{ jql = "project = ATL"; fields = @("key"); maxResults = 1 } | ConvertTo-Json
$response = Invoke-RestMethod -Method POST -Uri "${basePath}/rest/api/3/search" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json"; "Content-Type" = "application/json" } `
    -Body $body

if ($response.total -eq 0) {
    Write-Host "❌ Project ATL not found or has no tickets" -ForegroundColor Red
} else {
    Write-Host "✅ Project ATL exists" -ForegroundColor Green
}

# Verify JSON format - ensure project key is in correct format:
# project = @{ key = "ATL" }  (not just "ATL")
```

### Issue: Labels Not Showing Up

Labels are created automatically on first use. To verify:
```powershell
# Load credentials
cd "c:\Users\AndreyPopov\dmtools"
$token = (Get-Content "dmtools.env" | Select-String "^JIRA_API_TOKEN=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$email = (Get-Content "dmtools.env" | Select-String "^JIRA_EMAIL=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$basePath = (Get-Content "dmtools.env" | Select-String "^JIRA_BASE_PATH=" | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))

# Get current ticket to see existing labels
$ticket = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/ATL-1?fields=labels" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json" }

$currentLabels = if ($ticket.fields.labels) { $ticket.fields.labels } else { @() }
$newLabels = $currentLabels + "test_label"

# Add label
$updateBody = @{ fields = @{ labels = $newLabels } } | ConvertTo-Json
Invoke-RestMethod -Method PUT -Uri "${basePath}/rest/api/3/issue/ATL-1" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json"; "Content-Type" = "application/json" } `
    -Body $updateBody | Out-Null

# Get ticket to see labels
$updatedTicket = Invoke-RestMethod -Method GET -Uri "${basePath}/rest/api/3/issue/ATL-1?fields=labels" `
    -Headers @{ Authorization = "Basic $auth"; Accept = "application/json" }

Write-Host "Labels: $($updatedTicket.fields.labels -join ', ')" -ForegroundColor Green
```

---

## Additional Resources

- **Jira REST API - Create Issue:** [https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-post](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-post)
- **JQL Tutorial:** [https://www.atlassian.com/software/jira/guides/jql](https://www.atlassian.com/software/jira/guides/jql)
- **Jira Markdown Syntax:** [https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa](https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa)

---

**Document Version:** 1.0  
**Last Updated:** December 30, 2025  
**Previous Step:** [03-mcp-connection-test.md](03-mcp-connection-test.md)  
**Next Step:** Create learning agent configuration

