# Sample Ticket Descriptions for Testing

This file contains sample Jira ticket descriptions you can use to test your AI teammate agent.

## Category 1: Clear Requirements (Should Generate Few Questions)

### Sample 1: User Login
```
As a user, I want to be able to log in to the application using my email and password.

Acceptance Criteria:
- Login form with email and password fields
- "Remember me" checkbox
- "Forgot password" link
- Error message for invalid credentials: "Invalid email or password. Please try again."
- Redirect to dashboard after successful login
- Session timeout: 30 minutes of inactivity

Technical Notes:
- Use JWT for authentication
- Password must be hashed with bcrypt (salt rounds: 10)
- Store JWT in httpOnly cookie
- Database table: users (id, email, password_hash, created_at, last_login)

Design:
- Follow Material Design guidelines
- Mobile-responsive layout
- Accessibility: WCAG 2.1 AA compliant

Dependencies:
- Email service must be configured
- Database migration #045 must be applied
```

**Expected AI behavior:** 0-2 questions, requirements are very clear

---

## Category 2: Vague Requirements (Should Generate Many Questions)

### Sample 2: Dashboard Analytics
```
We need analytics on the dashboard. Users should be able to see their data and metrics.

Show some charts and graphs that look good. Make it useful for business decisions.

The dashboard should be fast and work well on mobile too.
```

**Expected AI questions:**
- What specific metrics should be displayed?
- Which user roles can access the dashboard?
- What time periods should the data cover?
- What types of charts are preferred?
- What constitutes "fast" performance?
- Are there any data export requirements?
- Should data be real-time or can it be cached?

### Sample 3: Improve Performance
```
The application is slow. Make it faster.

Users are complaining about performance issues. Fix whatever is causing the slowness.

Make sure it scales well for future growth.
```

**Expected AI questions:**
- Which specific features or pages are slow?
- What is the current response time?
- What is the target response time?
- How many concurrent users are experiencing issues?
- What does "scales well" mean quantitatively?
- Are there specific error logs or metrics available?
- What is the expected user growth?

### Sample 4: Add Notifications
```
Users want to receive notifications for important events.

Implement a notification system that keeps users informed about what's happening.

Should support different types of notifications and let users control what they see.
```

**Expected AI questions:**
- What are "important events"? (list specific events)
- What notification channels? (email, push, in-app, SMS?)
- What is the frequency limit? (avoid notification spam)
- Can users customize notification preferences?
- Should notifications be persistent or dismissible?
- Are there any regulatory requirements (GDPR, CAN-SPAM)?
- What is the priority system for notifications?

---

## Category 3: Technical Stories (Mixed Clarity)

### Sample 5: API Rate Limiting
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

Questions:
- Should we have different limits for different endpoints?
- How should we handle burst traffic?
```

**Expected AI questions:**
- What are the specific limits for anonymous users?
- What happens to requests that exceed the limit? (queue or reject?)
- Should there be a grace period or soft limit?
- How should rate limit information be communicated to API users?
- Are there any endpoints that should be exempt?

### Sample 6: Database Migration
```
Migrate user data from PostgreSQL to MongoDB.

Current schema:
- users table (10M rows)
- user_profiles table (10M rows)
- user_sessions table (50M rows)

Timeline: Complete by end of Q2.

Zero downtime migration required.
```

**Expected AI questions:**
- What is the data validation strategy?
- How will we handle schema differences?
- What is the rollback plan if migration fails?
- How will we verify data integrity?
- What is the cutover strategy?
- How will we handle writes during migration?
- Are there any data transformation requirements?

---

## Category 4: Edge Cases and Ambiguities

### Sample 7: File Upload
```
Allow users to upload files.

Supported formats: images, documents, videos.

Files should be stored securely and users should be able to download them later.

Add some validation to prevent bad files.
```

**Expected AI questions:**
- What is the maximum file size per upload?
- What specific image formats? (JPEG, PNG, GIF, WebP, etc.)
- What specific document formats? (PDF, DOCX, TXT, etc.)
- What specific video formats? (MP4, AVI, MOV, etc.)
- What constitutes a "bad file"? (virus scan, file type validation, content validation?)
- Where should files be stored? (S3, local filesystem, CDN?)
- Should there be a total storage limit per user?
- How long should files be retained?
- Should there be versioning?

### Sample 8: Payment Integration
```
Integrate payment processing so users can make purchases.

Support major credit cards and popular payment methods.

Make sure it's secure and complies with regulations.

Users should get receipts for their payments.
```

**Expected AI questions:**
- Which payment gateway? (Stripe, PayPal, Square, Braintree?)
- Which "major credit cards"? (Visa, Mastercard, Amex, Discover?)
- Which "popular payment methods"? (PayPal, Apple Pay, Google Pay, bank transfer?)
- Which regulations? (PCI DSS, GDPR, specific country regulations?)
- What information should receipts contain?
- How should receipts be delivered? (email, downloadable PDF, in-app?)
- What is the refund policy and process?
- Should there be payment history?
- What currencies should be supported?

---

## Category 5: Business Requirements with Missing Technical Details

### Sample 9: Search Functionality
```
Add search functionality so users can find content easily.

The search should be fast and accurate. Show relevant results first.

Users should be able to filter and sort results.
```

**Expected AI questions:**
- What content should be searchable? (users, posts, products, documents?)
- What fields should be searchable? (title, description, tags, content?)
- What constitutes "fast"? (response time SLA?)
- How should relevance be determined? (algorithm, ranking factors?)
- What filters are needed? (date, category, author, status?)
- What sort options? (relevance, date, popularity, alphabetical?)
- Should there be search suggestions/autocomplete?
- Should search history be saved?
- What is the expected search volume?

### Sample 10: Reporting System
```
Build a reporting system for managers.

Managers need to see team performance, project status, and other KPIs.

Reports should be exportable and shareable.

Update the reports regularly to keep data current.
```

**Expected AI questions:**
- Which specific KPIs should be tracked?
- What is "team performance"? (tickets closed, velocity, quality metrics?)
- What is "project status"? (on-time, budget, scope, risks?)
- Who are the "managers"? (role-based access control needed?)
- What export formats? (PDF, Excel, CSV?)
- How should reports be shared? (email, link, dashboard?)
- What does "regularly" mean? (real-time, hourly, daily?)
- Should there be historical data retention?
- Should reports be customizable?

---

## Testing Strategy

### For Each Sample:

1. **Create Jira ticket** with sample description
2. **Run AI teammate** agent on the ticket
3. **Review questions generated:**
   - Are they relevant?
   - Do they address actual ambiguities?
   - Are there false positives (questions about clear requirements)?
   - Are there false negatives (missing questions about unclear requirements)?

4. **Refine agent configuration:**
   - Update instructions
   - Add few-shot examples
   - Adjust prompt engineering

5. **Re-test** and compare results

### Quality Metrics

Good AI agent should:
- ✅ Generate 0-2 questions for Category 1 (clear requirements)
- ✅ Generate 5-10 questions for Category 2 (vague requirements)
- ✅ Generate 3-6 questions for Category 3 (mixed clarity)
- ✅ Focus on missing information, not obvious details
- ✅ Ask specific, actionable questions
- ✅ Prioritize critical questions as "High"

---

## Custom Test Cases

Add your own test cases here as you learn what works well and what doesn't:

### Test Case Template
```
Category: [Clear/Vague/Technical/Edge Case/Business]
Description:
[Your ticket description]

Expected number of questions: [X-Y]
Expected question topics:
- [Topic 1]
- [Topic 2]
- [Topic 3]
```

---

**Last Updated:** December 30, 2025  
**Purpose:** Testing samples for AI teammate question generation

