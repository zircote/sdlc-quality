---
name: sdlc-setup
description: Initialize a new project with SDLC-compliant structure. Creates required files, configures build system, sets up CI/CD, and establishes quality tooling.
argument-hint: "[language] [project-name-optional]"
allowed-tools: Bash, Read, Write, Glob
---

# SDLC Project Initialization

Initialize a new project with full SDLC compliance from the start.

## Process

### 1. Detect or Confirm Language

If not specified, detect from existing files or ask:

```bash
# Auto-detect language
if [ -f "Cargo.toml" ]; then echo "rust"
elif [ -f "package.json" ]; then echo "typescript"
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then echo "python"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then echo "java"
elif [ -f "go.mod" ]; then echo "go"
else echo "unknown"
fi
```

### 2. Create Directory Structure

```bash
# Create standard directories
mkdir -p src tests docs docs/adrs .github/workflows

# Language-specific directories
# Rust: src/ already standard
# TypeScript: src/, tests/
# Python: src/{package}/, tests/
# Java: src/main/java/, src/test/java/
# Go: cmd/, internal/, pkg/
```

### 3. Create Required Files

#### README.md

````markdown
# Project Name

[![CI](https://github.com/org/repo/actions/workflows/ci.yml/badge.svg)](...)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Brief project description.

## Installation

```bash
# Installation instructions
```
````

## Quick Start

```bash
# Usage example
```

## Documentation

See [docs/](docs/) for detailed documentation.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)

```

#### LICENSE (MIT default)

```

MIT License

Copyright (c) [year] [name]

Permission is hereby granted, free of charge, to any person obtaining a copy
...

````

#### CONTRIBUTING.md

```markdown
# Contributing

## Development Setup

1. Clone the repository
2. Install dependencies: `make setup`
3. Run tests: `make test`

## Code Style

- Run `make format` before committing
- Ensure `make lint` passes
- Follow existing code patterns

## Pull Request Process

1. Create feature branch from `develop`
2. Make changes with tests
3. Update documentation
4. Submit PR with description

## Commit Messages

Follow Conventional Commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code restructuring
````

#### CHANGELOG.md

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Initial project setup

[Unreleased]: https://github.com/org/repo/compare/v0.1.0...HEAD
```

#### SECURITY.md

```markdown
# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 0.x.x   | ✅        |

## Reporting a Vulnerability

Please report security vulnerabilities to: security@example.com

Do not open public issues for security vulnerabilities.

## Response Timeline

- Initial response: 48 hours
- Assessment: 7 days
- Fix timeline: Based on severity
```

#### .gitignore (language-specific)

Generate appropriate .gitignore for the detected language.

#### .gitattributes

```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
```

#### .editorconfig

```ini
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8
indent_style = space
indent_size = 4

[*.{yml,yaml,json,md}]
indent_size = 2

[Makefile]
indent_style = tab
```

### 4. Create Build System

#### Makefile

```makefile
.PHONY: all build test lint format format-check clean setup audit docs

all: build test

build:
	@echo "Building..."
	# Language-specific build command

test:
	@echo "Running tests..."
	# Language-specific test command

lint:
	@echo "Running linter..."
	# Language-specific lint command

format:
	@echo "Formatting code..."
	# Language-specific format command

format-check:
	@echo "Checking formatting..."
	# Language-specific format check

clean:
	@echo "Cleaning..."
	# Language-specific clean command

setup:
	@echo "Setting up development environment..."
	# Install dependencies and tools

audit:
	@echo "Running security audit..."
	# Language-specific audit command

docs:
	@echo "Building documentation..."
	# Language-specific docs command
```

### 5. Create CI Workflow

#### .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

env:
  CI: true

jobs:
  format:
    name: Format Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check formatting
        run: make format-check

  lint:
    name: Lint
    runs-on: ubuntu-latest
    needs: format
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: make lint

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - name: Test
        run: make test

  security:
    name: Security Audit
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - name: Audit
        run: make audit
```

### 6. Configure Quality Tools

Create language-specific configuration files:

**Rust:**

- `rustfmt.toml`
- `clippy.toml`
- `deny.toml`

**TypeScript:**

- `.prettierrc`
- `eslint.config.js`
- `tsconfig.json`

**Python:**

- `pyproject.toml` (with ruff config)

**Java:**

- `checkstyle.xml`
- `spotbugs.xml`

**Go:**

- `.golangci.yml`

### 7. Initialize ADRs

```bash
mkdir -p docs/adrs
```

Create `docs/adrs/README.md`:

```markdown
# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for this project.

## Index

| ADR                                          | Title                | Status   |
| -------------------------------------------- | -------------------- | -------- |
| [ADR-0001](adr-0001-initial-architecture.md) | Initial Architecture | Accepted |
```

### 8. Initialize Git

```bash
git init
git add .
git commit -m "chore: initialize SDLC-compliant project structure"
```

## Post-Initialization

After initialization, run `/sdlc:check` to verify compliance.

## Customization

The init command creates a standard structure. Customize as needed:

- Adjust Makefile targets for your build system
- Modify CI workflow for your needs
- Add language-specific configuration

## Language-Specific Templates

For detailed language-specific setup, refer to the skill files:

- `skills/build/SKILL.md` - Build system details
- `skills/quality/SKILL.md` - Quality tool configuration
- `skills/ci/SKILL.md` - CI workflow templates
