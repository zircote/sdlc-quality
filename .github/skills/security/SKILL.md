---
name: security
description: This skill should be used when the user asks about "security", "vulnerability scanning", "dependency audit", "supply chain security", "license compliance", "security audit", "CVE", "OWASP", "secrets scanning", "cargo-deny", "npm audit", or needs guidance on security requirements and vulnerability management.
version: 1.0.0
---

# Security Standards

Guidance for implementing security requirements including dependency scanning, supply chain security, and vulnerability management.

## Tooling

> **Available Tools**: If using Claude Code, the `pr-review-toolkit:silent-failure-hunter` agent identifies security issues in error handling. Use security scanning tools native to your language ecosystem.

## Dependency Security

### Vulnerability Scanning (MUST)

Projects MUST use automated dependency vulnerability scanning.

| Language | Tool                   | Command             |
| -------- | ---------------------- | ------------------- |
| Rust     | cargo-audit            | `cargo audit`       |
| Node.js  | npm audit              | `npm audit`         |
| Python   | pip-audit, safety      | `pip-audit`         |
| Java     | OWASP Dependency-Check | `dependency-check`  |
| Go       | govulncheck            | `govulncheck ./...` |

### Scanning Schedule (MUST)

Scanning MUST occur:

- On every pull request
- On every push to protected branches
- On a scheduled basis (daily minimum)

### Vulnerability Response (MUST)

Critical and high severity vulnerabilities MUST block PR merges.

### Vulnerability Exceptions

Known vulnerabilities that cannot be fixed MUST be:

1. Documented with justification
2. Listed in an ignore/allowlist with expiration dates
3. Reviewed quarterly

```toml
# Example: cargo-deny ignore
[advisories]
ignore = [
    # RUSTSEC-2024-0001: No fix available, mitigated by input validation
    # Expires: 2024-06-01, Review: Issue #123
    "RUSTSEC-2024-0001",
]
```

## Supply Chain Security

### Required Checks (MUST)

| Check               | Purpose                                      |
| ------------------- | -------------------------------------------- |
| License compliance  | Verify all dependencies use allowed licenses |
| Source verification | Ensure dependencies from trusted sources     |
| Advisory database   | Check against known vulnerability databases  |
| Package bans        | Block known problematic packages             |
| Duplicate detection | Identify multiple versions of same package   |

### Allowed Licenses (MUST)

Allowed licenses MUST be explicitly defined. Recommended allowed licenses:

| License      | Status       |
| ------------ | ------------ |
| MIT          | SHOULD allow |
| Apache-2.0   | SHOULD allow |
| BSD-2-Clause | SHOULD allow |
| BSD-3-Clause | SHOULD allow |
| ISC          | SHOULD allow |
| MPL-2.0      | SHOULD allow |
| CC0-1.0      | SHOULD allow |
| Unlicense    | SHOULD allow |
| Zlib         | SHOULD allow |

### Copyleft Licenses (MUST)

Copyleft licenses (GPL-3.0, AGPL-3.0) MUST be explicitly reviewed and approved before use.

### Supply Chain Configuration

```toml
# Example: cargo-deny.toml
[licenses]
allow = [
    "MIT",
    "Apache-2.0",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "MPL-2.0",
    "CC0-1.0",
    "Unlicense",
    "Zlib",
]

[bans]
multiple-versions = "warn"
deny = [
    # Banned packages
]

[sources]
unknown-registry = "deny"
unknown-git = "deny"
```

## Code Security

### Security Scanning (MUST)

All code MUST be scanned for:

- Hardcoded secrets
- Security misconfigurations
- Common vulnerability patterns (OWASP Top 10)

### Secret Detection

Use secret scanning tools:

| Tool                   | Usage                      |
| ---------------------- | -------------------------- |
| gitleaks               | `gitleaks detect`          |
| truffleHog             | `trufflehog git file://./` |
| GitHub Secret Scanning | Enabled in repo settings   |

### Security Dashboard (MUST)

Security scan results MUST be uploaded to a centralized security dashboard (e.g., GitHub Security tab).

### Semantic Code Analysis (SHOULD)

Projects SHOULD implement semantic code analysis:

- CodeQL (GitHub)
- Semgrep
- SonarQube

## Audit Schedule

### Quarterly Audits (MUST)

Full dependency audits MUST be conducted quarterly.

### Pre-release Monitoring (MUST)

Pre-release dependencies MUST be monitored and documented.

### Remediation SLAs (MUST)

Audit findings MUST be tracked and remediated within defined SLAs:

| Severity | Remediation Window |
| -------- | ------------------ |
| Critical | 7 days             |
| High     | 30 days            |
| Medium   | 90 days            |
| Low      | Next major release |

## Implementation Checklist

- [ ] Set up vulnerability scanning tool
- [ ] Configure daily scheduled scans
- [ ] Define allowed licenses
- [ ] Configure supply chain checks
- [ ] Set up secret scanning
- [ ] Enable GitHub Security features
- [ ] Document exception process
- [ ] Establish quarterly audit schedule
- [ ] Define remediation SLAs

## Compliance Verification

```bash
# Run vulnerability scan
cargo audit          # Rust
npm audit            # Node.js
pip-audit            # Python

# Check license compliance
cargo deny check licenses

# Scan for secrets
gitleaks detect --source .

# Check for multiple versions
cargo deny check bans
```

## Additional Resources

### Reference Files

- **`references/security-tools.md`** - Security tool configuration
- **`references/license-guide.md`** - License compliance guide

### Examples

- **`examples/cargo-deny.toml`** - Rust supply chain config
- **`examples/npm-audit-config.json`** - Node.js audit config
- **`examples/gitleaks.toml`** - Secret scanning config
