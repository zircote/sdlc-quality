---
name: check
description: Run SDLC compliance check against the current project. Validates build system, code quality, testing, CI/CD, security, documentation, VCS, and release configurations.
---

# SDLC Compliance Check

Perform a comprehensive compliance check of the current project against SDLC requirements.

## Process

### 1. Detect Project Type

First, identify the project's language and framework:

```bash
# Check for language indicators
ls Cargo.toml package.json pyproject.toml pom.xml build.gradle go.mod 2>/dev/null
```

### 2. Run Domain Checks

Check each SDLC domain for compliance. Use the specialized agents if available, or perform checks directly.

#### Build System Check
- [ ] Makefile exists with standard targets
- [ ] Build configuration present
- [ ] `make build` works
- [ ] `make test` works
- [ ] `make lint` works
- [ ] `make format` works

```bash
# Verify Makefile targets
make -n build test lint format clean 2>/dev/null && echo "✓ Makefile targets OK" || echo "✗ Makefile missing targets"
```

#### Code Quality Check
- [ ] Formatter configured
- [ ] Linter configured
- [ ] Format check passes
- [ ] Lint check passes

```bash
# Run format check
make format-check 2>/dev/null || echo "Format check failed or not configured"

# Run lint
make lint 2>/dev/null || echo "Lint failed or not configured"
```

#### Testing Check
- [ ] Tests exist
- [ ] Tests pass
- [ ] Coverage configured

```bash
# Run tests
make test 2>/dev/null || echo "Tests failed or not configured"
```

#### CI/CD Check
- [ ] Workflow file exists
- [ ] Required jobs present
- [ ] Actions pinned
- [ ] Caching configured

```bash
# Check CI workflow
ls .github/workflows/ci.yml .github/workflows/ci.yaml 2>/dev/null || echo "✗ No CI workflow found"

# Check for pinned actions
grep -E "uses:.*@v[0-9]" .github/workflows/*.yml 2>/dev/null | head -5
```

#### Security Check
- [ ] Vulnerability scanning configured
- [ ] License compliance defined
- [ ] SECURITY.md exists

```bash
# Check security config
ls SECURITY.md 2>/dev/null || echo "✗ SECURITY.md missing"
ls cargo-deny.toml .cargo/audit.toml 2>/dev/null  # Rust
ls .npmrc package.json 2>/dev/null | xargs grep -l "audit" 2>/dev/null  # Node
```

#### Documentation Check
- [ ] README.md exists with required sections
- [ ] CONTRIBUTING.md exists
- [ ] CHANGELOG.md exists
- [ ] LICENSE exists

```bash
# Check required docs
for f in README.md CONTRIBUTING.md CHANGELOG.md LICENSE; do
  [ -f "$f" ] && echo "✓ $f" || echo "✗ $f missing"
done
```

#### Version Control Check
- [ ] .gitignore exists
- [ ] .gitattributes exists
- [ ] Branch protection (check via gh if available)

```bash
# Check VCS files
for f in .gitignore .gitattributes; do
  [ -f "$f" ] && echo "✓ $f" || echo "✗ $f missing"
done
```

### 3. Generate Report

Compile findings into a compliance report:

```markdown
# SDLC Compliance Report

**Project**: [detected name]
**Language**: [detected language]
**Date**: [current date]

## Summary

| Domain | Status | Issues |
|--------|--------|--------|
| Build | ✓/✗ | N |
| Quality | ✓/✗ | N |
| Testing | ✓/✗ | N |
| CI/CD | ✓/✗ | N |
| Security | ✓/✗ | N |
| Docs | ✓/✗ | N |
| VCS | ✓/✗ | N |

## Findings

### Critical (Must Fix)
- [List critical issues]

### Important (Should Fix)
- [List important issues]

### Suggestions
- [List recommendations]

## Next Steps
1. [Prioritized remediation steps]
```

## Quick Check Mode

For a fast check of just the essentials:

```bash
# Essential files check
echo "=== SDLC Essential Files Check ==="
for f in Makefile README.md LICENSE CONTRIBUTING.md CHANGELOG.md SECURITY.md .gitignore; do
  [ -f "$f" ] && echo "✓ $f" || echo "✗ $f"
done

# CI check
[ -d ".github/workflows" ] && echo "✓ CI workflows directory" || echo "✗ No CI workflows"

# Build check
make -n build test lint 2>/dev/null && echo "✓ Makefile targets" || echo "✗ Makefile incomplete"
```

## Using Specialized Agents

When running in Claude Code with the sdlc plugin, leverage the specialized agents for deeper analysis:

- **compliance-auditor**: Full comprehensive audit
- **security-reviewer**: Deep security analysis
- **quality-enforcer**: Code quality assessment
- **ci-architect**: CI/CD pipeline review

Example: "Run the compliance-auditor agent for a full SDLC audit"

## Output

Present findings clearly with:
1. Overall compliance status
2. Domain-by-domain breakdown
3. Prioritized list of issues
4. Specific remediation steps
5. Commands to fix auto-fixable issues
