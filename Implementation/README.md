# DMTools AI Teammate Learning Project

A comprehensive hands-on tutorial for learning AI agent automation with DMTools, GitHub Actions, and Jira integration.

---

## ✅ Installation Status: COMPLETE

**DMTools Version:** 1.7.102  
**MCP Tools:** 136 available  
**Java:** OpenJDK 21.0.5 LTS  
**Configuration:** All credentials configured

### 🚀 Quick Actions

**Test your installation now (5 minutes):**
```powershell
cd "c:\Users\AndreyPopov\Documents\EPAM\AWS\GenAI Architect\ai-teammate"
.\test-dmtools-complete.ps1
```

**New Documentation:**
- **[QUICK-START-NOW.md](QUICK-START-NOW.md)** ← **START HERE to test!**
- **[INSTALLATION-COMPLETE.md](INSTALLATION-COMPLETE.md)** - Full installation summary
- **[dmtools-tools-reference.md](dmtools-tools-reference.md)** - All 136 tools catalog
- **[dmtools-verification-results.md](dmtools-verification-results.md)** - Build & test report

---

## Quick Start

**For newcomers, start here:** [00-learning-summary.md](00-learning-summary.md)

**Installation complete? Test now:** [QUICK-START-NOW.md](QUICK-START-NOW.md)

**Then follow the guides in order:**

### Phase 1: Setup (1-2 hours)
1. [01-api-credentials-guide.md](01-api-credentials-guide.md) - Get API tokens
2. [02-dmtools-installation.md](02-dmtools-installation.md) - Install dmtools CLI
3. [dmtools-env-template.md](dmtools-env-template.md) - Configure environment
4. [03-mcp-connection-test.md](03-mcp-connection-test.md) - Test connections

### Phase 2: Jira Setup (20 minutes)
5. [04-jira-project-setup.md](04-jira-project-setup.md) - Create test project

### Phase 3: Agent Development (1 hour)
6. [05-local-testing-guide.md](05-local-testing-guide.md) - Test locally
7. Agent configuration: [`agents/learning_questions.json`](agents/learning_questions.json)
8. Post-processing: [`agents/createQuestionsSimple.js`](agents/createQuestionsSimple.js)

### Phase 4: Automation (1-2 hours)
9. [06-github-actions-setup.md](06-github-actions-setup.md) - Set up CI/CD
10. [07-jira-automation-setup.md](07-jira-automation-setup.md) - Configure triggers

### Phase 5: Troubleshooting & Review
11. [08-troubleshooting-guide.md](08-troubleshooting-guide.md) - Problem solving
12. [00-learning-summary.md](00-learning-summary.md) - Final review

## What You'll Build

```
User assigns Jira ticket to "AI Teammate"
  ↓
Jira automation triggers GitHub Actions workflow
  ↓
Workflow calls dmtools CLI with Gemini API
  ↓
AI analyzes ticket and generates clarifying questions
  ↓
Questions are created as Jira sub-tickets
  ↓
Ticket is assigned back to user for review
```

## Prerequisites

- Windows 10+ with PowerShell
- Jira account (Atlassian Cloud)
- GitHub account
- Google account (for Gemini API)
- Text editor or IDE

## What You'll Learn

### Technical Skills
- ✅ API integration (Jira, Confluence, Gemini)
- ✅ GitHub Actions workflows
- ✅ dmtools CLI and MCP protocol
- ✅ Prompt engineering for structured output
- ✅ JavaScript post-processing
- ✅ Event-driven automation

### Conceptual Skills
- ✅ AI agent architecture
- ✅ Human-in-the-loop design
- ✅ Idempotency and state management
- ✅ Integration-centric vs model-centric AI
- ✅ Production automation patterns

## Files in This Project

### Documentation
```
ai-teammate/
├── README.md                           # This file
├── 00-learning-summary.md              # Overview and architecture comparison
├── 01-api-credentials-guide.md         # API token setup
├── 02-dmtools-installation.md          # CLI installation
├── 03-mcp-connection-test.md           # Integration testing
├── 04-jira-project-setup.md            # Jira project creation
├── 05-local-testing-guide.md           # Local execution
├── 06-github-actions-setup.md          # CI/CD setup
├── 07-jira-automation-setup.md         # Event triggers
├── 08-troubleshooting-guide.md         # Problem solving
└── dmtools-env-template.md             # Environment configuration
```

### Agent Configuration
```
ai-teammate/
└── agents/
    ├── learning_questions.json         # Agent definition
    └── createQuestionsSimple.js        # Post-processing script
```

### Workflow Definition
```
.github/
└── workflows/
    └── learning-ai-teammate.yml        # GitHub Actions workflow
```

## Comparison with AWS GenAI Architect

This project demonstrates a different approach to AI agents compared to AWS:

| Aspect | AWS GenAI | DMTools AI Teammate |
|--------|-----------|---------------------|
| **Focus** | Learn AI fundamentals | Automate real workflows |
| **AI Model** | AWS Bedrock (managed) | Direct API (Gemini/GPT) |
| **Knowledge** | Static files (FAISS) | Live APIs (Jira/Confluence) |
| **Execution** | Jupyter → Lambda | GitHub Actions |
| **Trigger** | Manual/API call | Event-driven (Jira) |
| **Output** | Return text | Execute system actions |

See [00-learning-summary.md](00-learning-summary.md) for detailed comparison.

## Time Investment

- **Initial Setup:** 1-2 hours
- **Agent Development:** 1 hour
- **GitHub Actions:** 1 hour
- **Jira Automation:** 30 minutes
- **Testing & Troubleshooting:** 30 minutes
- **Total:** 4-5 hours

## Support

### If You Get Stuck

1. Check [08-troubleshooting-guide.md](08-troubleshooting-guide.md)
2. Review [00-learning-summary.md](00-learning-summary.md) for concepts
3. Test each layer independently:
   - Layer 1: Credentials (can you curl the APIs?)
   - Layer 2: dmtools CLI (does `dmtools list` work?)
   - Layer 3: AI (does Gemini return JSON?)
   - Layer 4: JavaScript (does parsing work?)
   - Layer 5: Jira (are tickets created?)

### Additional Resources

- **DMTools repo:** [https://github.com/IstiN/dmtools](https://github.com/IstiN/dmtools)
- **dmtools-ai-teammate:** `c:\Users\AndreyPopov\dmtools-ai-teammate\`
- **MCP Protocol:** [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- **Gemini API:** [https://ai.google.dev/docs](https://ai.google.dev/docs)

## Next Steps After Learning

1. **Enhance the agent:**
   - Add Confluence context
   - Analyze codebase
   - Prioritize questions with ML

2. **Create new agents:**
   - Bug triage agent
   - Story description enhancer
   - Release notes generator

3. **Scale to production:**
   - Error handling
   - Monitoring and alerting
   - Rate limiting
   - Security hardening

4. **Integrate with other tools:**
   - Slack notifications
   - Email summaries
   - GitHub issues
   - Analytics dashboards

## Success Criteria

You've successfully completed this learning project when:

- [ ] ✅ dmtools CLI is working
- [ ] ✅ All API connections tested
- [ ] ✅ Jira project created with test tickets
- [ ] ✅ Agent runs locally and generates JSON
- [ ] ✅ GitHub Actions workflow executes successfully
- [ ] ✅ Jira automation triggers workflow
- [ ] ✅ Sub-tickets are created automatically
- [ ] ✅ You understand the architecture
- [ ] ✅ You can troubleshoot issues
- [ ] ✅ You can create new agents

## Acknowledgments

- **DMTools:** Created by IstiN
- **Architecture inspiration:** AWS GenAI Architect examples
- **MCP Protocol:** Anthropic and community

## License

This learning project is for educational purposes. DMTools is licensed under its own terms.

---

**Ready to begin?**

Start with [01-api-credentials-guide.md](01-api-credentials-guide.md) to get your API tokens!

Or jump to [00-learning-summary.md](00-learning-summary.md) for a high-level overview first.

**Happy learning! 🎓**

