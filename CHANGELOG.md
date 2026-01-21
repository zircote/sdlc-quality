# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.1] - 2026-01-21

### Added

- **Tests**: Hook-driven functional test framework with commands `/run-tests`, `/add-test`, `/test-report`
- **Tests**: Smoke and regression test definitions for commands, agents, and skills

### Fixed

- **Commands**: Updated command names in frontmatter to match filenames
- **Commands**: Prefixed commands with `sdlc-` for local plugin visibility

## [1.2.0] - 2026-01-20

### Changed

- Renamed commands: `check` → `validate`, `init` → `setup`
- Commands now invoked as `/sdlc:setup` and `/sdlc:validate`

## [1.1.2] - 2026-01-20

### Changed

- **CI**: Bump github/codeql-action from 3 to 4
- **CI**: Bump actions/setup-node from 4 to 6
- **CI**: Bump actions/github-script from 7 to 8
- **CI**: Bump actions/checkout from 4 to 6

## [1.1.1] - 2026-01-20

### Changed

- Updated command frontmatter with `argument-hint` and `allowed-tools` fields
- Fixed Makefile format-check pattern (removed non-existent `**/*.yaml`)
- Updated documentation to reflect actual directory structure

### Fixed

- Commands now include proper frontmatter per Claude Code plugin spec

## [1.1.0] - 2025-01-19

### Added

- GitHub Actions composite action for SDLC compliance checking
- Reusable workflow for comprehensive audits
- Multiple trigger modes: PR, push, schedule, issue assignment, manual dispatch
- Report formats: Markdown, JSON, SARIF (GitHub Security tab integration)
- Automatic PR comments with compliance results
- Issue creation for compliance failures
- AI agent configuration files:
  - `.github/copilot-instructions.md` for GitHub Copilot
  - `AGENTS.md` for OpenAI Codex
  - `.github/workflows/copilot-setup-steps.yml` for Copilot coding agent
- GitHub Actions integration documentation (`docs/GITHUB_ACTIONS.md`)
- Domain-specific check modules for all 11 SDLC domains

### Changed

- Updated README with GitHub Actions quick start example
- Added AI Agent Interoperability section to README

## [1.0.0] - 2025-01-19

### Added

- Initial plugin structure with skills, agents, and commands
- Comprehensive SDLC standards in `docs/PROJECT_REQUIREMENTS.md`
- Skills for build, quality, testing, CI, security, docs, VCS, release, observability, AI, and setup
- Agents for compliance auditing, security review, quality enforcement, and CI architecture
- Commands: `/sdlc:check` and `/sdlc:init`
- GitHub Actions CI workflow
- Issue and PR templates
- Architecture Decision Records structure

[Unreleased]: https://github.com/zircote/sdlc-quality/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/zircote/sdlc-quality/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/zircote/sdlc-quality/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/zircote/sdlc-quality/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/zircote/sdlc-quality/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/zircote/sdlc-quality/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/zircote/sdlc-quality/releases/tag/v1.0.0
