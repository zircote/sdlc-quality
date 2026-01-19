# GitHub Actions Integration

This document describes how to integrate the SDLC Standards Plugin compliance checking into your GitHub Actions workflows.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Composite Action](#composite-action)
- [Reusable Workflow](#reusable-workflow)
- [Trigger Modes](#trigger-modes)
- [Output Formats](#output-formats)
- [AI Agent Integration](#ai-agent-integration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Overview

The SDLC Standards Plugin provides two integration options:

1. **Composite Action** (`zircote/sdlc-quality/.github/actions/sdlc-check@v1`) - Use directly in your workflow steps
2. **Reusable Workflow** (`zircote/sdlc-quality/.github/workflows/sdlc-audit.yml@main`) - Call as a complete workflow

Both options support:

- All 11 SDLC domains
- Multiple report formats (Markdown, JSON, SARIF)
- PR comments with results
- GitHub issue creation for failures
- GitHub Security tab integration (via SARIF)
- Scheduled audits
- Issue-triggered audits

## Quick Start

### Minimal Setup

Add to `.github/workflows/sdlc.yml`:

```yaml
name: SDLC Compliance

on:
  pull_request:
  push:
    branches: [main]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run SDLC Check
        uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
```

### With All Features

```yaml
name: SDLC Compliance

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: "0 9 * * 1" # Weekly on Monday

permissions:
  contents: read
  pull-requests: write
  issues: write
  security-events: write

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run SDLC Check
        id: sdlc
        uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
        with:
          domains: "all"
          fail-on-error: "true"
          report-format: "all"
          upload-artifact: "true"
          create-pr-comment: "true"
          create-issue: "true"

      - name: Check Results
        run: |
          echo "Score: ${{ steps.sdlc.outputs.score }}/100"
          echo "Status: ${{ steps.sdlc.outputs.status }}"
          echo "Critical: ${{ steps.sdlc.outputs.critical-count }}"
```

## Composite Action

### Inputs

| Input               | Description                        | Default    |
| ------------------- | ---------------------------------- | ---------- |
| `domains`           | Comma-separated domains or "all"   | `all`      |
| `fail-on-error`     | Fail if MUST requirements not met  | `true`     |
| `report-format`     | Format: markdown, json, sarif, all | `markdown` |
| `upload-artifact`   | Upload report as artifact          | `true`     |
| `create-pr-comment` | Comment on PR with results         | `true`     |
| `create-issue`      | Create issue for failures          | `false`    |
| `working-directory` | Directory to check                 | `.`        |
| `config-file`       | Custom configuration file          | ``         |

### Outputs

| Output             | Description                      |
| ------------------ | -------------------------------- |
| `score`            | Overall compliance score (0-100) |
| `status`           | Status: pass, warn, or fail      |
| `report-path`      | Path to generated report         |
| `critical-count`   | Number of MUST violations        |
| `important-count`  | Number of SHOULD violations      |
| `suggestion-count` | Number of MAY suggestions        |

### Domain Selection

Check specific domains:

```yaml
- uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
  with:
    domains: "security,ci,docs"
```

Available domains:

- `build` - Build system (Makefile, dependencies)
- `quality` - Code formatting and linting
- `testing` - Test coverage and organization
- `ci` - CI/CD pipeline configuration
- `security` - Vulnerability scanning, secrets
- `docs` - Documentation completeness
- `vcs` - Version control practices
- `release` - Versioning and release process
- `observability` - Logging, metrics, health
- `ai` - AI assistant configuration

## Reusable Workflow

Call the complete audit workflow:

```yaml
name: Weekly Audit

on:
  schedule:
    - cron: "0 9 * * 1"
  workflow_dispatch:

jobs:
  audit:
    uses: zircote/sdlc-quality/.github/workflows/sdlc-audit.yml@main
    with:
      domains: "all"
      fail-on-error: false
      create-issue: true
    permissions:
      contents: read
      pull-requests: write
      issues: write
      security-events: write
```

### Workflow Inputs

Same as composite action, plus:

| Input    | Description   | Default         |
| -------- | ------------- | --------------- |
| `runner` | Runner to use | `ubuntu-latest` |

### Workflow Outputs

| Output            | Description              |
| ----------------- | ------------------------ |
| `score`           | Overall compliance score |
| `status`          | Compliance status        |
| `critical-count`  | Critical violations      |
| `important-count` | Important violations     |

## Trigger Modes

### Pull Request

Automatically check PRs:

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

### Push to Protected Branch

Check on merge to main:

```yaml
on:
  push:
    branches: [main, develop]
```

### Scheduled

Weekly compliance audit:

```yaml
on:
  schedule:
    - cron: "0 9 * * 1" # Monday 9am UTC
```

### Manual Dispatch

On-demand with parameters:

```yaml
on:
  workflow_dispatch:
    inputs:
      domains:
        description: "Domains to check"
        type: choice
        options: [all, security, ci, docs]
        default: "all"
```

### Issue Assignment

Trigger audit when assigned to an issue:

```yaml
on:
  issues:
    types: [assigned]
```

Create an issue with:

- Title containing "SDLC", "compliance", or "audit"
- Label `sdlc-audit`
- Body with optional `domains: security,ci` line

## Output Formats

### Markdown Report

Human-readable report with:

- Summary table
- Domain scores
- Prioritized findings
- Remediation guidance

```yaml
report-format: "markdown"
```

### JSON Report

Machine-readable for tooling integration:

```yaml
report-format: "json"
```

Structure:

```json
{
  "project_name": "my-project",
  "score": 85,
  "status": "warn",
  "domain_scores": {
    "build": 10,
    "security": 7
  },
  "findings": [
    {
      "domain": "security",
      "severity": "important",
      "message": "No vulnerability scanning configured"
    }
  ]
}
```

### SARIF Report

For GitHub Security tab integration:

```yaml
report-format: "sarif"
```

Automatically uploads to GitHub Code Scanning when permissions allow.

### All Formats

Generate all formats:

```yaml
report-format: "all"
```

## AI Agent Integration

### GitHub Copilot Coding Agent

The repository includes `copilot-setup-steps.yml` for Copilot agent integration:

```yaml
# .github/workflows/copilot-setup-steps.yml is pre-configured
```

See `.github/copilot-instructions.md` for Copilot-specific guidance.

### Claude Code

Install the plugin:

```bash
claude plugins add github:zircote/sdlc-quality
```

Use slash commands:

```
/sdlc:check
/sdlc:init
```

### OpenAI Codex

Refer to `AGENTS.md` in the repository root for Codex guidelines.

## Examples

### Security-Focused Check

```yaml
name: Security Audit

on:
  pull_request:
    paths:
      - "Cargo.toml"
      - "package.json"
      - "requirements.txt"
      - ".github/workflows/**"

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
        with:
          domains: "security"
          fail-on-error: "true"
          create-pr-comment: "true"
```

### Documentation Compliance

```yaml
name: Docs Check

on:
  pull_request:
    paths:
      - "**.md"
      - "docs/**"

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
        with:
          domains: "docs,ai"
          fail-on-error: "false"
```

### Multi-Platform Matrix

```yaml
name: Cross-Platform SDLC

on: [push, pull_request]

jobs:
  compliance:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      - uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
        with:
          domains: "build,testing"
```

### Monorepo with Working Directory

```yaml
name: Service SDLC

on: [push]

jobs:
  check-services:
    strategy:
      matrix:
        service: [api, web, worker]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
        with:
          working-directory: "services/${{ matrix.service }}"
          upload-artifact: "true"
```

## Troubleshooting

### Action Not Found

Ensure you're using the correct path:

```yaml
uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
```

### Permission Denied

Add required permissions:

```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
  security-events: write
```

### SARIF Upload Failed

SARIF upload requires `security-events: write` permission and is only available on public repos or with GitHub Advanced Security.

### PR Comment Not Created

Ensure:

1. `create-pr-comment: 'true'`
2. Running on `pull_request` event
3. `pull-requests: write` permission

### False Positives

Use a config file to customize checks:

```bash
# .sdlc-config.sh
SKIP_DOMAINS="observability"
COVERAGE_THRESHOLD=70
```

```yaml
- uses: zircote/sdlc-quality/.github/actions/sdlc-check@v1
  with:
    config-file: ".sdlc-config.sh"
```

## Support

- [GitHub Issues](https://github.com/zircote/sdlc-quality/issues)
- [Discussions](https://github.com/zircote/sdlc-quality/discussions)
- [Documentation](https://github.com/zircote/sdlc-quality/tree/main/docs)
