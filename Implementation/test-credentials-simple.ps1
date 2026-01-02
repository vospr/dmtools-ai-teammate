# DMTools Credentials Test Script (Simple Version)
# Run this script to verify all your API tokens are working correctly

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DMTOOLS CREDENTIALS TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load environment variables from dmtools.env
Write-Host "Loading environment variables..." -ForegroundColor Yellow
$envFile = "c:\Users\AndreyPopov\dmtools\dmtools.env"

if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: dmtools.env not found at: $envFile" -ForegroundColor Red
    exit 1
}

Get-Content $envFile | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

Write-Host "SUCCESS: Environment variables loaded" -ForegroundColor Green
Write-Host ""

# Test 1: Jira Connection
Write-Host "Test 1: Jira Connection" -ForegroundColor Yellow
Write-Host "   URL: $env:JIRA_BASE_PATH" -ForegroundColor Gray
Write-Host "   Email: $env:JIRA_EMAIL" -ForegroundColor Gray
try {
    $user = dmtools jira_get_current_user | ConvertFrom-Json
    Write-Host "   SUCCESS: Connected as $($user.displayName)" -ForegroundColor Green
    Write-Host "   Account ID: $($user.accountId)" -ForegroundColor Cyan
    Write-Host "   IMPORTANT: Save this Account ID for agent configuration!" -ForegroundColor Yellow
    
    # Save account ID to a file for easy reference
    $user.accountId | Out-File "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate\YOUR_JIRA_ACCOUNT_ID.txt" -Encoding UTF8
    Write-Host "   Account ID saved to: YOUR_JIRA_ACCOUNT_ID.txt" -ForegroundColor Green
} catch {
    Write-Host "   FAILED: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Confluence Connection
Write-Host "Test 2: Confluence Connection" -ForegroundColor Yellow
Write-Host "   URL: $env:CONFLUENCE_BASE_PATH" -ForegroundColor Gray
try {
    $spaces = dmtools confluence_list_spaces | ConvertFrom-Json
    $spaceCount = $spaces.results.Count
    Write-Host "   SUCCESS: Found $spaceCount space(s)" -ForegroundColor Green
    if ($spaceCount -gt 0) {
        Write-Host "   Spaces:" -ForegroundColor Cyan
        $spaces.results | Select-Object -First 5 | ForEach-Object {
            Write-Host "      - $($_.name) (key: $($_.key))" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "   FAILED: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Gemini AI
Write-Host "Test 3: Gemini AI" -ForegroundColor Yellow
Write-Host "   Model: $env:GEMINI_DEFAULT_MODEL" -ForegroundColor Gray
try {
    $response = dmtools gemini_ai_chat "Respond with exactly: Configuration test successful"
    if ($response -match "Configuration test successful" -or $response -match "successful") {
        Write-Host "   SUCCESS: AI is responding correctly" -ForegroundColor Green
        Write-Host "   Response: $response" -ForegroundColor Cyan
    } else {
        Write-Host "   WARNING: Connected but unexpected response" -ForegroundColor Yellow
        Write-Host "   Response: $response" -ForegroundColor Gray
    }
} catch {
    Write-Host "   FAILED: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: GitHub (optional)
Write-Host "Test 4: GitHub (optional)" -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "token $env:GITHUB_TOKEN"
        "Accept" = "application/vnd.github.v3+json"
    }
    $githubUser = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
    Write-Host "   SUCCESS: Connected as $($githubUser.login)" -ForegroundColor Green
    Write-Host "   Name: $($githubUser.name)" -ForegroundColor Cyan
} catch {
    Write-Host "   Could not verify (this is optional)" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: Figma (optional)
Write-Host "Test 5: Figma (optional)" -ForegroundColor Yellow
try {
    $headers = @{
        "X-Figma-Token" = $env:FIGMA_API_KEY
    }
    $figmaUser = Invoke-RestMethod -Uri "https://api.figma.com/v1/me" -Headers $headers
    Write-Host "   SUCCESS: Connected as $($figmaUser.email)" -ForegroundColor Green
} catch {
    Write-Host "   Could not verify (this is optional)" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Required Services:" -ForegroundColor White
Write-Host "  - Jira: Check results above" -ForegroundColor Green
Write-Host "  - Confluence: Check results above" -ForegroundColor Green
Write-Host "  - Gemini AI: Check results above" -ForegroundColor Green
Write-Host ""
Write-Host "Optional Services:" -ForegroundColor White
Write-Host "  - GitHub: Check results above" -ForegroundColor Yellow
Write-Host "  - Figma: Check results above" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Check YOUR_JIRA_ACCOUNT_ID.txt for your Jira account ID" -ForegroundColor White
Write-Host "  2. Update agents/learning_questions.json with your account ID" -ForegroundColor White
Write-Host "  3. Follow 04-jira-project-setup.md to create test project" -ForegroundColor White
Write-Host "  4. Configure GitHub Secrets (see CREDENTIALS_CONFIGURED.md)" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

