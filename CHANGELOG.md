# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/zircote/sdlc-quality/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/zircote/sdlc-quality/releases/tag/v1.0.0
