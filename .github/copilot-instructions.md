# Copilot Instructions for SDLC Standards Plugin

This document provides guidance for GitHub Copilot when working with the SDLC Standards Plugin repository.

## Project Overview

The SDLC Standards Plugin is a Claude Code plugin that provides comprehensive Software Development Lifecycle standards guidance. It works with any AI coding assistant (Claude, Gemini, Codex, Copilot, OpenCode, etc.) and codifies project quality requirements across the entire software development lifecycle.

## Repository Structure

```
sdlc-quality/
├── .claude-plugin/          # Claude Code plugin configuration
│   └── plugin.json          # Plugin manifest
├── .github/
│   ├── actions/
│   │   └── sdlc-check/      # Composite action for compliance checks
│   ├── workflows/
│   │   ├── ci.yml           # CI pipeline
│   │   └── sdlc-audit.yml   # Reusable SDLC audit workflow
│   ├── copilot-instructions.md  # This file
│   └── ISSUE_TEMPLATE/      # Issue templates
├── agents/                  # Autonomous agent definitions
├── commands/                # Slash command definitions
├── skills/                  # Domain-specific skill guidance
├── docs/                    # Documentation
│   ├── adrs/               # Architecture Decision Records
│   └── PROJECT_REQUIREMENTS.md
└── scripts/                # Utility scripts
```

## Key Conventions

### RFC 2119 Terminology

This project uses RFC 2119 compliance levels:

- **MUST**: Mandatory requirement. Non-compliance blocks release.
- **SHOULD**: Strong recommendation. Should be followed unless there's good reason not to.
- **MAY**: Optional enhancement. Nice to have.

### SDLC Domains

The plugin covers 11 domains:

1. **build** - Build system configuration (Makefile, dependencies)
2. **quality** - Code formatting, linting, error handling
3. **testing** - Test organization, coverage, patterns
4. **ci** - CI/CD pipeline configuration
5. **security** - Vulnerability scanning, supply chain, secrets
6. **docs** - Documentation requirements (README, CHANGELOG, ADRs)
7. **vcs** - Version control practices (git, branching, commits)
8. **release** - Semantic versioning, release automation
9. **observability** - Logging, metrics, health checks
10. **ai** - AI coding assistant context configuration
11. **setup** - Project initialization and scaffolding

### File Naming

- Skills: `skills/<domain>/SKILL.md`
- Agents: `agents/<name>.md`
- Commands: `commands/<name>.md`
- All use YAML frontmatter for metadata

### Code Style

- Shell scripts: POSIX-compatible when possible, bash for complex logic
- Use `set -euo pipefail` in shell scripts
- Prefer composition over monolithic scripts
- Use `shellcheck` for linting

## When Modifying This Repository

### Adding a New Skill

1. Create `skills/<domain>/SKILL.md`
2. Include YAML frontmatter with `name` and `description`
3. Structure content with:
   - Overview section
   - Requirements (MUST/SHOULD/MAY)
   - Technology-specific examples
   - Common pitfalls

### Adding a New Agent

1. Create `agents/<name>.md`
2. Include YAML frontmatter:
   ```yaml
   ---
   description: Brief description of what the agent does
   whenToUse: When this agent should be triggered
   color: blue|green|yellow|red
   ---
   ```
3. Define clear behavior guidelines
4. Specify tools the agent should use

### Adding a New Check Module

1. Create `scripts/checks/<domain>.sh`
2. Implement `check_<domain>()` function
3. Use `add_finding` for issues:
   ```bash
   add_finding "domain" "$SEVERITY_MUST" "Message" "file" "line"
   ```
4. Use `set_domain_score` at the end

### Modifying GitHub Actions

- Always pin action versions (e.g., `@v4`, not `@main`)
- Use environment variables for untrusted inputs (issue titles, etc.)
- Add `continue-on-error: true` for non-critical steps
- Include proper permissions block

## Testing

Before submitting changes:

1. Run `make lint` to check formatting
2. Run `make test` to run validation scripts
3. Test the composite action locally if modifying checks
4. Verify all markdown links are valid

## Common Tasks

### Running a Local Compliance Check

```bash
# From any project directory
source /path/to/sdlc-quality/.github/actions/sdlc-check/scripts/sdlc-check.sh
run_sdlc_checks "all"
```

### Adding Technology-Specific Examples

When adding examples for a new language/framework:

1. Add to the relevant skill file in `skills/<domain>/SKILL.md`
2. Include complete, working examples
3. Show both configuration and CLI usage
4. Reference official documentation

## Do Not

- Add secrets or credentials to any files
- Use `@latest` or `@main` for action versions
- Create files without proper frontmatter where required
- Skip shellcheck validation for shell scripts
- Add dependencies without documenting them

## References

- [Claude Code Plugin Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
