# Contributing to SDLC Standards Plugin

Thank you for your interest in contributing to the SDLC Standards Plugin.

## Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Content Guidelines](#content-guidelines)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Style Guide](#style-guide)
- [Getting Help](#getting-help)

## Development Setup

### Prerequisites

- Claude Code CLI installed
- Node.js 18+ (for linting/formatting tools)
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/zircote/sdlc-quality.git
cd sdlc-quality

# Install development dependencies
npm install

# Install the plugin locally for testing
claude plugins add .

# Verify installation
claude plugins list

# Run tests
make test

# Run linting
make lint
```

### Development Workflow

```bash
# 1. Create feature branch
git checkout -b feat/your-feature

# 2. Make changes

# 3. Format and lint
make format
make lint

# 4. Test locally
make test
claude "/sdlc:check"   # Test in a sample project

# 5. Commit and push
git commit -m "feat(skills): add new skill"
git push -u origin feat/your-feature
```

## Project Structure

```
sdlc-quality/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, version, description)
├── .github/
│   ├── workflows/ci.yml     # CI pipeline
│   ├── ISSUE_TEMPLATE/      # Bug/feature templates
│   └── PULL_REQUEST_TEMPLATE.md
├── agents/                   # Autonomous analysis agents
│   ├── compliance-auditor.md
│   ├── security-reviewer.md
│   ├── quality-enforcer.md
│   └── ci-architect.md
├── commands/                 # User-invokable commands
│   ├── check.md              # /sdlc:check
│   └── init.md               # /sdlc:init
├── docs/
│   ├── adrs/                 # Architecture Decision Records
│   ├── ARCHITECTURE.md       # System design
│   ├── USAGE.md              # Usage guide
│   └── PROJECT_REQUIREMENTS.md  # Canonical SDLC standards
├── scripts/
│   └── test.sh               # Test script
├── skills/                   # Topic-specific guidance
│   ├── build/SKILL.md
│   ├── quality/SKILL.md
│   ├── testing/SKILL.md
│   ├── ci/SKILL.md
│   ├── security/SKILL.md
│   ├── docs/SKILL.md
│   ├── vcs/SKILL.md
│   ├── release/SKILL.md
│   ├── observability/SKILL.md
│   ├── ai/SKILL.md
│   └── setup/SKILL.md
├── .claude/
│   └── documentation-review.local.md  # Doc review config
├── CHANGELOG.md
├── CONTRIBUTING.md           # This file
├── LICENSE
├── Makefile
├── package.json
├── README.md
└── SECURITY.md
```

## Content Guidelines

### RFC 2119 Terminology

All standards content MUST use RFC 2119 terminology:

| Term | Meaning | Example |
|------|---------|---------|
| **MUST** | Absolute requirement | "Projects MUST have a Makefile" |
| **MUST NOT** | Absolute prohibition | "Wildcards MUST NOT be used" |
| **SHOULD** | Strong recommendation | "Projects SHOULD have 80% coverage" |
| **SHOULD NOT** | Strong discouragement | "Panics SHOULD NOT occur in library code" |
| **MAY** | Optional | "Projects MAY include benchmarks" |

### Technology Agnosticism

Core content must be technology-agnostic:

**Good:**
```markdown
Projects MUST use a unified build system entry point.
```

**Bad:**
```markdown
Projects MUST use a Makefile.
```

Language-specific examples go at the end of each skill file.

### Writing Style

- Use active voice
- Be concise and direct
- Include practical examples
- Reference official documentation
- Use tables for structured data

## Making Changes

### Adding a Skill

1. Create `skills/<topic>/SKILL.md`
2. Add YAML frontmatter:
   ```yaml
   ---
   name: Topic Name
   description: When to trigger this skill (include keywords)
   version: 1.0.0
   ---
   ```
3. Write content following RFC 2119 terminology
4. Include language-specific examples at the end
5. Update PROJECT_REQUIREMENTS.md if introducing new standards

### Adding an Agent

1. Create `agents/<name>.md`
2. Add YAML frontmatter:
   ```yaml
   ---
   description: When to use this agent
   whenToUse: Detailed trigger conditions
   color: blue
   ---
   ```
3. Write clear system prompt instructions
4. Specify available tools (Glob, Grep, Read, Bash)
5. Define expected output format

### Adding a Command

1. Create `commands/<name>.md`
2. Commands MUST be namespaced: `/sdlc:<name>`
3. Add YAML frontmatter:
   ```yaml
   ---
   name: command-name
   description: What this command does
   ---
   ```
4. Document expected inputs and outputs
5. Include step-by-step execution instructions

### Modifying Standards

When changing PROJECT_REQUIREMENTS.md:

1. Ensure changes are technology-agnostic
2. Use RFC 2119 terminology
3. Update affected skills
4. Consider creating an ADR for significant changes
5. Update CHANGELOG.md

## Pull Request Process

### Before Submitting

1. Run all checks locally:
   ```bash
   make ci
   ```

2. Verify plugin works:
   ```bash
   claude plugins add .
   /sdlc:check  # In a test project
   ```

3. Update documentation:
   - CHANGELOG.md (if user-facing change)
   - README.md (if feature change)
   - ADR (if architectural decision)

### PR Requirements

- [ ] Passes CI checks
- [ ] Follows style guidelines
- [ ] Includes tests (where applicable)
- [ ] Updates documentation
- [ ] Has descriptive commit messages
- [ ] PR template filled out completely

### Branch Naming

```
feat/description    # New feature
fix/description     # Bug fix
docs/description    # Documentation
refactor/description  # Code restructuring
chore/description   # Maintenance
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

| Type | Purpose |
|------|---------|
| `feat` | New feature (skill, agent, command) |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Formatting (no content change) |
| `refactor` | Restructuring (no behavior change) |
| `test` | Test changes |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |

**Scopes:**
- `skills`, `skills/build`, `skills/ci`, etc.
- `agents`, `agents/compliance-auditor`, etc.
- `commands`, `commands/check`, etc.
- `docs`, `ci`, `deps`

**Examples:**
```bash
feat(skills): add kubernetes deployment skill
fix(agents/compliance-auditor): correct scoring calculation
docs: update installation instructions
chore(deps): update markdownlint-cli2 to 0.17.0
```

## Testing

### Automated Tests

```bash
# Run all tests
make test

# Run linting
make lint

# Run strict linting (warnings as errors)
make lint-strict

# Check formatting
make format-check

# Run full CI locally
make ci
```

### Manual Testing

1. **Install plugin locally:**
   ```bash
   claude plugins add .
   ```

2. **Test skills:**
   - Ask questions that should trigger each skill
   - Verify correct content is surfaced

3. **Test commands:**
   ```bash
   /sdlc:check    # Should produce compliance report
   /sdlc:init     # Should create structure (in test dir)
   ```

4. **Test agents:**
   - Request comprehensive audit
   - Verify agent runs autonomously
   - Check output format

### Test Projects

Keep sample projects for testing:
- One with full SDLC compliance (should pass)
- One with missing elements (should identify issues)
- One empty (for testing /sdlc:init)

## Style Guide

### Markdown

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers
- Keep lines under 100 characters (exceptions for tables/URLs)
- Use tables for structured data
- Ensure all links are valid
- No trailing whitespace
- Files end with newline

### YAML Frontmatter

```yaml
---
name: Descriptive Name
description: Clear description with keywords for matching
version: 1.0.0
---
```

### Code Examples

Always specify language in fenced blocks:

````markdown
```bash
make test
```

```rust
fn main() {
    println!("Hello, world!");
}
```
````

### Tables

Use proper alignment:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
```

## Getting Help

### Questions

- Open a [GitHub Discussion](https://github.com/zircote/sdlc-quality/discussions)
- Check existing issues and discussions first

### Bugs

- Open a [Bug Report](https://github.com/zircote/sdlc-quality/issues/new?template=bug_report.yml)
- Include reproduction steps
- Specify plugin and Claude Code versions

### Feature Requests

- Open a [Feature Request](https://github.com/zircote/sdlc-quality/issues/new?template=feature_request.yml)
- Explain the use case
- Describe proposed solution

### Security Issues

- See [SECURITY.md](SECURITY.md)
- Do NOT open public issues for security vulnerabilities

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to SDLC Standards Plugin!
