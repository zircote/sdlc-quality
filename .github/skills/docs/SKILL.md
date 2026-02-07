---
name: Documentation Standards
description: This skill should be used when the user asks about "documentation", "README", "CHANGELOG", "CONTRIBUTING", "ADR", "architecture decision record", "changelog format", "keep a changelog", "doc comments", "API documentation", or needs guidance on project documentation requirements.
version: 1.0.0
---

# Documentation Standards

Guidance for implementing documentation requirements including project docs, changelogs, and Architecture Decision Records.

## Tooling

> **Available Tools**: If using Claude Code, the `documentation-review` plugin provides comprehensive documentation tools (`/doc-review`, `/doc-create`, `/doc-update`, `/changelog`). For ADRs, use the `adr` plugin (`/adr:new`, `/adr:list`, `/adr:search`).

## Required Documentation

### Mandatory Files (MUST)

| Document          | Purpose                                     |
| ----------------- | ------------------------------------------- |
| `README.md`       | Project overview, quick start, installation |
| `CONTRIBUTING.md` | Contributor guidelines, setup instructions  |
| `CHANGELOG.md`    | Version history and change documentation    |
| `LICENSE`         | Software license terms                      |
| `SECURITY.md`     | Security policy and vulnerability reporting |

### Recommended Files (SHOULD)

| Document               | Purpose                      |
| ---------------------- | ---------------------------- |
| `CODE_OF_CONDUCT.md`   | Community standards          |
| `docs/architecture.md` | System design and decisions  |
| API documentation      | Generated from code comments |

## README Requirements

### Required Sections (MUST)

README MUST include:

- Project name and brief description
- Badge indicators (CI status, version, coverage, license)
- Installation instructions (multiple methods if applicable)
- Quick start/usage examples
- Links to detailed documentation
- License information
- Contribution link

### Recommended Sections (SHOULD)

README SHOULD include:

- Feature list with descriptions
- Architecture overview (diagram recommended)
- Performance characteristics
- Configuration options
- Troubleshooting section

### Badge Examples

```markdown
[![CI](https://github.com/org/repo/actions/workflows/ci.yml/badge.svg)](...)
[![crates.io](https://img.shields.io/crates/v/package.svg)](...)
[![Coverage](https://codecov.io/gh/org/repo/branch/main/graph/badge.svg)](...)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](...)
```

## Changelog Requirements

### Format (MUST)

Changelogs MUST follow the [Keep a Changelog](https://keepachangelog.com/) format.

### Version Entry Structure (MUST)

Each version entry MUST be organized into these categories:

| Category   | Purpose                           |
| ---------- | --------------------------------- |
| Added      | New features                      |
| Changed    | Changes to existing functionality |
| Deprecated | Features to be removed            |
| Removed    | Removed features                  |
| Fixed      | Bug fixes                         |
| Security   | Security-related changes          |

### Required Elements (MUST)

Changelogs MUST include:

- Version number
- Release date
- Comparison links to previous versions

### Unreleased Section (MUST)

The `[Unreleased]` section MUST be maintained for ongoing changes.

### Changelog Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- New feature description

## [1.0.0] - 2024-01-15

### Added

- Initial release features

### Fixed

- Bug fix description

[Unreleased]: https://github.com/org/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Contributing Guidelines

### Required Sections (MUST)

CONTRIBUTING.md MUST include:

- Prerequisites and tool requirements
- Development environment setup steps
- Build and test instructions
- Code style guidelines
- Pull request process
- Commit message format

### Recommended Sections (SHOULD)

CONTRIBUTING.md SHOULD include:

- Project structure overview
- Troubleshooting section
- Contact/support information

## Architecture Decision Records (ADRs)

### When to Create (MUST)

Significant technical decisions MUST be documented as ADRs.

### Location (MUST)

ADRs MUST be stored in version control at `docs/adrs/` (or `docs/decisions/`).

### Required Sections (MUST)

Each ADR MUST include:

| Section      | Content                                    |
| ------------ | ------------------------------------------ |
| Title        | Descriptive title with ADR number          |
| Status       | Proposed, Accepted, Deprecated, Superseded |
| Context      | Background and problem statement           |
| Decision     | The chosen approach                        |
| Consequences | Positive and negative outcomes             |

### Recommended Sections (SHOULD)

ADRs SHOULD also include:

- Decision drivers (weighted criteria)
- Considered alternatives
- Implementation notes
- Related ADRs

### ADR Format (MUST)

ADRs MUST use a structured format such as:

- **Structured MADR** (recommended)
- MADR (Markdown Architectural Decision Records)
- Nygard format
- Y-Statement format

### ADR Naming (MUST)

ADR files MUST use consistent naming: `adr_NNNN.md` or `NNNN-title.md`.

### ADR Index (MUST)

Projects MUST maintain an ADR index/README listing all decisions.

## Implementation Checklist

- [ ] Create README.md with required sections
- [ ] Create CONTRIBUTING.md
- [ ] Create CHANGELOG.md with proper format
- [ ] Add LICENSE file
- [ ] Create SECURITY.md
- [ ] Set up docs/adrs/ directory
- [ ] Create ADR template
- [ ] Create ADR index/README

## Compliance Verification

```bash
# Verify required docs exist
ls README.md CONTRIBUTING.md CHANGELOG.md LICENSE SECURITY.md

# Check README has badges
grep -E "^\[!\[" README.md

# Verify changelog format
grep -E "^\## \[" CHANGELOG.md

# Check ADR directory
ls docs/adrs/ || ls docs/decisions/
```

## Additional Resources

### Reference Files

- **`references/readme-template.md`** - Complete README template
- **`references/adr-template.md`** - MADR ADR template

### Examples

- **`examples/CHANGELOG.md`** - Example changelog
- **`examples/CONTRIBUTING.md`** - Example contributing guide
- **`examples/adr-0001.md`** - Example ADR
