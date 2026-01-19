# Usage Guide

Complete guide to using the SDLC Standards Plugin with Claude Code.

## Installation

### From GitHub

```bash
claude plugins add github:zircote/sdlc-quality
```

### From Local Directory

```bash
claude plugins add /path/to/sdlc-quality
```

### Verify Installation

```bash
claude plugins list
```

You should see `sdlc` in the list of installed plugins.

## Quick Start

### Check Project Compliance

Run a compliance check on your current project:

```bash
claude "/sdlc:check"
```

This will analyze your project against SDLC standards and report:
- Build system configuration
- Code quality setup
- Testing practices
- CI/CD pipeline
- Security scanning
- Documentation completeness
- Version control practices

### Initialize a New Project

Set up a new project with SDLC-compliant structure:

```bash
claude "/sdlc:init"
```

This creates:
- Standard directory structure
- Required documentation files
- Build system (Makefile)
- CI/CD workflow
- Issue and PR templates
- ADR directory

## Skills Reference

Skills are automatically activated when you ask related questions.

### Build System (`sdlc:build`)

**Triggers:**
- "How should I set up my build system?"
- "What Makefile targets do I need?"
- "Configure build profiles"

**Provides:**
- Required build targets (build, test, lint, format, clean, ci)
- Build profile configuration (dev vs release)
- Dependency management best practices
- Lockfile requirements

**Example:**
```
User: How do I set up a Makefile for my Rust project?
Claude: [Provides SDLC-compliant Makefile with all required targets]
```

### Code Quality (`sdlc:quality`)

**Triggers:**
- "Configure linting"
- "Set up code formatting"
- "Error handling best practices"

**Provides:**
- Formatter configuration
- Linter rules and configuration
- Error handling patterns
- Documentation comment requirements

### Testing (`sdlc:testing`)

**Triggers:**
- "Test organization"
- "Coverage requirements"
- "Testing best practices"

**Provides:**
- Test directory structure
- Coverage targets (80% general, 95% critical paths)
- Test naming conventions
- Arrange-Act-Assert pattern

### CI/CD (`sdlc:ci`)

**Triggers:**
- "Set up GitHub Actions"
- "Configure CI pipeline"
- "CI job structure"

**Provides:**
- Required CI jobs (format, lint, test, security)
- Job ordering and dependencies
- Caching configuration
- Multi-platform testing

### Security (`sdlc:security`)

**Triggers:**
- "Dependency security scanning"
- "Supply chain security"
- "License compliance"

**Provides:**
- Vulnerability scanning setup
- License allowlist
- Security audit schedules
- Secret scanning configuration

### Documentation (`sdlc:docs`)

**Triggers:**
- "README requirements"
- "Changelog format"
- "Documentation standards"

**Provides:**
- Required documentation files
- README section requirements
- Keep a Changelog format
- ADR structure

### Version Control (`sdlc:vcs`)

**Triggers:**
- "Git branching strategy"
- "Commit message format"
- "PR standards"

**Provides:**
- Branch protection rules
- Conventional Commits format
- PR template requirements
- .gitignore and .gitattributes

### Release (`sdlc:release`)

**Triggers:**
- "Semantic versioning"
- "Release process"
- "Distribution channels"

**Provides:**
- SemVer requirements
- Release workflow
- Artifact checksums
- Multi-channel distribution

### Observability (`sdlc:observability`)

**Triggers:**
- "Logging requirements"
- "Metrics setup"
- "Performance targets"

**Provides:**
- Structured logging setup
- Metrics naming conventions
- Performance benchmarking
- Tracing configuration

### AI Context (`sdlc:ai`)

**Triggers:**
- "CLAUDE.md configuration"
- "AI coding assistant setup"
- "Copilot instructions"

**Provides:**
- AI context file structure
- Version discovery requirements
- Code generation standards
- Prohibited patterns

## Agents Reference

Agents perform autonomous, multi-step analysis.

### Compliance Auditor

**When to use:**
- Full project compliance assessment
- Pre-release audit
- Periodic compliance review

**Usage:**
```
User: Run a full SDLC compliance audit
Claude: [Runs compliance-auditor agent]
```

**Output:**
- Overall compliance score
- Domain-by-domain breakdown
- Critical/important findings
- Remediation steps

### Security Reviewer

**When to use:**
- Security-focused analysis
- Vulnerability assessment
- Supply chain review

**Usage:**
```
User: Review this project for security issues
Claude: [Runs security-reviewer agent]
```

**Output:**
- Security score
- Vulnerability findings
- Supply chain risks
- Remediation priorities

### Quality Enforcer

**When to use:**
- Code quality assessment
- Pre-PR review
- Quality gate validation

**Usage:**
```
User: Check code quality standards
Claude: [Runs quality-enforcer agent]
```

**Output:**
- Quality score
- Formatting issues
- Linting violations
- Error handling problems

### CI Architect

**When to use:**
- CI/CD pipeline design
- Workflow optimization
- Pipeline troubleshooting

**Usage:**
```
User: Design a CI pipeline for this project
Claude: [Runs ci-architect agent]
```

**Output:**
- Pipeline design
- Job configuration
- Optimization suggestions
- Security hardening

## Commands Reference

### `/sdlc:check`

Run compliance check on current project.

**Syntax:**
```bash
/sdlc:check
```

**Options:**
- No arguments: Full check
- Future: `--quick` for essential files only

**Output:**
- Compliance report
- Domain scores
- Issue list
- Remediation steps

### `/sdlc:init`

Initialize SDLC-compliant project structure.

**Syntax:**
```bash
/sdlc:init
```

**Process:**
1. Detect or ask for language
2. Create directory structure
3. Generate required files
4. Set up build system
5. Configure CI/CD
6. Create templates

**Created Files:**
```
├── .github/
│   ├── workflows/ci.yml
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   └── adrs/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── README.md
└── SECURITY.md
```

## GitHub Actions Integration

Run SDLC compliance checks automatically in CI/CD pipelines.

### Quick Start

```yaml
# .github/workflows/sdlc.yml
name: SDLC Compliance

on: [pull_request, push]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
```

### Full Configuration

```yaml
- uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
  with:
    domains: 'all'           # or 'security,ci,docs'
    fail-on-error: 'true'
    report-format: 'all'     # markdown, json, sarif
    create-pr-comment: 'true'
    create-issue: 'true'
```

### Available Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `domains` | Domains to check (or "all") | `all` |
| `fail-on-error` | Fail if MUST requirements unmet | `true` |
| `report-format` | Output format(s) | `markdown` |
| `create-pr-comment` | Comment on PR | `true` |
| `create-issue` | Create issue on failure | `false` |

### Outputs

| Output | Description |
|--------|-------------|
| `score` | Overall compliance score (0-100) |
| `status` | pass, warn, or fail |
| `critical-count` | MUST violations count |

See [GitHub Actions Integration](GITHUB_ACTIONS.md) for complete documentation.

## Integration Examples

### With Existing Project

1. Install plugin
2. Run `/sdlc:check` to assess current state
3. Address critical findings
4. Run agents for deep analysis
5. Iterate until compliant

### New Project from Scratch

1. Create empty directory
2. Run `/sdlc:init`
3. Add your source code
4. Run `/sdlc:check` to verify
5. Commit and push

### Pre-PR Workflow

```bash
# Before creating PR
claude "Check this project for SDLC compliance"

# Address any issues
claude "Fix the linting configuration"

# Verify fixes
claude "/sdlc:check"
```

### Continuous Compliance

Add to your workflow:

1. Local: `make ci` before pushing
2. CI: Automated checks on every PR
3. Periodic: Run full audit weekly/monthly

## Troubleshooting

### Plugin Not Found

```bash
# Verify installation
claude plugins list

# Reinstall if needed
claude plugins remove sdlc
claude plugins add github:zircote/sdlc-quality
```

### Skills Not Triggering

Skills activate based on keywords. Try:
- More specific queries
- Use exact terminology ("build system", "CI pipeline")
- Explicitly reference the standard

### Agent Errors

If an agent fails:
1. Check file permissions
2. Verify project structure
3. Try with simpler query
4. Check for missing dependencies

### Command Not Working

```bash
# Verify command syntax
/sdlc:check   # Correct
/check        # Wrong (not namespaced)
```

## Best Practices

### For Best Results

1. **Start with `/sdlc:check`**: Understand current state first
2. **Address critical issues first**: MUST requirements block releases
3. **Use agents for deep analysis**: More thorough than quick checks
4. **Iterate incrementally**: Fix one domain at a time
5. **Run checks locally**: Use `make ci` before pushing

### Maintaining Compliance

1. **Automate checks in CI**: Catch issues early
2. **Regular audits**: Run compliance auditor periodically
3. **Update standards**: Keep PROJECT_REQUIREMENTS.md current
4. **Train team**: Share standards with all contributors

## AI Agent Interoperability

This plugin supports multiple AI coding assistants:

| Agent | Configuration | Usage |
|-------|---------------|-------|
| Claude Code | `.claude-plugin/`, skills, agents | Install plugin, use `/sdlc:check` |
| GitHub Copilot | `.github/copilot-instructions.md` | Provides repo context to Copilot |
| OpenAI Codex | `AGENTS.md` | Guidelines for Codex interactions |

All agents reference the same SDLC standards from `docs/PROJECT_REQUIREMENTS.md`.

## Support

- **Issues**: [GitHub Issues](https://github.com/zircote/sdlc-quality/issues)
- **Discussions**: [GitHub Discussions](https://github.com/zircote/sdlc-quality/discussions)
- **Standards Reference**: [PROJECT_REQUIREMENTS.md](PROJECT_REQUIREMENTS.md)
