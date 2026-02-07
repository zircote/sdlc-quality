---
name: Release Management Standards
description: This skill should be used when the user asks about "release process", "versioning", "semantic versioning", "semver", "release automation", "publishing", "package publishing", "release checklist", "version bump", "release notes", or needs guidance on release workflows and version management.
version: 1.0.0
---

# Release Management Standards

Guidance for implementing release requirements including versioning, automation, and publishing workflows.

## Tooling

> **Available Tools**: If using Claude Code, the `agents:release` skill can prepare and execute releases with version bumps and validation. The `documentation-review:changelog` skill manages changelog entries.

## Versioning Requirements

### Semantic Versioning (MUST)

Projects MUST follow Semantic Versioning (SemVer):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

| Component  | When to Increment                       |
| ---------- | --------------------------------------- |
| MAJOR      | Breaking API changes                    |
| MINOR      | New backwards-compatible features       |
| PATCH      | Backwards-compatible bug fixes          |
| PRERELEASE | Pre-release versions (alpha, beta, rc)  |
| BUILD      | Build metadata (ignored for precedence) |

### Version Examples

```
1.0.0         # Initial release
1.0.1         # Patch release (bug fix)
1.1.0         # Minor release (new feature)
2.0.0         # Major release (breaking change)
2.0.0-alpha.1 # Pre-release
2.0.0-rc.1    # Release candidate
2.0.0+build.123 # With build metadata
```

### Pre-release Versions (MUST)

Pre-release versions MUST follow this progression:

1. `x.y.z-alpha.N` - Early testing, unstable
2. `x.y.z-beta.N` - Feature complete, testing
3. `x.y.z-rc.N` - Release candidate, final testing

## Release Process

### Pre-Release Checklist (MUST)

Before releasing, verify:

| Check                       | Requirement                 |
| --------------------------- | --------------------------- |
| All tests pass              | MUST                        |
| No security vulnerabilities | MUST                        |
| Documentation updated       | MUST                        |
| CHANGELOG updated           | MUST                        |
| Version bumped              | MUST                        |
| Breaking changes documented | MUST (if applicable)        |
| Migration guide provided    | SHOULD (for major versions) |

### Release Workflow (MUST)

1. **Prepare**: Update version, changelog, documentation
2. **Validate**: Run full test suite and security audit
3. **Tag**: Create signed Git tag
4. **Build**: Generate release artifacts
5. **Publish**: Deploy to package registry
6. **Announce**: Create GitHub release with notes

### Git Tags (MUST)

Release tags MUST:

- Use `v` prefix: `v1.2.3`
- Be annotated or signed
- Reference the release commit

```bash
# Annotated tag
git tag -a v1.2.3 -m "Release v1.2.3"

# Signed tag (preferred)
git tag -s v1.2.3 -m "Release v1.2.3"
```

## Changelog Management

### Changelog Requirements (MUST)

CHANGELOG.md MUST:

- Follow Keep a Changelog format
- Be updated before every release
- Include all notable changes
- Link to comparison between versions

### Changelog Entry Structure

```markdown
## [1.2.0] - 2024-01-15

### Added

- New authentication methods (#123)

### Changed

- Improved error messages (#124)

### Fixed

- Memory leak in parser (#125)

### Security

- Updated dependencies for CVE-2024-001

[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
```

## Release Automation

### Automated Releases (SHOULD)

Projects SHOULD implement automated releases:

```yaml
# GitHub Actions release workflow
name: Release

on:
  push:
    tags:
      - "v*"

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: make build

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
          files: |
            dist/*
```

### Version Bump Automation (SHOULD)

Automate version bumps based on commit types:

| Commit Type                    | Version Bump |
| ------------------------------ | ------------ |
| `fix:`                         | PATCH        |
| `feat:`                        | MINOR        |
| `feat!:` or `BREAKING CHANGE:` | MAJOR        |

## Package Publishing

### Registry Configuration (MUST)

Configure publishing to appropriate registries:

| Language | Registry      | Config File      |
| -------- | ------------- | ---------------- |
| Rust     | crates.io     | `Cargo.toml`     |
| Node.js  | npm           | `package.json`   |
| Python   | PyPI          | `pyproject.toml` |
| Java     | Maven Central | `pom.xml`        |
| Go       | Go Modules    | `go.mod`         |

### Publishing Checklist (MUST)

Before publishing:

- [ ] Version matches Git tag
- [ ] Package metadata complete
- [ ] License file included
- [ ] README included
- [ ] No sensitive data in package
- [ ] Dependencies properly declared

### Publish Verification (MUST)

After publishing, verify:

- Package installable from registry
- Version appears correctly
- Documentation renders properly
- No missing files

## Release Notes

### Release Notes Content (MUST)

Release notes MUST include:

- Version number and release date
- Summary of changes
- Breaking changes (highlighted)
- Migration instructions (if needed)
- Contributors acknowledgment

### Release Notes Template

```markdown
# Release v1.2.0

## Highlights

Brief summary of key changes

## Breaking Changes

- Change 1: Migration steps...

## New Features

- Feature 1 (#123)
- Feature 2 (#124)

## Bug Fixes

- Fix 1 (#125)

## Contributors

Thanks to @contributor1, @contributor2
```

## Implementation Checklist

- [ ] Define versioning scheme (SemVer)
- [ ] Create release checklist
- [ ] Set up changelog automation
- [ ] Configure Git tag signing
- [ ] Implement release workflow
- [ ] Configure package registry publishing
- [ ] Create release notes template
- [ ] Set up release announcement process

## Compliance Verification

```bash
# Verify version format
echo "v1.2.3" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+\.[0-9]+)?$"

# Check changelog has entry for version
grep -E "^\## \[1\.2\.3\]" CHANGELOG.md

# Verify tag exists and is signed
git tag -v v1.2.3

# Check package version matches
cargo metadata --format-version 1 | jq '.packages[0].version'
npm pkg get version
```

## Additional Resources

### Reference Files

- **`references/release-workflow.md`** - Detailed release process
- **`references/versioning-guide.md`** - Versioning decision guide

### Examples

- **`examples/release.yml`** - GitHub Actions release workflow
- **`examples/RELEASE_CHECKLIST.md`** - Pre-release checklist template
