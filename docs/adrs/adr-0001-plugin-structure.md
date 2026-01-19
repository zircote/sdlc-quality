# ADR-0001: Plugin Structure

## Status

Accepted

## Date

2026-01-19

## Context

We need to define a consistent structure for the SDLC Standards Plugin that:

- Works with Claude Code's plugin system
- Supports skills, agents, and commands
- Remains technology-agnostic
- Is easy to maintain and extend

## Decision

We adopt the following plugin structure:

```
sdlc-quality/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/                  # Specialized agents
│   └── *.md
├── commands/                # Slash commands
│   └── *.md
├── docs/                    # Documentation
│   ├── adrs/                # Architecture decisions
│   └── PROJECT_REQUIREMENTS.md  # Canonical standards
├── skills/                  # Topic-specific guidance
│   └── <topic>/
│       └── SKILL.md
├── scripts/                 # Automation scripts
├── .github/                 # GitHub configuration
│   ├── workflows/
│   └── ISSUE_TEMPLATE/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── README.md
└── SECURITY.md
```

### Key Decisions

1. **Skills in subdirectories**: Each skill lives in `skills/<topic>/SKILL.md` for clear organization
2. **Flat agents/commands**: Agents and commands are flat files in their directories
3. **Canonical source**: `docs/PROJECT_REQUIREMENTS.md` is the authoritative standards document
4. **RFC 2119 compliance**: All standards use MUST/SHOULD/MAY terminology
5. **Technology-agnostic core**: Core standards don't assume specific languages

## Consequences

### Positive

- Clear separation of concerns
- Easy to add new skills without restructuring
- Single source of truth for standards
- Supports parallel agent execution
- Works seamlessly with Claude Code plugin discovery

### Negative

- Skill content duplicated somewhat between PROJECT_REQUIREMENTS.md and individual skills
- Requires maintaining consistency across multiple files

## Alternatives Considered

### Single File Plugin

All content in one large file.

Trade-offs: Simpler structure but harder to navigate and maintain.

### JSON-Based Skills

Skills defined in JSON/YAML rather than markdown.

Trade-offs: More structured but less readable and harder to edit.

## Related

- Claude Code Plugin Documentation
- RFC 2119 (Key words for use in RFCs)
