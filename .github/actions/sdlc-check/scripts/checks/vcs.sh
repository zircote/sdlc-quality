#!/usr/bin/env bash
# SDLC Check: Version Control
# Validates VCS configuration and practices

check_vcs() {
  local score=10

  # Check for .gitignore (MUST)
  if [[ ! -f ".gitignore" ]]; then
    add_finding "vcs" "$SEVERITY_MUST" "Missing .gitignore"
    ((score -= 2))
  else
    local project_type
    project_type=$(detect_project_type)

    # Check for language-specific ignores
    local missing_ignores=()

    case "$project_type" in
      rust)
        if ! grep -q "target/" .gitignore 2>/dev/null; then
          missing_ignores+=("target/")
        fi
        ;;
      typescript|javascript)
        if ! grep -q "node_modules" .gitignore 2>/dev/null; then
          missing_ignores+=("node_modules/")
        fi
        if ! grep -qE "dist/|build/" .gitignore 2>/dev/null; then
          missing_ignores+=("dist/ or build/")
        fi
        ;;
      python)
        if ! grep -qE "__pycache__|\.pyc" .gitignore 2>/dev/null; then
          missing_ignores+=("__pycache__/")
        fi
        if ! grep -qE "\.venv|venv/" .gitignore 2>/dev/null; then
          missing_ignores+=("venv/")
        fi
        ;;
      go)
        if ! grep -q "vendor/" .gitignore 2>/dev/null; then
          # vendor/ is optional in Go
          :
        fi
        ;;
      java-maven|java-gradle)
        if ! grep -q "target/" .gitignore 2>/dev/null && ! grep -q "build/" .gitignore 2>/dev/null; then
          missing_ignores+=("target/ or build/")
        fi
        ;;
    esac

    # Common ignores
    if ! grep -qE "\.env|\.env\." .gitignore 2>/dev/null; then
      missing_ignores+=(".env")
    fi

    if [[ ${#missing_ignores[@]} -gt 0 ]]; then
      add_finding "vcs" "$SEVERITY_SHOULD" ".gitignore missing: ${missing_ignores[*]}" ".gitignore"
      ((score -= 1))
    fi
  fi

  # Check for .gitattributes (SHOULD)
  if [[ ! -f ".gitattributes" ]]; then
    add_finding "vcs" "$SEVERITY_SHOULD" "Missing .gitattributes - define line endings and merge strategies"
    ((score -= 1))
  else
    # Check for auto line ending normalization
    if ! grep -q "text=auto" .gitattributes 2>/dev/null; then
      add_finding "vcs" "$SEVERITY_MAY" "Consider adding '* text=auto' to .gitattributes for consistent line endings"
    fi
  fi

  # Check for PR template (SHOULD)
  if [[ ! -f ".github/PULL_REQUEST_TEMPLATE.md" ]] && [[ ! -f ".github/pull_request_template.md" ]] && [[ ! -d ".github/PULL_REQUEST_TEMPLATE" ]]; then
    add_finding "vcs" "$SEVERITY_SHOULD" "Missing PR template - helps ensure PR quality"
    ((score -= 1))
  fi

  # Check for issue templates (SHOULD)
  if [[ ! -d ".github/ISSUE_TEMPLATE" ]] && [[ ! -f ".github/ISSUE_TEMPLATE.md" ]]; then
    add_finding "vcs" "$SEVERITY_SHOULD" "Missing issue templates - helps standardize issue reporting"
    ((score -= 1))
  fi

  # Check for CODEOWNERS (SHOULD for teams)
  if [[ ! -f "CODEOWNERS" ]] && [[ ! -f ".github/CODEOWNERS" ]] && [[ ! -f "docs/CODEOWNERS" ]]; then
    add_finding "vcs" "$SEVERITY_MAY" "Consider adding CODEOWNERS file for code review assignments"
  fi

  # Check for branch protection configuration (SHOULD)
  # Note: Can't directly check GitHub settings, but can check for settings file
  if [[ -f ".github/settings.yml" ]]; then
    if ! grep -q "protection" .github/settings.yml 2>/dev/null; then
      add_finding "vcs" "$SEVERITY_SHOULD" "Consider configuring branch protection in .github/settings.yml"
      ((score -= 1))
    fi
  else
    add_finding "vcs" "$SEVERITY_MAY" "Consider adding .github/settings.yml for repository settings as code"
  fi

  # Check for conventional commits setup (SHOULD)
  local has_commit_lint=false

  if [[ -f "commitlint.config.js" ]] || [[ -f "commitlint.config.cjs" ]] || [[ -f ".commitlintrc" ]] || [[ -f ".commitlintrc.json" ]]; then
    has_commit_lint=true
  fi

  # Check for commit-msg hook
  if [[ -f ".husky/commit-msg" ]] || [[ -f ".git/hooks/commit-msg" ]]; then
    has_commit_lint=true
  fi

  # Check for conventional commit mention in CONTRIBUTING
  if [[ -f "CONTRIBUTING.md" ]] && grep -qi "conventional commit" CONTRIBUTING.md 2>/dev/null; then
    has_commit_lint=true
  fi

  if [[ "$has_commit_lint" == "false" ]]; then
    add_finding "vcs" "$SEVERITY_SHOULD" "Consider enforcing Conventional Commits format"
    ((score -= 1))
  fi

  # Check for signed commits configuration (MAY)
  if [[ -f ".github/settings.yml" ]] && grep -q "require_signed_commits: true" .github/settings.yml 2>/dev/null; then
    : # Good - signed commits required
  else
    add_finding "vcs" "$SEVERITY_MAY" "Consider requiring signed commits for enhanced security"
  fi

  # Check for linear history preference (MAY)
  if [[ -f ".github/settings.yml" ]] && ! grep -q "required_linear_history" .github/settings.yml 2>/dev/null; then
    add_finding "vcs" "$SEVERITY_MAY" "Consider enforcing linear history (rebase-only merges)"
  fi

  # Check current branch naming (info only)
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  if [[ "$current_branch" == "master" ]]; then
    add_finding "vcs" "$SEVERITY_MAY" "Consider renaming default branch from 'master' to 'main'"
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "vcs" "$score"
}
