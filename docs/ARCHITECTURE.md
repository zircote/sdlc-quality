# Architecture Documentation

This document describes the architecture and design of the SDLC Standards Plugin.

## Overview

The SDLC Standards Plugin is a Claude Code plugin that provides comprehensive Software Development Lifecycle guidance for AI coding assistants. It uses a modular architecture with skills, agents, and commands to deliver standards-based guidance.

```
┌─────────────────────────────────────────────────────────────────┐
│                        Claude Code                               │
├─────────────────────────────────────────────────────────────────┤
│                     SDLC Standards Plugin                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │    Skills    │  │    Agents    │  │   Commands   │          │
│  │  (Guidance)  │  │  (Analysis)  │  │  (Actions)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         │                 │                 │                   │
│         └─────────────────┼─────────────────┘                   │
│                           │                                      │
│              ┌────────────▼────────────┐                        │
│              │  PROJECT_REQUIREMENTS   │                        │
│              │   (Canonical Source)    │                        │
│              └─────────────────────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Skills (`skills/`)

Skills provide topic-specific guidance that Claude Code surfaces contextually.

```
skills/
├── build/SKILL.md      # Build system standards
├── quality/SKILL.md    # Code quality (format, lint, errors)
├── testing/SKILL.md    # Test organization and coverage
├── ci/SKILL.md         # CI/CD pipeline configuration
├── security/SKILL.md   # Security scanning and supply chain
├── docs/SKILL.md       # Documentation requirements
├── vcs/SKILL.md        # Version control practices
├── release/SKILL.md    # Versioning and releases
├── observability/SKILL.md  # Logging, metrics, tracing
├── ai/SKILL.md         # AI context configuration
└── setup/SKILL.md      # Project initialization
```

**Skill Structure:**
```yaml
---
name: Skill Name
description: When to trigger this skill...
version: 1.0.0
---
# Skill Content (Markdown)
```

**Design Principles:**
- Technology-agnostic core content
- RFC 2119 terminology (MUST/SHOULD/MAY)
- Language-specific examples at end
- Self-contained (no external dependencies)

### 2. Agents (`agents/`)

Agents perform deep, autonomous analysis tasks.

```
agents/
├── compliance-auditor.md   # Full SDLC compliance audit
├── security-reviewer.md    # Security-focused analysis
├── quality-enforcer.md     # Code quality assessment
└── ci-architect.md         # CI/CD pipeline design
```

**Agent Structure:**
```yaml
---
description: When to use this agent...
whenToUse: Trigger conditions
color: blue
---
# System Prompt (Agent Instructions)
```

**Agent Capabilities:**
- Autonomous multi-step workflows
- Access to file system tools (Glob, Grep, Read)
- Structured output generation
- Parallel file analysis

### 3. Commands (`commands/`)

Commands provide explicit user-invokable actions.

```
commands/
├── check.md    # /sdlc:check - Run compliance assessment
└── init.md     # /sdlc:init - Initialize SDLC structure
```

**Command Naming:**
- All commands MUST be namespaced: `/sdlc:<command>`
- Clear, action-oriented names

### 4. Canonical Source (`docs/PROJECT_REQUIREMENTS.md`)

The single source of truth for all SDLC standards. Skills derive their content from this document.

**Sections:**
1. Build System Requirements
2. Code Quality Requirements
3. Testing Requirements
4. CI/CD Requirements
5. Security Requirements
6. Documentation Requirements
7. Version Control Requirements
8. Release Requirements
9. Performance/Observability Requirements
10. AI Context Requirements

## Data Flow

### Skill Activation Flow

```
User Query
    │
    ▼
┌─────────────────┐
│ Claude Code     │
│ (Skill Matcher) │
└────────┬────────┘
         │ Matches description/when_to_use
         ▼
┌─────────────────┐
│ SKILL.md        │
│ (Loaded)        │
└────────┬────────┘
         │ Content injected into context
         ▼
┌─────────────────┐
│ Response with   │
│ SDLC Guidance   │
└─────────────────┘
```

### Agent Execution Flow

```
User Request (e.g., "audit this project")
    │
    ▼
┌─────────────────┐
│ Agent Selected  │
│ (compliance-    │
│  auditor.md)    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ Autonomous Execution        │
│ - Glob: Find files          │
│ - Read: Analyze content     │
│ - Grep: Search patterns     │
│ - Bash: Run commands        │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────┐
│ Structured      │
│ Report Output   │
└─────────────────┘
```

### Command Execution Flow

```
User: /sdlc:check
    │
    ▼
┌─────────────────┐
│ Command Loaded  │
│ (check.md)      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ Command Instructions        │
│ Executed Step-by-Step       │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────┐
│ Compliance      │
│ Report          │
└─────────────────┘
```

## Design Decisions

See [ADRs](adrs/) for detailed architectural decisions.

### Key Decisions

1. **Markdown-based content**: Maximum portability, human-readable
2. **Technology-agnostic core**: Apply to any language/framework
3. **RFC 2119 compliance**: Unambiguous requirement levels
4. **Single source of truth**: PROJECT_REQUIREMENTS.md as canonical
5. **Modular skills**: Enable contextual, focused guidance
6. **Autonomous agents**: Deep analysis without constant user input

## Extension Points

### Adding a New Skill

1. Create `skills/<topic>/SKILL.md`
2. Add YAML frontmatter with `name`, `description`
3. Write content following existing patterns
4. Update PROJECT_REQUIREMENTS.md if introducing new standards

### Adding a New Agent

1. Create `agents/<name>.md`
2. Define clear system prompt in YAML frontmatter
3. Specify tools the agent can use
4. Define expected output format

### Adding a New Command

1. Create `commands/<name>.md`
2. Use namespaced name: `/sdlc:<name>`
3. Document expected inputs and outputs
4. Provide step-by-step execution instructions

## Technology Stack

| Component | Technology |
|-----------|------------|
| Content format | Markdown with YAML frontmatter |
| Configuration | JSON (plugin.json) |
| Build/Test | Makefile, Bash, Node.js tools |
| CI/CD | GitHub Actions |
| Linting | markdownlint-cli2 |
| Formatting | Prettier |

## Directory Structure

```
sdlc-quality/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── .github/
│   ├── workflows/
│   │   └── ci.yml           # CI pipeline
│   ├── ISSUE_TEMPLATE/      # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml       # Dependency updates
├── agents/                   # Autonomous agents
├── commands/                 # User commands
├── docs/
│   ├── adrs/                # Architecture decisions
│   ├── ARCHITECTURE.md      # This file
│   ├── USAGE.md             # Usage guide
│   └── PROJECT_REQUIREMENTS.md  # Canonical standards
├── scripts/
│   └── test.sh              # Test script
├── skills/                   # Topic skills
├── .claude/
│   └── documentation-review.local.md  # Doc config
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── package.json
├── README.md
└── SECURITY.md
```

## Performance Considerations

- Skills are loaded on-demand based on query matching
- Agents can run in parallel for different domains
- File operations use Glob for efficient pattern matching
- Large projects benefit from targeted agent scopes

## Security Considerations

- No executable code in plugin (markdown only)
- No secrets stored in content
- CI uses minimal permissions
- Dependency updates automated via Dependabot
