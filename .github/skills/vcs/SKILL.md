---
name: vcs
description: This skill should be used when the user asks about "version control", "git workflow", "branching strategy", "commit messages", "conventional commits", "git hooks", "branch naming", "merge strategy", "PR requirements", "pull request process", or needs guidance on version control practices and Git configuration.
version: 1.0.0
---

# Version Control Standards

Guidance for implementing version control requirements including branching strategies, commit conventions, and Git workflow configuration.

## Tooling

> **Available Tools**: If using Claude Code, the `gh` plugin provides Git workflow commands (`/gh:commit`, `/gh:pr`, `/gh:sync`). The `commit-commands` plugin offers commit automation (`/commit`, `/commit-push-pr`).

## Branching Strategy

### Branch Types (MUST)

Projects MUST use a defined branching strategy with these branch types:

| Branch Type | Naming Pattern | Purpose                    |
| ----------- | -------------- | -------------------------- |
| Main        | `main`         | Production-ready code      |
| Development | `develop`      | Integration branch         |
| Feature     | `feature/*`    | New functionality          |
| Bugfix      | `bugfix/*`     | Bug repairs                |
| Hotfix      | `hotfix/*`     | Emergency production fixes |
| Release     | `release/*`    | Release preparation        |

### Branch Protection (MUST)

Protected branches (`main`, `develop`) MUST require:

- Pull request reviews before merge
- Status checks passing
- No direct commits
- Linear history (recommended)

### Branch Naming (MUST)

Branch names MUST follow the pattern: `type/description-with-dashes`

**Good:**

```
feature/user-authentication
bugfix/login-timeout-error
hotfix/security-patch-cve-2024
release/v2.1.0
```

**Bad:**

```
my-branch
fix
Feature_UserAuth
```

## Commit Message Standards

### Conventional Commits (MUST)

Projects MUST use Conventional Commits format:

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Commit Types (MUST)

| Type       | Purpose                    |
| ---------- | -------------------------- |
| `feat`     | New feature                |
| `fix`      | Bug fix                    |
| `docs`     | Documentation only         |
| `style`    | Formatting, no code change |
| `refactor` | Code restructuring         |
| `perf`     | Performance improvement    |
| `test`     | Adding/updating tests      |
| `build`    | Build system changes       |
| `ci`       | CI configuration           |
| `chore`    | Maintenance tasks          |

### Message Requirements (MUST)

Commit messages MUST:

- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line under 72 characters
- Separate subject from body with blank line
- Reference issues when applicable

### Breaking Changes (MUST)

Breaking changes MUST be indicated with:

- `!` after type/scope: `feat(api)!: change response format`
- `BREAKING CHANGE:` footer in body

### Commit Message Examples

**Good:**

```
feat(auth): add OAuth2 support for GitHub login

Implements OAuth2 flow for GitHub authentication.
Adds new configuration options for client credentials.

Closes #123
```

**Bad:**

```
fixed stuff
WIP
updates
```

## Pull Request Process

### PR Requirements (MUST)

Pull requests MUST include:

- Descriptive title following commit convention
- Summary of changes
- Testing instructions
- Link to related issues

### PR Template

```markdown
## Summary

Brief description of changes

## Changes

- Change 1
- Change 2

## Testing

How to test these changes

## Related Issues

Closes #123
```

### Review Requirements (MUST)

| Requirement              | Level                                 |
| ------------------------ | ------------------------------------- |
| Minimum reviewers        | MUST be at least 1                    |
| CI checks passing        | MUST pass                             |
| Code owner approval      | SHOULD be required for critical paths |
| Merge conflicts resolved | MUST be resolved                      |

## Git Configuration

### Required Git Hooks (SHOULD)

Projects SHOULD configure pre-commit hooks:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.0.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
```

### Git Attributes (MUST)

Projects MUST define `.gitattributes` for consistent line endings:

```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf
```

### Git Ignore (MUST)

Projects MUST maintain comprehensive `.gitignore` covering:

- Build artifacts
- IDE/editor files
- OS-specific files
- Dependency directories
- Environment files with secrets

## Merge Strategy

### Merge Methods (MUST)

Define allowed merge methods per branch:

| Target Branch | Allowed Methods      |
| ------------- | -------------------- |
| main          | Squash merge, Rebase |
| develop       | Merge commit, Squash |
| feature/\*    | Any                  |

### Squash Merge (SHOULD)

Squash merges SHOULD be used for feature branches to maintain clean history.

### Rebase Strategy (SHOULD)

Feature branches SHOULD be rebased on target before merge to resolve conflicts.

## Implementation Checklist

- [ ] Define branching strategy
- [ ] Configure branch protection rules
- [ ] Set up commit message validation
- [ ] Create PR template
- [ ] Configure pre-commit hooks
- [ ] Define `.gitattributes`
- [ ] Create comprehensive `.gitignore`
- [ ] Document merge strategy

## Compliance Verification

```bash
# Check branch protection (GitHub CLI)
gh api repos/{owner}/{repo}/branches/main/protection

# Validate commit message format
echo "feat(api): add endpoint" | commitlint

# Verify pre-commit hooks installed
pre-commit run --all-files

# Check gitattributes
git check-attr -a README.md
```

## Additional Resources

### Reference Files

- **`references/git-workflow.md`** - Detailed Git workflow guide
- **`references/commit-examples.md`** - Commit message examples

### Examples

- **`examples/.pre-commit-config.yaml`** - Pre-commit configuration
- **`examples/.gitattributes`** - Git attributes template
- **`examples/PULL_REQUEST_TEMPLATE.md`** - PR template
