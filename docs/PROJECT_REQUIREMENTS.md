---
title: Project Requirements Document
version: 1.0.0
last_updated: 2026-01-19
description: Software Development Lifecycle Standards and Expectations
usage:
  - Project setup guidance for human developers
  - AI coding assistant instructions (CLAUDE.md, copilot-instructions.md, AGENTS.md)
  - Compliance checklist for code reviews
  - Onboarding reference for new contributors
audience:
  - Software developers
  - AI coding assistants (Claude, Copilot, Codex, Gemini, etc.)
  - Project maintainers
  - Code reviewers
rfc2119: true
technology_agnostic: true
---
# Project Requirements Document
**Version:** 1.0.0
**Last Updated:** 2026-01-19
**Scope:** Software Development Lifecycle Standards and Expectations
**Usage:** AI Assistant Instructions (GitHub Copilot, OpenAI Codex, Claude Code)

## AI ASSISTANT DIRECTIVES

> **CRITICAL INSTRUCTION FOR AI ASSISTANTS (GitHub Copilot, OpenAI Codex, Claude Code, and similar tools):**
>
> This document serves as authoritative project instructions. When implementing these requirements:
>
> 1. **VERSION DISCOVERY REQUIREMENT**: You **MUST** discover all version numbers, release versions, dependency versions, tool versions, and API versions from **ONLINE SOURCES** (official documentation, package registries, GitHub releases, crates.io, npm, PyPI, etc.). **DO NOT** rely on training data or cached knowledge for version information. Always verify current versions at implementation time using web search, documentation fetches, or registry queries.
>
> 2. **TECHNOLOGY INFERENCE**: Infer specific technologies, frameworks, and tooling from the project you are working in. This document is technology-agnostic by design.
>
> 3. **NO ASSUMPTIONS**: If a requirement is unclear or you cannot find information online, **ASK** the user rather than assuming or using potentially outdated knowledge.
>
> 4. **COMPLIANCE**: All code you generate **MUST** comply with the requirements in this document.
>
> 5. **VERIFICATION**: Before suggesting any version, dependency, or tool configuration, verify it is current by consulting official sources online.

---

## 1. Purpose and Scope

This document defines prescriptive requirements for software project development. It establishes standards across the entire software development lifecycle (SDLC) that ensure quality, security, maintainability, and consistency.

This document is **project-agnostic**. Technical implementations (languages, frameworks, tools) shall be inferred based on the target project's technology stack.

This document is designed to be used as:
- Project setup guidance for human developers
- Instruction file for AI coding assistants (`.github/copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`, etc.)
- Compliance checklist for code reviews
- Onboarding reference for new contributors

### 1.1 Requirement Language

This document uses RFC 2119 terminology:

| Term | Meaning |
|------|---------|
| **MUST** / **SHALL** | Absolute requirement; non-negotiable |
| **MUST NOT** / **SHALL NOT** | Absolute prohibition |
| **SHOULD** / **RECOMMENDED** | Strong recommendation; deviation requires justification |
| **SHOULD NOT** / **NOT RECOMMENDED** | Strong discouragement; use requires justification |
| **MAY** / **OPTIONAL** | Truly optional; use at discretion |

---

## 2. Build System Requirements

### 2.1 Build Automation

1. Projects **MUST** provide a unified build system entry point (e.g., Makefile, Taskfile, Justfile, or equivalent).

2. The build system **MUST** expose the following standardized targets:

   | Target | Purpose | Required |
   |--------|---------|----------|
   | `build` | Compile debug/development build | MUST |
   | `release` | Compile optimized production build | MUST |
   | `test` | Run all tests | MUST |
   | `lint` | Run linting with warnings allowed | MUST |
   | `lint-strict` | Run linting with warnings as errors | MUST |
   | `format` | Apply code formatting | MUST |
   | `format-check` | Verify code formatting without changes | MUST |
   | `clean` | Remove build artifacts | MUST |
   | `install` | Install to system path | SHOULD |
   | `dev` | Full development workflow (check + install) | SHOULD |
   | `quick` | Fast build + install (skip tests) | SHOULD |
   | `doc` | Generate documentation | SHOULD |
   | `bench` | Run performance benchmarks | SHOULD |
   | `ci` | Run all CI gates locally | MUST |
   | `help` | Display available targets | MUST |

3. The `ci` target **MUST** execute all checks in the same order as the CI pipeline.

4. Build systems **MUST** use locked/reproducible dependency resolution.

5. The `help` target **MUST** document all available targets and their purposes.

### 2.2 Build Profiles

1. Projects **MUST** define at minimum two build profiles:
   - **Development**: Fast compilation, debugging enabled
   - **Release**: Optimized for performance and size

2. Release builds **SHOULD** enable:
   - Maximum optimization level
   - Link-time optimization (LTO)
   - Binary stripping (where appropriate)
   - Single codegen unit (where beneficial)

### 2.3 Dependency Management

1. All dependencies **MUST** be declared with explicit version constraints.

2. Lockfiles **MUST** be committed to version control.

3. Wildcard version constraints (e.g., `*`) **MUST NOT** be used.

4. Dependencies **MUST** be sourced only from official package registries.

5. Git-based dependencies **MUST** pin to specific commits or tags, never branches.

6. Projects **MUST** define a Minimum Supported Version (MSV) for the primary language/runtime.

---

## 3. Code Quality Requirements

### 3.1 Formatting

1. All source code **MUST** pass automated formatting checks before merge.

2. Projects **MUST** define and commit formatting configuration files.

3. The following formatting standards **MUST** be enforced:

   | Standard | Requirement |
   |----------|-------------|
   | Line length | MUST be 100 characters maximum |
   | Indentation | MUST be consistent (spaces or tabs, not mixed) |
   | Line endings | MUST be Unix-style (LF) |
   | Trailing whitespace | MUST be removed |
   | Final newline | MUST be present |

4. Import/include statements **MUST** be automatically sorted and grouped.

### 3.2 Linting

1. Projects **MUST** use static analysis (linting) tools appropriate to the language.

2. CI pipelines **MUST** run linting with warnings treated as errors.

3. Linting **MUST** include the following categories:

   | Category | Enforcement |
   |----------|-------------|
   | Correctness | MUST be enabled |
   | Performance | MUST be enabled |
   | Style | SHOULD be enabled |
   | Complexity | SHOULD be enabled |
   | Documentation | SHOULD be enabled |
   | Pedantic | SHOULD be enabled |
   | Nursery (experimental) | MAY be enabled |

4. Lint rule exceptions **MUST** be documented with justification.

### 3.3 Error Handling

1. Library code **MUST NOT** panic, abort, or terminate the process unexpectedly.

2. All error conditions **MUST** be handled via structured error types or result types.

3. The following patterns **MUST NOT** appear in library code:
   - Unchecked unwrapping of optional/nullable values
   - Unchecked type assertions/casts
   - Unhandled exceptions
   - Process exit calls

4. Test code and CLI entry points **MAY** use simplified error handling where appropriate.

### 3.4 Unsafe Code

1. Unsafe code blocks **MUST** be minimized.

2. All unsafe code **MUST** be:
   - Documented with safety invariants
   - Encapsulated in safe abstractions
   - Reviewed by at least one additional maintainer

3. Projects **MUST** enable compiler/linter warnings for unsafe code usage.

### 3.5 Documentation Comments

1. All public APIs **MUST** have documentation comments.

2. Documentation **MUST** include:
   - Brief description of purpose
   - Parameter descriptions
   - Return value descriptions
   - Error conditions (what errors can occur and when)

3. Documentation **SHOULD** include:
   - Usage examples (preferably as tested code)
   - References to related APIs
   - Notes on thread safety or concurrency

4. Documentation **MUST** be validated as part of CI (no broken links, valid examples).

---

## 4. Testing Requirements

### 4.1 Test Organization

1. Projects **MUST** maintain the following test categories:

   | Category | Location | Purpose |
   |----------|----------|---------|
   | Unit tests | Alongside source code | Test individual functions/methods |
   | Integration tests | Dedicated test directory | Test component interactions |
   | Documentation tests | Within doc comments | Verify examples work |
   | End-to-end tests | Dedicated e2e directory | Test full system behavior |

2. Test files **MUST** be clearly identifiable by naming convention.

### 4.2 Test Coverage

1. All new functionality **MUST** include corresponding tests.

2. Bug fixes **MUST** include regression tests that fail before the fix.

3. Test coverage **MUST** be measured and tracked over time.

4. Projects **SHOULD** target a minimum of 80% code coverage.

5. Critical paths (security, data integrity) **MUST** have 95%+ coverage.

6. Coverage reports **MUST** be uploaded to a coverage tracking service.

### 4.3 Test Execution

1. All tests **MUST** pass before code can be merged.

2. Tests **MUST** be deterministic (no flaky tests).

3. Tests **MUST** be isolated (no shared state between tests unless explicitly required).

4. Tests **SHOULD** complete within reasonable time limits:
   - Unit tests: < 1 second each
   - Integration tests: < 30 seconds each
   - Full test suite: < 10 minutes

5. Tests **MUST** run on all supported platforms as part of CI.

### 4.4 Test Best Practices

1. Tests **MUST** follow the Arrange-Act-Assert pattern.

2. Test names **MUST** clearly describe what is being tested.

3. Tests **MUST** cover:
   - Happy path (expected inputs)
   - Error cases (invalid inputs)
   - Edge cases (boundary conditions)

---

## 5. Continuous Integration Requirements

### 5.1 CI Pipeline Structure

1. CI **MUST** run on:
   - All pull requests to protected branches
   - All pushes to protected branches (develop, main)
   - Scheduled intervals (daily/weekly for security scans)

2. CI pipelines **MUST** include the following jobs in order:

   | Job | Purpose | Required |
   |-----|---------|----------|
   | Format check | Verify code formatting | MUST |
   | Lint | Static analysis with errors | MUST |
   | Test | Run all tests | MUST |
   | Documentation | Verify docs build | MUST |
   | Security audit | Check for vulnerabilities | MUST |
   | MSV check | Verify minimum version support | MUST |
   | Coverage | Measure test coverage | SHOULD |
   | Benchmarks | Performance regression check | SHOULD |

3. All CI jobs **MUST** pass before a PR can be merged.

### 5.2 CI Configuration

1. CI workflows **MUST** use pinned action versions (commit SHAs preferred over tags).

2. CI **MUST** implement concurrency controls to cancel superseded runs.

3. CI **MUST** cache dependencies and build artifacts to reduce execution time.

4. CI **MUST** test on all supported operating systems and architectures.

### 5.3 CI Environment

1. CI environment variables **MUST** be explicitly configured (no reliance on runner defaults).

2. Sensitive values **MUST** be stored as secrets, never in workflow files.

3. CI **MUST** use minimal permissions (principle of least privilege).

---

## 6. Security Requirements

### 6.1 Dependency Security

1. Projects **MUST** use automated dependency vulnerability scanning.

2. Scanning **MUST** occur:
   - On every pull request
   - On every push to protected branches
   - On a scheduled basis (daily minimum)

3. Critical and high severity vulnerabilities **MUST** block PR merges.

4. Known vulnerabilities that cannot be fixed **MUST** be:
   - Documented with justification
   - Listed in an ignore/allowlist with expiration dates
   - Reviewed quarterly

### 6.2 Supply Chain Security

1. Projects **MUST** implement supply chain security controls.

2. The following checks **MUST** be performed:

   | Check | Purpose |
   |-------|---------|
   | License compliance | Verify all dependencies use allowed licenses |
   | Source verification | Ensure dependencies come from trusted sources |
   | Advisory database | Check against known vulnerability databases |
   | Package bans | Block known problematic packages |
   | Duplicate detection | Identify multiple versions of same package |

3. Allowed licenses **MUST** be explicitly defined.

4. The following licenses **SHOULD** be allowed:
   - MIT
   - Apache-2.0
   - BSD-2-Clause
   - BSD-3-Clause
   - ISC
   - MPL-2.0
   - CC0-1.0
   - Unlicense
   - Zlib

5. Copyleft licenses (GPL-3.0, AGPL-3.0) **MUST** be explicitly reviewed and approved.

### 6.3 Code Security

1. All code **MUST** be scanned for:
   - Hardcoded secrets
   - Security misconfigurations
   - Common vulnerability patterns (OWASP Top 10)

2. Security scan results **MUST** be uploaded to a centralized security dashboard.

3. Projects **SHOULD** implement semantic code analysis (e.g., CodeQL, Semgrep).

### 6.4 Audit Schedule

1. Full dependency audits **MUST** be conducted quarterly.

2. Pre-release dependencies **MUST** be monitored and documented.

3. Audit findings **MUST** be tracked and remediated within defined SLAs:
   - Critical: 7 days
   - High: 30 days
   - Medium: 90 days
   - Low: Next major release

---

## 7. Documentation Requirements

### 7.1 Required Documentation

1. Projects **MUST** maintain the following documentation:

   | Document | Purpose |
   |----------|---------|
   | README.md | Project overview, quick start, installation |
   | CONTRIBUTING.md | Contributor guidelines, setup instructions |
   | CHANGELOG.md | Version history and change documentation |
   | LICENSE | Software license terms |
   | SECURITY.md | Security policy and vulnerability reporting |

2. Projects **SHOULD** also maintain:

   | Document | Purpose |
   |----------|---------|
   | CODE_OF_CONDUCT.md | Community standards |
   | Architecture documentation | System design and decisions |
   | API documentation | Generated from code comments |

### 7.2 README Requirements

1. README **MUST** include:
   - Project name and brief description
   - Badge indicators (CI status, version, coverage, license)
   - Installation instructions (multiple methods if applicable)
   - Quick start/usage examples
   - Links to detailed documentation
   - License information
   - Contribution link

2. README **SHOULD** include:
   - Feature list with descriptions
   - Architecture overview (diagram recommended)
   - Performance characteristics
   - Configuration options
   - Troubleshooting section

### 7.3 Changelog Requirements

1. Changelogs **MUST** follow the [Keep a Changelog](https://keepachangelog.com/) format.

2. Each version entry **MUST** be organized into these categories:
   - Added (new features)
   - Changed (changes to existing functionality)
   - Deprecated (features to be removed)
   - Removed (removed features)
   - Fixed (bug fixes)
   - Security (security-related changes)

3. Changelogs **MUST** include:
   - Version number
   - Release date
   - Comparison links to previous versions

4. The `[Unreleased]` section **MUST** be maintained for ongoing changes.

### 7.4 Contributing Guidelines

1. CONTRIBUTING.md **MUST** include:
   - Prerequisites and tool requirements
   - Development environment setup steps
   - Build and test instructions
   - Code style guidelines
   - Pull request process
   - Commit message format

2. CONTRIBUTING.md **SHOULD** include:
   - Project structure overview
   - Troubleshooting section
   - Contact/support information

---

## 8. Architecture Decision Records (ADRs)

### 8.1 ADR Requirements

1. Significant technical decisions **MUST** be documented as ADRs.

2. ADRs **MUST** be stored in version control at `docs/adrs/` (or `docs/decisions/`).

3. Each ADR **MUST** include:

   | Section | Content |
   |---------|---------|
   | Title | Descriptive title with ADR number |
   | Status | Proposed, Accepted, Deprecated, Superseded |
   | Context | Background and problem statement |
   | Decision | The chosen approach |
   | Consequences | Positive and negative outcomes |

4. ADRs **SHOULD** also include:
   - Decision drivers (weighted criteria)
   - Considered alternatives
   - Implementation notes
   - Related ADRs

### 8.2 ADR Format

1. ADRs **MUST** use a structured format such as:
   - **Structured MADR (Markdown Architectural Decision Records)**
   - MADR (Markdown Architectural Decision Records)
   - Nygard format
   - Y-Statement format

2. ADR files **MUST** use consistent naming: `adr_NNNN.md` or `NNNN-title.md`.

3. ADR status transitions **MUST** be documented:
   - Proposed -> Accepted
   - Accepted -> Deprecated (with reason)
   - Accepted -> Superseded (with link to replacement)

### 8.3 ADR Compliance

1. Projects **MUST** maintain an ADR index/README listing all decisions.

2. ADR compliance audits **SHOULD** be conducted periodically.

3. Non-compliant implementations **MUST** be documented with remediation plans.

---

## 9. Version Control Requirements

### 9.1 Branching Strategy

1. Projects **MUST** define and document a branching strategy (e.g., GitFlow, trunk-based).

2. The following branches **MUST** be protected:
   - `main` (or `master`): Production-ready code
   - `develop`: Integration branch for features

3. Protected branches **MUST** require:
   - Pull request reviews (minimum 1 approval)
   - Passing CI checks
   - Up-to-date with base branch
   - Linear history (rebase or squash)

### 9.2 Commit Standards

1. Commits **MUST** follow [Conventional Commits](https://www.conventionalcommits.org/) format:

   ```
   <type>(<scope>): <description>

   [optional body]

   [optional footer(s)]
   ```

2. Allowed commit types:

   | Type | Purpose |
   |------|---------|
   | `feat` | New feature |
   | `fix` | Bug fix |
   | `docs` | Documentation changes |
   | `style` | Formatting, no code change |
   | `refactor` | Code restructuring |
   | `perf` | Performance improvement |
   | `test` | Test additions/changes |
   | `chore` | Maintenance tasks |
   | `ci` | CI configuration changes |
   | `build` | Build system changes |

3. Commit messages **MUST**:
   - Use imperative mood ("Add feature" not "Added feature")
   - Be concise (< 72 characters for subject line)
   - Reference issues where applicable

4. Commits **MUST NOT** include AI attribution lines (e.g., "Co-Authored-By: AI").

### 9.3 Pull Request Standards

1. Pull requests **MUST** use a standardized template.

2. PR templates **MUST** include:
   - Summary of changes
   - Type of change (bug fix, feature, etc.)
   - Testing performed
   - Checklist of requirements

3. PRs **MUST** be:
   - Focused on a single concern
   - Rebased on the target branch
   - Squash-merged (maintaining clean history)

---

## 10. Issue and PR Templates

### 10.1 Issue Templates

1. Projects **MUST** provide structured issue templates for:

   | Template | Purpose |
   |----------|---------|
   | Bug Report | Report defects and unexpected behavior |
   | Feature Request | Propose new functionality |

2. Bug report templates **MUST** require:
   - Bug description
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Environment information (OS, version, etc.)

3. Feature request templates **MUST** require:
   - Problem statement
   - Proposed solution
   - Alternatives considered

4. Issue templates **SHOULD** include:
   - Minimal reproducible examples
   - Priority/severity indicators
   - Contribution willingness checkbox

### 10.2 PR Templates

1. PR templates **MUST** include checklists for:

   | Category | Items |
   |----------|-------|
   | Code Quality | Formatting, linting, no unsafe patterns |
   | Testing | Tests added, tests pass, doc tests |
   | Documentation | Docs updated, doc comments, changelog |
   | Supply Chain | Security audit passed, dependencies justified |
   | Commit Hygiene | Conventional commits, rebased |

2. PR templates **SHOULD** include sections for:
   - API changes (before/after)
   - Performance impact
   - Breaking changes notice

---

## 11. Release and Versioning Requirements

### 11.1 Versioning

1. Projects **MUST** follow [Semantic Versioning](https://semver.org/) (SemVer):

   ```
   MAJOR.MINOR.PATCH
   ```

   | Component | Increment When |
   |-----------|----------------|
   | MAJOR | Breaking API changes |
   | MINOR | New backward-compatible features |
   | PATCH | Backward-compatible bug fixes |

2. Pre-release versions **MUST** use suffixes: `-alpha.N`, `-beta.N`, `-rc.N`.

3. Version **MUST** be defined in a single source of truth (package manifest).

### 11.2 Release Process

1. Releases **MUST** be automated via CI/CD.

2. Release workflows **MUST**:
   - Build artifacts for all supported platforms
   - Generate checksums (SHA256) for all artifacts
   - Create GitHub releases with release notes
   - Publish to package registries (where applicable)

3. Release notes **MUST** include:
   - Version number
   - Installation instructions (multiple methods)
   - Download links with platform information
   - Changelog excerpts
   - Checksum verification instructions

### 11.3 Distribution

1. Projects **SHOULD** support multiple distribution channels:

   | Channel | Use Case |
   |---------|----------|
   | Package registry | Language ecosystem users |
   | Homebrew/apt/etc. | System package managers |
   | Container images | Containerized deployments |
   | Direct download | Manual installation |

2. Each distribution artifact **MUST** include checksum verification.

3. Container images **SHOULD**:
   - Use minimal base images
   - Support multiple architectures (amd64, arm64)
   - Include SBOM (Software Bill of Materials)
   - Be scanned for vulnerabilities

---

## 12. Dependency Update Requirements

### 12.1 Automated Updates

1. Projects **MUST** use automated dependency update tooling (e.g., Dependabot, Renovate).

2. Update configuration **MUST** specify:
   - Update schedule (weekly recommended)
   - PR limits (to avoid overwhelming)
   - Commit message format (conventional commits)
   - Reviewers/assignees

3. Dependencies **SHOULD** be grouped by ecosystem/category for batch updates.

### 12.2 Update Review

1. Dependency updates **MUST** pass all CI checks before merge.

2. Major version updates **MUST** be reviewed manually.

3. Security updates **MUST** be prioritized and merged within SLA (see Section 6.4).

---

## 13. Performance Requirements

### 13.1 Performance Targets

1. Projects **MUST** define measurable performance targets.

2. Performance targets **MUST** be documented in project documentation.

3. Example performance target categories:

   | Category | Example Metric |
   |----------|----------------|
   | Latency | Operation completes in < X ms |
   | Throughput | Handle > X operations/second |
   | Resource usage | Memory < X MB, CPU < X% |
   | Startup time | Cold start < X ms |
   | Binary size | Artifact < X MB |

### 13.2 Performance Benchmarks

1. Performance-critical code **MUST** have automated benchmarks.

2. Benchmarks **MUST** be run as part of CI (at minimum in validation mode).

3. Benchmark results **SHOULD** be tracked over time for regression detection.

4. Performance regressions > 10% **MUST** block PR merges or generate warnings.

### 13.3 Performance Documentation

1. Performance characteristics **MUST** be documented in README or dedicated file.

2. Documentation **MUST** include:
   - Target vs. actual performance
   - Benchmark methodology
   - Hardware/environment specifications
   - Tuning recommendations

---

## 14. Observability Requirements

### 14.1 Logging

1. Applications **MUST** implement structured logging.

2. Log levels **MUST** be configurable at runtime.

3. Logs **MUST NOT** contain sensitive information (secrets, PII).

4. Standard log levels **MUST** be used: TRACE, DEBUG, INFO, WARN, ERROR.

### 14.2 Metrics

1. Applications **SHOULD** expose metrics for monitoring.

2. Metrics **MUST** follow standard naming conventions (e.g., Prometheus conventions).

3. Key metrics to track:
   - Request/operation latency (histograms)
   - Error rates
   - Resource utilization

### 14.3 Tracing

1. Distributed applications **SHOULD** implement distributed tracing.

2. Tracing **MUST** use OpenTelemetry or equivalent standard.

---

## 15. AI/LLM Code Generation Guidelines

### 15.1 Version Discovery (CRITICAL)

1. AI assistants **MUST** discover all version information from online sources.

2. AI assistants **MUST NOT** rely on training data for:
   - Dependency versions
   - Tool versions
   - API versions
   - Framework versions
   - Runtime versions

3. AI assistants **MUST** use the following sources for version discovery:
   - Official package registries (crates.io, npm, PyPI, etc.)
   - GitHub releases/tags
   - Official documentation websites
   - Language/framework official sites

4. When version information cannot be verified online, AI assistants **MUST** ask the user.

### 15.2 Code Generation Standards

1. AI-generated code **MUST** comply with all project standards in this document.

2. AI tools **MUST** be configured with project-specific guidelines.

3. AI-generated code **MUST** be reviewed by humans before merge.

4. AI assistants **MUST** infer technology choices from the project context.

### 15.3 AI Tool Configuration

1. Projects **SHOULD** provide AI tool configuration files:
   - `.github/copilot-instructions.md` (GitHub Copilot)
   - `CLAUDE.md` (Claude Code)
   - `.cursorrules` (Cursor)

2. Configuration **MUST** specify:
   - Code style requirements
   - Patterns to use and avoid
   - Error handling requirements
   - Documentation requirements
   - No AI attribution policy

### 15.4 Prohibited AI Patterns

1. AI tools **MUST NOT** generate:
   - Code that panics or crashes
   - Hardcoded secrets or credentials
   - Unsafe code without justification and documentation
   - Code that bypasses security checks
   - Outdated dependencies based on training data

---

## 16. Repository Configuration

### 16.1 GitHub Configuration

1. Projects **MUST** configure the following in `.github/`:

   | File | Purpose |
   |------|---------|
   | `workflows/ci.yml` | Continuous integration pipeline |
   | `workflows/release.yml` | Automated releases |
   | `workflows/security.yml` | Security scanning |
   | `PULL_REQUEST_TEMPLATE.md` | PR template |
   | `ISSUE_TEMPLATE/` | Issue templates |
   | `dependabot.yml` | Dependency updates |

2. Projects **SHOULD** also configure:

   | File | Purpose |
   |------|---------|
   | `CODEOWNERS` | Automatic review assignment |
   | `FUNDING.yml` | Sponsorship links |
   | `SECURITY.md` | Security policy |
   | `copilot-instructions.md` | GitHub Copilot configuration |

### 16.2 Branch Protection

1. The `main` branch **MUST** require:
   - Pull request before merge
   - At least 1 approval
   - Status checks to pass
   - Up-to-date branches
   - No force pushes

2. The `develop` branch **SHOULD** have similar protections with potentially relaxed approval requirements.

---

## Appendix A: Checklist for New Projects

Use this checklist when setting up a new project:

### Repository Setup
- [ ] Initialize git repository
- [ ] Create `.gitignore` appropriate to technology
- [ ] Set up branch protection rules
- [ ] Configure default branch (main/develop)
- [ ] Add CODEOWNERS file

### Documentation
- [ ] Create README.md with required sections
- [ ] Create CONTRIBUTING.md
- [ ] Create CHANGELOG.md
- [ ] Add LICENSE file
- [ ] Create SECURITY.md
- [ ] Create docs/ directory structure
- [ ] Initialize ADR directory with template

### Build System
- [ ] Create build configuration (Makefile, etc.)
- [ ] Define all required targets (ci, build, test, lint, format, etc.)
- [ ] Configure build profiles (dev, release)
- [ ] Set up dependency management with lockfile
- [ ] Define MSV (Minimum Supported Version)
- [ ] Add `make help` target

### Code Quality
- [ ] Configure formatter with config file
- [ ] Configure linter with strict rules
- [ ] Define error handling patterns
- [ ] Document code style requirements

### CI/CD
- [ ] Create CI workflow with all required jobs
- [ ] Configure caching
- [ ] Set up multi-platform testing
- [ ] Configure security scanning
- [ ] Set up coverage reporting
- [ ] Create release workflow

### Security
- [ ] Set up dependency vulnerability scanning
- [ ] Configure supply chain security (license, advisories)
- [ ] Define allowed licenses
- [ ] Create security audit schedule

### Issue/PR Management
- [ ] Create bug report template
- [ ] Create feature request template
- [ ] Create PR template with checklists
- [ ] Configure labels

### Release
- [ ] Define versioning strategy
- [ ] Create release workflow
- [ ] Configure distribution channels
- [ ] Set up changelog automation

### AI Tool Configuration
- [ ] Create AI instruction files (CLAUDE.md, copilot-instructions.md)
- [ ] Document version discovery requirements
- [ ] Configure code generation standards

---

## Appendix B: Compliance Matrix

| Requirement Area | Critical | High | Medium | Low |
|------------------|----------|------|--------|-----|
| Build System | ci target, locked deps, MSV | All standard targets | Install, doc, bench | Help target |
| Code Quality | Format, lint, no panics | Documentation, pedantic lints | Unsafe restrictions | Style lints |
| Testing | Tests pass, deterministic | Coverage tracking (80%+) | Performance tests | E2E tests |
| CI/CD | All jobs pass, pinned actions | Multi-platform | Coverage upload | Benchmark tracking |
| Security | Vuln scanning, supply chain | CodeQL/Semgrep | Scheduled scans | Secret scanning |
| Documentation | README, CONTRIBUTING, CHANGELOG | ADRs, SECURITY.md | Architecture docs | API docs |
| Version Control | Protected branches, conventional commits | PR templates | Issue templates | CODEOWNERS |
| Release | SemVer, automated releases | Multi-channel distribution | SBOM | Homebrew formula |
| AI Configuration | Version discovery online | Project-specific config | No AI attribution | Tool configs |

---

## Appendix C: Reference Implementations

The standards in this document are derived from production-grade projects. When implementing these requirements, refer to:

1. **Build System**: Makefile with standardized targets and help
2. **Code Quality**: Language-specific linter configurations with pedantic rules
3. **CI/CD**: GitHub Actions workflows with pinned versions and caching
4. **Security**: cargo-deny/dependency-review configurations
5. **Documentation**: Keep a Changelog format, MADR for ADRs
6. **Templates**: Structured YAML-based issue templates
7. **AI Configuration**: CLAUDE.md with strict directives

---

*This document establishes baseline requirements. Projects may exceed these standards but must not fall below them without documented justification and approval.*

*When using this document as AI assistant instructions, the AI MUST verify all version information from online sources and MUST NOT rely on training data for technical specifications.*
