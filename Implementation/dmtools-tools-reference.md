# DMTools MCP Tools Reference

**Version:** 1.7.102  
**Total Tools:** 136  
**Last Updated:** December 30, 2025

This document provides a comprehensive reference for all 136 MCP tools available in DMTools.

---

## Quick Start Commands

```powershell
# List all tools
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" list

# Get help for a specific tool
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" <tool_name> --help

# Execute a tool with parameters
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" <tool_name> param1 param2

# Execute with JSON data
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" <tool_name> --data '{"key":"value"}'
```

---

## Tools by Category

### 1. AI Services Tools (10 tools)

#### Anthropic Claude
- `anthropic_ai_chat` - Chat with Claude AI
- `anthropic_ai_chat_with_files` - Chat with file attachments

#### Google Gemini
- `gemini_ai_chat` - Chat with Gemini AI
- `gemini_ai_chat_with_files` - Chat with file attachments

#### AWS Bedrock
- `bedrock_ai_chat` - Chat using AWS Bedrock

#### DIAL (Distributed AI Layer)
- `dial_ai_chat` - Chat using DIAL protocol

#### Ollama (Local AI)
- `ollama_ai_chat` - Chat with local Ollama models

**Example Usage:**
```powershell
# Simple AI chat
java -jar dmtools.jar gemini_ai_chat --data '{"prompt":"Hello, how are you?"}'

# Chat with file context
java -jar dmtools.jar gemini_ai_chat_with_files --data '{"prompt":"Analyze this file","files":["path/to/file.txt"]}'
```

---

### 2. Jira Tools (60+ tools)

#### Profile & User Management
- `jira_get_my_profile` - Get current user profile
- `jira_get_user_profile` - Get specific user profile
- `jira_get_account_by_email` - Find user by email

#### Ticket Operations
- `jira_get_ticket` - Get ticket details
- `jira_create_ticket_basic` - Create simple ticket
- `jira_create_ticket_with_parent` - Create subtask
- `jira_create_ticket_with_json` - Create with full JSON
- `jira_update_ticket` - Update ticket fields
- `jira_update_description` - Update ticket description
- `jira_update_ticket_parent` - Change parent ticket
- `jira_update_field` - Update specific field
- `jira_delete_ticket` - Delete ticket

#### Search & Query
- `jira_search_by_jql` - Search using JQL
- `jira_search_with_pagination` - Paginated search
- `jira_search_by_page` - Get specific page

#### Comments
- `jira_get_comments` - Get all comments
- `jira_post_comment` - Add comment
- `jira_post_comment_if_not_exists` - Conditional comment

#### Subtasks & Links
- `jira_get_subtasks` - Get ticket subtasks
- `jira_link_issues` - Link two issues
- `jira_get_issue_link_types` - Get available link types

#### Labels & Assignments
- `jira_add_label` - Add label to ticket
- `jira_assign_ticket_to` - Assign to user

#### Versions & Components
- `jira_get_fix_versions` - Get fix versions
- `jira_get_components` - Get project components
- `jira_set_fix_version` - Set fix version
- `jira_add_fix_version` - Add fix version
- `jira_remove_fix_version` - Remove fix version

#### Status & Transitions
- `jira_get_project_statuses` - Get available statuses
- `jira_get_transitions` - Get available transitions
- `jira_move_to_status` - Change ticket status
- `jira_move_to_status_with_resolution` - Close with resolution

#### Attachments
- `jira_attach_file_to_ticket` - Upload attachment
- `jira_download_attachment` - Download attachment

#### Metadata & Configuration
- `jira_get_fields` - Get all fields
- `jira_get_issue_types` - Get issue types
- `jira_get_field_custom_code` - Get custom field ID
- `jira_clear_field` - Clear field value
- `jira_set_priority` - Set ticket priority

#### Advanced Operations
- `jira_execute_request` - Custom API request
- `jira_xray_create_precondition` - Create Xray precondition

**Most Common Jira Commands:**

```powershell
# Get ticket details
java -jar dmtools.jar jira_get_ticket PROJECT-123

# Search tickets
java -jar dmtools.jar jira_search_by_jql "project = PROJECT AND status = Open"

# Create ticket
java -jar dmtools.jar jira_create_ticket_basic "PROJECT" "Bug" "Title" "Description"

# Add comment
java -jar dmtools.jar jira_post_comment PROJECT-123 "This is a comment"

# Get my profile
java -jar dmtools.jar jira_get_my_profile
```

---

### 3. Confluence Tools (25 tools)

#### Content Retrieval
- `confluence_contents_by_urls` - Get multiple pages by URL
- `confluence_content_by_id` - Get page by ID
- `confluence_content_by_title_and_space` - Get by title
- `confluence_content_by_title` - Search by title
- `confluence_find_content_by_title_and_space` - Find content
- `confluence_find_content` - General content search
- `confluence_search_content_by_text` - Full-text search

#### User Profiles
- `confluence_get_current_user_profile` - Get current user
- `confluence_get_user_profile_by_id` - Get user by ID

#### Page Management
- `confluence_create_page` - Create new page
- `confluence_update_page` - Update page
- `confluence_update_page_with_history` - Update with history
- `confluence_find_or_create` - Find existing or create

#### Navigation
- `confluence_get_children_by_name` - Get child pages by name
- `confluence_get_children_by_id` - Get child pages by ID

#### Attachments
- `confluence_get_content_attachments` - List attachments
- `confluence_download_attachment` - Download attachment

**Example Confluence Commands:**

```powershell
# Get current user profile
java -jar dmtools.jar confluence_get_current_user_profile

# Search for pages
java -jar dmtools.jar confluence_search_content_by_text "search term"

# Get page by ID
java -jar dmtools.jar confluence_content_by_id 123456

# Create page
java -jar dmtools.jar confluence_create_page "SPACE" "Title" "Content"
```

---

### 4. Figma Tools (15 tools)

#### Design Retrieval
- `figma_get_screen_source` - Get screen/frame source
- `figma_get_node_details` - Get node information
- `figma_get_node_children` - Get child nodes

#### Image Export
- `figma_download_node_image` - Export node as image
- `figma_download_image_of_file` - Export file image
- `figma_download_image_as_file` - Save image to file
- `figma_get_svg_content` - Get SVG markup

#### Design System
- `figma_get_icons` - Get icon library
- `figma_get_styles` - Get design styles
- `figma_get_text_content` - Extract text

#### Layer Management
- `figma_get_layers` - Get layer structure
- `figma_get_layers_batch` - Batch layer retrieval

**Example Figma Commands:**

```powershell
# Get file design
java -jar dmtools.jar figma_get_node_details FILE_KEY NODE_ID

# Download image
java -jar dmtools.jar figma_download_node_image FILE_KEY NODE_ID output.png

# Get styles
java -jar dmtools.jar figma_get_styles FILE_KEY
```

---

### 5. Microsoft Teams Tools (30+ tools)

#### Authentication
- `teams_auth_start` - Start auth flow
- `teams_auth_complete` - Complete auth
- `teams_auth_status` - Check auth status

#### Chat Operations
- `teams_chats` - List chats
- `teams_chats_raw` - Raw chat data
- `teams_recent_chats` - Get recent chats
- `teams_chat_by_name_raw` - Find chat by name

#### Messages
- `teams_messages` - Get messages
- `teams_messages_raw` - Raw message data
- `teams_messages_by_chat_id_raw` - Messages from chat
- `teams_messages_since` - Messages since timestamp
- `teams_messages_since_by_id` - Messages since by chat ID
- `teams_send_message` - Send message
- `teams_send_message_by_id` - Send to specific chat

#### Personal Messages
- `teams_myself_messages_raw` - My messages raw
- `teams_myself_messages` - My messages
- `teams_send_myself_message` - Send to self

#### Teams & Channels
- `teams_get_joined_teams_raw` - Joined teams
- `teams_get_team_channels_raw` - Team channels
- `teams_find_team_by_name_raw` - Find team
- `teams_find_channel_by_name_raw` - Find channel
- `teams_get_channel_messages_by_name_raw` - Channel messages

#### Files & Attachments
- `teams_download_file` - Download file
- `teams_get_message_hosted_contents` - Get hosted content
- `teams_search_user_drive_files` - Search OneDrive

#### Call Recordings & Transcripts
- `teams_get_call_transcripts` - Get transcripts
- `teams_get_recording_transcripts` - Recording transcripts
- `teams_list_recording_transcripts` - List transcripts
- `teams_download_recording_transcript` - Download transcript
- `teams_extract_transcript_from_sharepoint` - Extract from SharePoint

---

### 6. Azure DevOps (ADO) Tools (15 tools)

#### Work Items
- `ado_get_work_item` - Get work item details
- `ado_create_work_item` - Create work item
- `ado_update_description` - Update description
- `ado_update_tags` - Update tags
- `ado_move_to_state` - Change state
- `ado_link_work_items` - Link items

#### Search & Query
- `ado_search_by_wiql` - Search using WIQL

#### Comments & History
- `ado_get_comments` - Get comments
- `ado_post_comment` - Add comment
- `ado_get_changelog` - Get change history

#### Assignments
- `ado_assign_work_item` - Assign work item

#### Attachments
- `ado_download_attachment` - Download attachment

#### User Management
- `ado_get_user_by_email` - Find user
- `ado_get_my_profile` - Get current user

---

### 7. SharePoint Tools (2 tools)

- `sharepoint_get_drive_item` - Get drive item
- `sharepoint_download_file` - Download file

---

### 8. File Operation Tools (4 tools)

- `file_read` - Read file content
- `file_write` - Write to file
- `file_validate_json` - Validate JSON string
- `file_validate_json_file` - Validate JSON file

**Example File Commands:**

```powershell
# Read file
java -jar dmtools.jar file_read "path/to/file.txt"

# Write file
java -jar dmtools.jar file_write "path/to/file.txt" "content"

# Validate JSON
java -jar dmtools.jar file_validate_json_file "config.json"
```

---

### 9. Knowledge Base Tools (4 tools)

- `kb_get` - Get KB entry
- `kb_build` - Build KB
- `kb_process` - Process KB data
- `kb_aggregate` - Aggregate KB
- `kb_process_inbox` - Process KB inbox

---

### 10. Mermaid Diagram Tools (3 tools)

- `mermaid_index_generate` - Generate index
- `mermaid_index_read_list` - List diagrams
- `mermaid_index_read` - Read diagram

---

### 11. CLI Execution Tool (1 tool)

- `cli_execute_command` - Execute system command

**Warning:** Use with caution - executes arbitrary commands

---

## Configuration Requirements

### Required Environment Variables by Tool Category

#### For Jira Tools:
```
JIRA_BASE_PATH=https://your-domain.atlassian.net
JIRA_EMAIL=your-email@domain.com
JIRA_API_TOKEN=your-jira-api-token
JIRA_AUTH_TYPE=basic
```

#### For Confluence Tools:
```
CONFLUENCE_BASE_PATH=https://your-domain.atlassian.net/wiki
CONFLUENCE_EMAIL=your-email@domain.com
CONFLUENCE_API_TOKEN=your-confluence-api-token
CONFLUENCE_AUTH_TYPE=basic
```

#### For Gemini AI Tools:
```
GEMINI_API_KEY=your-gemini-api-key
GEMINI_DEFAULT_MODEL=gemini-2.0-flash-exp
```

#### For Figma Tools:
```
FIGMA_API_KEY=your-figma-api-key
FIGMA_BASE_PATH=https://api.figma.com
```

#### For GitHub Tools:
```
GITHUB_TOKEN=your-github-token
GITHUB_WORKSPACE=your-org-or-user
GITHUB_BASE_PATH=https://api.github.com
```

---

## Usage Patterns

### Pattern 1: Direct Execution
```powershell
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" tool_name param1 param2
```

### Pattern 2: With JSON Data
```powershell
java -jar dmtools.jar tool_name --data '{"key":"value","array":["item1","item2"]}'
```

### Pattern 3: With JSON File
```powershell
# Create params.json
@{
    ticketKey = "PROJECT-123"
    fields = @("summary", "description")
} | ConvertTo-Json | Out-File params.json

# Execute
java -jar dmtools.jar jira_get_ticket --file params.json
```

### Pattern 4: With Environment Variables
```powershell
# Load from dmtools.env automatically
cd "c:\Users\AndreyPopov\dmtools"
java -jar "C:\Users\AndreyPopov\.dmtools\dmtools.jar" jira_get_my_profile
```

---

## Common Use Cases for Learning Project

### 1. Get Jira Ticket Information
```powershell
# Basic ticket info
java -jar dmtools.jar jira_get_ticket LEARN-1

# With specific fields
java -jar dmtools.jar jira_get_ticket LEARN-1 summary,description,status
```

### 2. Create Jira Subtask
```powershell
java -jar dmtools.jar jira_create_ticket_with_parent "LEARN" "Sub-task" "Question 1" "What is X?" "LEARN-1"
```

### 3. Generate Questions with AI
```powershell
# Create prompt file
@{
    prompt = "Generate 3 clarifying questions for this user story: As a user, I want to..."
} | ConvertTo-Json | Out-File prompt.json

# Get AI response
java -jar dmtools.jar gemini_ai_chat --file prompt.json
```

### 4. Post Comment to Ticket
```powershell
java -jar dmtools.jar jira_post_comment LEARN-1 "AI generated these questions..."
```

### 5. Search for Tickets
```powershell
java -jar dmtools.jar jira_search_by_jql "project = LEARN AND type = Story"
```

---

## Troubleshooting

### Tool Not Found
```
Error: Unknown tool 'tool_name'
```
**Solution:** Run `java -jar dmtools.jar list` to see all available tools

### Authentication Error
```
Error: 401 Unauthorized
```
**Solution:** Check your API tokens in `dmtools.env`

### Missing Parameters
```
Error: Required parameter 'X' not provided
```
**Solution:** Use `--data` or `--file` to provide parameters as JSON

### Timeout
```
Error: Timeout after 30s
```
**Solution:** Some AI tools may take longer - this is normal for complex requests

---

## Next Steps

1. ✅ Review this reference
2. Run test script: `.\test-dmtools-complete.ps1`
3. Create Jira test project (covered in next guide)
4. Create simple agent configuration
5. Test agent locally

---

**Document Version:** 1.0  
**Based on:** DMTools v1.7.102 (136 tools)  
**Last Updated:** December 30, 2025  
**Previous:** [02-dmtools-installation.md](02-dmtools-installation.md)  
**Next:** [04-jira-project-setup.md](04-jira-project-setup.md)

