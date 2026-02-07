---
name: AI-Assisted Development Standards
description: This skill should be used when the user asks about "AI development", "AI coding", "AI assistant", "CLAUDE.md", "AI context", "AI guidelines", "code generation", "AI workflow", "AI review", "AI configuration", or needs guidance on configuring AI assistants and AI-assisted development workflows.
version: 1.0.0
---

# AI-Assisted Development Standards

Guidance for implementing AI-assisted development requirements including context configuration, workflow integration, and quality practices.

## Tooling

> **Available Tools**: If using Claude Code, the `pr-review-toolkit` provides AI-powered code review agents. The `feature-dev` plugin offers guided feature development workflows.

## AI Context Configuration

### Context Files (MUST)

Projects using AI assistants MUST maintain context files:

| File                              | Purpose                      | Location        |
| --------------------------------- | ---------------------------- | --------------- |
| `CLAUDE.md`                       | Claude-specific instructions | Repository root |
| `.cursorrules`                    | Cursor AI configuration      | Repository root |
| `AI_CONTEXT.md`                   | Generic AI context           | Repository root |
| `.github/copilot-instructions.md` | GitHub Copilot               | `.github/`      |

### Context File Content (MUST)

AI context files MUST include:

| Section          | Content                         |
| ---------------- | ------------------------------- |
| Project overview | Brief description and purpose   |
| Architecture     | Key patterns and structures     |
| Conventions      | Naming, formatting, style rules |
| Constraints      | What AI should NOT do           |
| Key files        | Important files to understand   |

### Context File Template

```markdown
# Project Context for AI Assistants

## Overview

Brief project description and purpose.

## Architecture

- Pattern: [MVC/Clean Architecture/etc.]
- Key directories and their purposes
- Core abstractions

## Conventions

- Naming: camelCase for functions, PascalCase for types
- Error handling: Use Result types
- Testing: Unit tests alongside source

## Constraints

- Do NOT modify configuration files without asking
- Do NOT add new dependencies without approval
- Always run tests after changes

## Key Files

- `src/lib.rs` - Main library entry
- `src/config.rs` - Configuration handling
```

## AI-Generated Code Requirements

### Review Requirements (MUST)

All AI-generated code MUST be:

- Reviewed by a human developer
- Tested before merge
- Compliant with project standards
- Free of security vulnerabilities

### Code Quality (MUST)

AI-generated code MUST meet the same standards as human-written code:

- Pass all linting rules
- Include appropriate tests
- Follow project conventions
- Be properly documented

### Attribution (SHOULD)

AI-generated code SHOULD be attributable:

- Commit messages may indicate AI assistance
- Significant AI contributions noted in PR description
- License compliance verified

## AI Workflow Integration

### Development Workflow

| Phase          | AI Integration                   |
| -------------- | -------------------------------- |
| Planning       | Use for architecture exploration |
| Implementation | Code generation with review      |
| Testing        | Test case generation             |
| Review         | AI-assisted code review          |
| Documentation  | Doc generation and review        |

### Review Workflow (MUST)

AI-assisted code reviews MUST:

1. Run automated checks first
2. Apply AI review as additional layer
3. Require human final approval
4. Document AI findings

### Iterative Refinement (SHOULD)

When using AI for code generation:

1. Start with clear requirements
2. Review initial output
3. Provide specific feedback
4. Iterate until satisfactory
5. Final human review

## Security Considerations

### Sensitive Data (MUST NOT)

AI context and prompts MUST NOT include:

- API keys or secrets
- Passwords or credentials
- Production database contents
- Customer data
- Internal security details

### Code Review for Security (MUST)

AI-generated code MUST be reviewed for:

- Input validation
- Authentication/authorization
- Injection vulnerabilities
- Secure defaults
- Error handling that doesn't leak info

### Dependency Addition (MUST)

AI-suggested dependencies MUST be:

- Reviewed for necessity
- Checked for security vulnerabilities
- Verified for license compatibility
- Approved before addition

## Quality Assurance

### Testing AI Code (MUST)

AI-generated code MUST:

- Have test coverage matching project standards
- Include edge case tests
- Be verified manually for logic correctness
- Pass all existing tests

### Documentation (MUST)

AI-generated documentation MUST be:

- Reviewed for accuracy
- Checked for completeness
- Verified against actual code behavior
- Updated when code changes

## Team Guidelines

### Training (SHOULD)

Teams SHOULD:

- Establish AI usage guidelines
- Train developers on effective prompting
- Share successful patterns
- Document lessons learned

### Consistency (MUST)

AI usage MUST:

- Follow team-agreed practices
- Use consistent context files
- Apply uniform quality standards
- Be transparent about AI involvement

## Implementation Checklist

- [ ] Create AI context file (CLAUDE.md or equivalent)
- [ ] Document project conventions
- [ ] Define AI constraints and boundaries
- [ ] Establish review requirements
- [ ] Configure AI tools (if applicable)
- [ ] Train team on AI workflows
- [ ] Set up quality gates

## Compliance Verification

```bash
# Check for AI context file
ls CLAUDE.md .cursorrules AI_CONTEXT.md 2>/dev/null

# Verify no secrets in context files
grep -r -i "api_key\|secret\|password" CLAUDE.md .cursorrules 2>/dev/null
# Should return nothing

# Check context file has required sections
grep -E "^##" CLAUDE.md | head -10
```

## Context File Best Practices

### Keep Updated (MUST)

Context files MUST be updated when:

- Architecture changes
- New conventions adopted
- Constraints modified
- Key files change

### Be Specific (SHOULD)

Context files SHOULD:

- Provide concrete examples
- Reference specific files
- Explain the "why" behind rules
- Include anti-patterns to avoid

### Be Concise (SHOULD)

Context files SHOULD:

- Focus on essential information
- Avoid redundant documentation
- Link to detailed docs rather than duplicate
- Target 500-2000 words

## Additional Resources

### Reference Files

- **`references/ai-context-guide.md`** - Detailed context file guide
- **`references/ai-security.md`** - Security considerations

### Examples

- **`examples/CLAUDE.md`** - Example Claude context file
- **`examples/.cursorrules`** - Example Cursor configuration
