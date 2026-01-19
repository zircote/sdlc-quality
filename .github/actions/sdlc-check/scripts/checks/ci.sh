#!/usr/bin/env bash
# SDLC Check: CI/CD
# Validates CI/CD pipeline configuration

check_ci() {
  local score=10

  # Check for CI workflow file (MUST)
  local has_ci=false
  local ci_file=""

  if [[ -f ".github/workflows/ci.yml" ]]; then
    has_ci=true
    ci_file=".github/workflows/ci.yml"
  elif [[ -f ".github/workflows/ci.yaml" ]]; then
    has_ci=true
    ci_file=".github/workflows/ci.yaml"
  elif [[ -f ".github/workflows/build.yml" ]]; then
    has_ci=true
    ci_file=".github/workflows/build.yml"
  elif [[ -f ".github/workflows/test.yml" ]]; then
    has_ci=true
    ci_file=".github/workflows/test.yml"
  elif [[ -f ".gitlab-ci.yml" ]]; then
    has_ci=true
    ci_file=".gitlab-ci.yml"
  elif [[ -f "Jenkinsfile" ]]; then
    has_ci=true
    ci_file="Jenkinsfile"
  elif [[ -f ".circleci/config.yml" ]]; then
    has_ci=true
    ci_file=".circleci/config.yml"
  elif [[ -f "azure-pipelines.yml" ]]; then
    has_ci=true
    ci_file="azure-pipelines.yml"
  fi

  if [[ "$has_ci" == "false" ]]; then
    add_finding "ci" "$SEVERITY_MUST" "No CI/CD configuration found"
    ((score -= 4))
    set_domain_score "ci" "$score"
    return
  fi

  # For GitHub Actions, check specific requirements
  if [[ "$ci_file" == ".github/workflows/"* ]]; then
    # Check for required jobs (MUST)
    local has_format_job=false
    local has_lint_job=false
    local has_test_job=false
    local has_security_job=false

    if grep -qE "^\s*(format|formatting|fmt):" "$ci_file" 2>/dev/null || grep -q "prettier\|fmt\|format" "$ci_file" 2>/dev/null; then
      has_format_job=true
    fi

    if grep -qE "^\s*lint:" "$ci_file" 2>/dev/null || grep -q "eslint\|clippy\|pylint\|golangci" "$ci_file" 2>/dev/null; then
      has_lint_job=true
    fi

    if grep -qE "^\s*test:" "$ci_file" 2>/dev/null || grep -q "pytest\|jest\|cargo test\|go test" "$ci_file" 2>/dev/null; then
      has_test_job=true
    fi

    if grep -qE "^\s*security:" "$ci_file" 2>/dev/null || grep -q "audit\|snyk\|trivy\|dependabot" "$ci_file" 2>/dev/null; then
      has_security_job=true
    fi

    if [[ "$has_format_job" == "false" ]]; then
      add_finding "ci" "$SEVERITY_MUST" "CI missing format check job" "$ci_file"
      ((score -= 1))
    fi

    if [[ "$has_lint_job" == "false" ]]; then
      add_finding "ci" "$SEVERITY_MUST" "CI missing lint job" "$ci_file"
      ((score -= 1))
    fi

    if [[ "$has_test_job" == "false" ]]; then
      add_finding "ci" "$SEVERITY_MUST" "CI missing test job" "$ci_file"
      ((score -= 2))
    fi

    if [[ "$has_security_job" == "false" ]]; then
      add_finding "ci" "$SEVERITY_SHOULD" "CI missing security scanning job" "$ci_file"
      ((score -= 1))
    fi

    # Check for pinned action versions (MUST)
    if grep -E "uses:.*@(main|master|latest)" "$ci_file" 2>/dev/null | head -1 >/dev/null; then
      add_finding "ci" "$SEVERITY_MUST" "Actions should be pinned to version tags or SHA, not 'main/master/latest'" "$ci_file"
      ((score -= 2))
    fi

    # Check if actions are pinned (should use @vX or @SHA)
    if grep -E "uses: [^@]+$" "$ci_file" 2>/dev/null | head -1 >/dev/null; then
      add_finding "ci" "$SEVERITY_MUST" "Actions must be pinned to a version" "$ci_file"
      ((score -= 1))
    fi

    # Check for caching (SHOULD)
    if ! grep -qE "cache|restore-cache|setup-.*cache" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_SHOULD" "Consider adding caching to speed up CI" "$ci_file"
      ((score -= 1))
    fi

    # Check for concurrency control (SHOULD)
    if ! grep -q "concurrency:" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_SHOULD" "Consider adding concurrency control to cancel redundant runs" "$ci_file"
      ((score -= 1))
    fi

    # Check for permissions (SHOULD)
    if ! grep -q "permissions:" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_SHOULD" "Consider adding explicit permissions block for least-privilege" "$ci_file"
      ((score -= 1))
    fi

    # Check for multi-platform testing (MAY)
    if ! grep -qE "matrix|ubuntu.*windows.*macos|os:\s*\[" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_MAY" "Consider multi-platform testing with matrix strategy"
    fi

    # Check for pull_request trigger (MUST)
    if ! grep -q "pull_request" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_MUST" "CI should run on pull_request events" "$ci_file"
      ((score -= 1))
    fi

    # Check for protected branch trigger (SHOULD)
    if ! grep -qE "push:.*main|push:.*master|branches:.*main|branches:.*master" "$ci_file" 2>/dev/null; then
      add_finding "ci" "$SEVERITY_SHOULD" "CI should run on pushes to protected branches" "$ci_file"
      ((score -= 1))
    fi
  fi

  # Check for dependabot configuration (SHOULD)
  if [[ ! -f ".github/dependabot.yml" ]] && [[ ! -f ".github/dependabot.yaml" ]]; then
    add_finding "ci" "$SEVERITY_SHOULD" "Consider adding Dependabot configuration for automated dependency updates"
    ((score -= 1))
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "ci" "$score"
}
