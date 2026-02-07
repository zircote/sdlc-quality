---
name: Project Setup Standards
description: This skill should be used when the user asks about "project setup", "project initialization", "repository setup", "new project", "bootstrap project", "project structure", "development environment", "toolchain setup", "project configuration", or needs guidance on setting up new projects that comply with SDLC standards.
version: 1.0.0
---

# Project Setup Standards

Guidance for initializing new projects that comply with all SDLC requirements from the start.

## Tooling

> **Available Tools**: If using Claude Code with the sdlc plugin, run `/sdlc:init` to bootstrap a compliant project structure. The `/sdlc:check` command validates existing projects.

## Project Initialization

### Required Steps (MUST)

New projects MUST complete these setup steps:

| Order | Step                    | Purpose                         |
| ----- | ----------------------- | ------------------------------- |
| 1     | Create repository       | Initialize Git with main branch |
| 2     | Add standard files      | LICENSE, README, etc.           |
| 3     | Configure build system  | Makefile with standard targets  |
| 4     | Set up CI pipeline      | GitHub Actions workflow         |
| 5     | Configure quality tools | Formatter, linter, etc.         |
| 6     | Add security scanning   | Dependency audit, secrets scan  |
| 7     | Create documentation    | README, CONTRIBUTING, etc.      |

### Repository Initialization

```bash
# Initialize repository
git init
git branch -M main

# Create standard directory structure
mkdir -p src tests docs .github/workflows

# Initialize with empty commit
git commit --allow-empty -m "chore: initialize repository"
```

## Required Files

### Mandatory Files (MUST)

Every project MUST include:

| File              | Purpose           | Template              |
| ----------------- | ----------------- | --------------------- |
| `README.md`       | Project overview  | See docs skill        |
| `LICENSE`         | License terms     | MIT, Apache-2.0, etc. |
| `CONTRIBUTING.md` | Contributor guide | See docs skill        |
| `CHANGELOG.md`    | Version history   | Keep a Changelog      |
| `SECURITY.md`     | Security policy   | See security skill    |
| `.gitignore`      | Git exclusions    | Language-specific     |
| `.gitattributes`  | Git attributes    | See vcs skill         |
| `Makefile`        | Build commands    | See build skill       |

### Configuration Files (MUST)

Projects MUST include appropriate configuration:

| Category   | Files                                        |
| ---------- | -------------------------------------------- |
| Build      | `Makefile`, `Cargo.toml`/`package.json`/etc. |
| Formatting | `rustfmt.toml`/`.prettierrc`/etc.            |
| Linting    | `clippy.toml`/`eslint.config.js`/etc.        |
| CI         | `.github/workflows/ci.yml`                   |
| Editor     | `.editorconfig`                              |

### EditorConfig (MUST)

Projects MUST include `.editorconfig`:

```ini
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8

[*.{rs,ts,js,py,java,go}]
indent_style = space
indent_size = 4

[*.{yml,yaml,json}]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

## Build System Setup

### Makefile Targets (MUST)

Create Makefile with standard targets:

```makefile
.PHONY: all build test lint format clean

all: build test

build:
	# Language-specific build command

test:
	# Run test suite

lint:
	# Run linter

format:
	# Format code

format-check:
	# Check formatting without changes

clean:
	# Clean build artifacts
```

### Language-Specific Setup

#### Rust

```bash
cargo init
# Add to Cargo.toml:
# [lints.clippy]
# all = "warn"
# pedantic = "warn"

touch rustfmt.toml clippy.toml
```

#### TypeScript/Node.js

```bash
npm init -y
npm install -D typescript eslint prettier
npx tsc --init
```

#### Python

```bash
python -m venv .venv
pip install ruff pytest
# Create pyproject.toml with ruff config
```

#### Java

```bash
# Maven
mvn archetype:generate -DgroupId=com.example -DartifactId=project

# Gradle
gradle init --type java-application
```

## CI/CD Setup

### GitHub Actions (MUST)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: make build
      - name: Test
        run: make test
      - name: Lint
        run: make lint
```

### Branch Protection (MUST)

Configure branch protection for `main`:

- Require pull request reviews
- Require status checks to pass
- Require linear history (recommended)

## Quality Tools Setup

### Pre-commit Hooks (SHOULD)

Install pre-commit:

```bash
pip install pre-commit
pre-commit install
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

## Security Setup

### Secret Scanning (SHOULD)

Enable GitHub secret scanning or configure gitleaks:

```yaml
# .gitleaks.toml
[extend]
useDefault = true
```

### Dependency Auditing (MUST)

Configure automated dependency scanning based on language.

## Documentation Setup

### README Template

Create README.md with required sections:

- Project name and description
- Badges (CI, version, license)
- Installation instructions
- Quick start
- Contributing link
- License

### ADR Directory (SHOULD)

Set up Architecture Decision Records:

```bash
mkdir -p docs/adrs
touch docs/adrs/README.md
```

## Implementation Checklist

### Repository Setup

- [ ] Initialize Git repository
- [ ] Create main branch
- [ ] Add `.gitignore`
- [ ] Add `.gitattributes`
- [ ] Configure branch protection

### Required Files

- [ ] Create `README.md`
- [ ] Add `LICENSE`
- [ ] Create `CONTRIBUTING.md`
- [ ] Create `CHANGELOG.md`
- [ ] Add `SECURITY.md`
- [ ] Create `.editorconfig`

### Build System

- [ ] Create `Makefile` with standard targets
- [ ] Add language-specific build config
- [ ] Verify `make all` works

### Quality Tools

- [ ] Configure formatter
- [ ] Configure linter
- [ ] Set up pre-commit hooks
- [ ] Verify `make lint` and `make format` work

### CI/CD

- [ ] Create GitHub Actions workflow
- [ ] Configure required status checks
- [ ] Add security scanning job

### Documentation

- [ ] Populate README with content
- [ ] Set up ADR directory
- [ ] Create initial ADRs if applicable

## Compliance Verification

```bash
# Verify required files exist
for f in README.md LICENSE CONTRIBUTING.md CHANGELOG.md SECURITY.md .gitignore .gitattributes Makefile .editorconfig; do
  [ -f "$f" ] && echo "✓ $f" || echo "✗ $f missing"
done

# Verify CI workflow exists
ls .github/workflows/ci.yml

# Verify Makefile targets
make -n build test lint format

# Run initial compliance check
make lint && make test
```

## Additional Resources

### Reference Files

- **`references/setup-guide.md`** - Detailed setup walkthrough
- **`references/toolchain-versions.md`** - Recommended tool versions

### Examples

- **`examples/project-rust/`** - Complete Rust project template
- **`examples/project-typescript/`** - Complete TypeScript template
- **`examples/project-python/`** - Complete Python template
