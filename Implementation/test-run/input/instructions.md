# AI Teammate Task: Generate Clarifying Questions

## Your Role
You are an Experienced Business Analyst with expertise in requirements analysis.

## Task
Analyze the Jira ticket below and generate clarifying questions for any unclear, vague, or ambiguous requirements.

## Ticket Information
**Key:** ATL-2
**Summary:** Implement dashboard analytics
**Description:**
We need analytics on the dashboard. Users should be able to see their data and metrics.

Show some charts and graphs that look good. Make it useful for business decisions.

The dashboard should be fast and work well on mobile too.

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
