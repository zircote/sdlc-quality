# AGENTS.md - OpenAI Codex Guidelines

This file provides guidelines for OpenAI Codex and other AI agents working with the sdlc plugin.

## Project Identity

**Plugin Name**: `sdlc`
**Purpose**: Comprehensive Software Development Lifecycle standards and compliance checking
**Repository**: https://github.com/zircote/sdlc-quality
**License**: MIT

## Quick Context

```
┌─────────────────────────────────────────────────────────────┐
│                        sdlc plugin                           │
├─────────────────────────────────────────────────────────────┤
│  Build │ Quality │ Testing │ CI/CD │ Security │ Docs │ VCS │
│   ✓    │    ✓    │    ✓    │   ✓   │    ✓     │  ✓   │  ✓  │
└─────────────────────────────────────────────────────────────┘
```

This plugin validates projects against SDLC best practices across 11 domains.

## Agent Guidelines

### 1. Understand the Domain Model

The plugin uses RFC 2119 severity levels:

- **MUST** (Critical): Mandatory requirements
- **SHOULD** (Important): Strong recommendations
- **MAY** (Suggestion): Optional enhancements

### 2. Repository Layout

| Path                          | Purpose                                                  |
| ----------------------------- | -------------------------------------------------------- |
| `skills/`                     | Domain-specific guidance (build, quality, testing, etc.) |
| `agents/`                     | Autonomous agent definitions for Claude Code             |
| `commands/`                   | Slash command implementations                            |
| `.github/actions/sdlc-check/` | GitHub Action for compliance checking                    |
| `.github/workflows/`          | CI and audit workflows                                   |
| `docs/`                       | Extended documentation and ADRs                          |

### 3. Code Conventions

**Shell Scripts**:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Use functions for organization
my_function() {
  local arg="$1"
  # Implementation
}

# Export for subshells if needed
export -f my_function
```

**YAML Frontmatter** (for skills/agents/commands):

```yaml
---
name: example
description: Brief description
---
# Content starts here
```

### 4. When Adding Features

**New Skill**:

1. Create `skills/<domain>/SKILL.md`
2. Include requirements categorized by MUST/SHOULD/MAY
3. Add technology-specific examples (Rust, TypeScript, Python, Go, Java)
4. Reference official documentation

**New Check Module**:

1. Create `scripts/checks/<domain>.sh`
2. Implement `check_<domain>` function
3. Use provided utilities:
   ```bash
   add_finding "domain" "$SEVERITY_MUST" "Message" "file.txt" "42"
   set_domain_score "domain" 8
   ```

**New Agent**:

1. Create `agents/<name>.md`
2. Define clear scope and triggers
3. Specify available tools
4. Include behavior guidelines

### 5. Security Considerations

**DO**:

- Pin GitHub Action versions to tags or SHAs
- Use environment variables for untrusted inputs in workflows
- Validate and sanitize all inputs
- Follow least-privilege for permissions

**DO NOT**:

- Commit secrets or credentials
- Use `@latest` or `@main` for actions
- Trust user-provided data without validation
- Add overly permissive workflow permissions

### 6. Testing Requirements

Before submitting changes:

```bash
# Run linting
make lint

# Run tests
make test

# Validate plugin structure
./scripts/test.sh
```

### 7. Documentation Standards

- README must include: overview, installation, usage, contributing
- CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/)
- ADRs for architectural decisions in `docs/adrs/`
- All public APIs documented

## Interaction Examples

### Example 1: Adding a New Domain Check

User request: "Add a check for database migration practices"

Response approach:

1. Create `skills/database/SKILL.md` with migration requirements
2. Create `scripts/checks/database.sh` with validation logic
3. Update `sdlc-check.sh` to source the new module
4. Add to domain list in action inputs
5. Document in README

### Example 2: Fixing a Compliance Issue

User request: "The security check is failing for my Rust project"

Response approach:

1. Identify the specific finding from the report
2. Reference `skills/security/SKILL.md` for requirements
3. Provide Rust-specific remediation (cargo-deny, cargo-audit)
4. Include configuration examples

### Example 3: Extending the GitHub Action

User request: "Add support for custom report templates"

Response approach:

1. Add input parameter to `action.yml`
2. Update `report-generator.sh` to accept template path
3. Provide default template
4. Document usage in `docs/GITHUB_ACTIONS.md`

## Integration with Other AI Agents

This repository is designed for multi-agent interoperability:

| Agent          | Configuration File                | Purpose                        |
| -------------- | --------------------------------- | ------------------------------ |
| Claude Code    | `CLAUDE.md`, `.claude-plugin/`    | Full plugin with skills/agents |
| GitHub Copilot | `.github/copilot-instructions.md` | Repository context             |
| OpenAI Codex   | `AGENTS.md` (this file)           | Guidelines and structure       |
| Cursor         | `.cursorrules`                    | Editor-specific rules          |

All agents should:

1. Respect RFC 2119 terminology
2. Follow existing code patterns
3. Maintain documentation parity
4. Test changes before committing

## Quick Reference

### Domain Scores

Each domain is scored 0-10:

- 8-10: Compliant ✅
- 5-7: Needs attention ⚠️
- 0-4: Critical issues ❌

### Finding Severities

```bash
SEVERITY_MUST=3    # Critical - blocks release
SEVERITY_SHOULD=2  # Important - should fix
SEVERITY_MAY=1     # Suggestion - nice to have
```

### Useful Commands

```bash
# Run full audit
/sdlc:check

# Initialize new project
/sdlc:init

# Check specific domain
./scripts/sdlc-check.sh build,quality
```

## Contact

- Issues: https://github.com/zircote/sdlc-quality/issues
- Discussions: https://github.com/zircote/sdlc-quality/discussions
