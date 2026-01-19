#!/usr/bin/env bash
# SDLC Check: Code Quality
# Validates formatting, linting, and code quality configuration

check_quality() {
  local score=10
  local project_type
  project_type=$(detect_project_type)

  # Check formatter configuration (MUST)
  local has_formatter=false

  case "$project_type" in
    rust)
      if [[ -f "rustfmt.toml" ]] || [[ -f ".rustfmt.toml" ]]; then
        has_formatter=true
      fi
      ;;
    typescript|javascript)
      if [[ -f ".prettierrc" ]] || [[ -f ".prettierrc.json" ]] || [[ -f ".prettierrc.yml" ]] || [[ -f ".prettierrc.yaml" ]] || [[ -f "prettier.config.js" ]] || [[ -f "prettier.config.mjs" ]]; then
        has_formatter=true
      elif jq -e '.prettier' package.json >/dev/null 2>&1; then
        has_formatter=true
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]]; then
        if grep -qE "\[tool\.(black|ruff|yapf)\]" pyproject.toml 2>/dev/null; then
          has_formatter=true
        fi
      fi
      if [[ -f ".style.yapf" ]] || [[ -f "setup.cfg" ]]; then
        has_formatter=true
      fi
      ;;
    go)
      # Go has built-in formatting (gofmt), always considered configured
      has_formatter=true
      ;;
    java-maven|java-gradle)
      if [[ -f "checkstyle.xml" ]] || [[ -f ".editorconfig" ]]; then
        has_formatter=true
      fi
      ;;
  esac

  # Also check for .editorconfig as universal formatter config
  if [[ -f ".editorconfig" ]]; then
    has_formatter=true
  fi

  if [[ "$has_formatter" == "false" ]] && [[ "$project_type" != "unknown" ]]; then
    add_finding "quality" "$SEVERITY_MUST" "No code formatter configuration found"
    ((score -= 3))
  fi

  # Check linter configuration (MUST)
  local has_linter=false

  case "$project_type" in
    rust)
      if [[ -f "clippy.toml" ]] || [[ -f ".clippy.toml" ]]; then
        has_linter=true
      fi
      # Rust has clippy built-in, check if deny warnings is configured
      if grep -q "deny(warnings)" "$(find . -name '*.rs' -type f | head -1)" 2>/dev/null; then
        has_linter=true
      fi
      # Check Cargo.toml for lints
      if grep -qE "\[lints\]|\[workspace.lints\]" Cargo.toml 2>/dev/null; then
        has_linter=true
      fi
      ;;
    typescript|javascript)
      if [[ -f ".eslintrc" ]] || [[ -f ".eslintrc.json" ]] || [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.cjs" ]] || [[ -f ".eslintrc.yml" ]] || [[ -f "eslint.config.js" ]] || [[ -f "eslint.config.mjs" ]]; then
        has_linter=true
      fi
      # Check for biome
      if [[ -f "biome.json" ]] || [[ -f "biome.jsonc" ]]; then
        has_linter=true
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]]; then
        if grep -qE "\[tool\.(ruff|pylint|flake8)\]" pyproject.toml 2>/dev/null; then
          has_linter=true
        fi
      fi
      if [[ -f ".pylintrc" ]] || [[ -f ".flake8" ]] || [[ -f "ruff.toml" ]]; then
        has_linter=true
      fi
      ;;
    go)
      if [[ -f ".golangci.yml" ]] || [[ -f ".golangci.yaml" ]] || [[ -f "golangci.yml" ]]; then
        has_linter=true
      fi
      ;;
    java-maven|java-gradle)
      if [[ -f "checkstyle.xml" ]] || [[ -f "spotbugs-exclude.xml" ]]; then
        has_linter=true
      fi
      # Check pom.xml for checkstyle plugin
      if [[ -f "pom.xml" ]] && grep -q "checkstyle" pom.xml 2>/dev/null; then
        has_linter=true
      fi
      ;;
  esac

  if [[ "$has_linter" == "false" ]] && [[ "$project_type" != "unknown" ]]; then
    add_finding "quality" "$SEVERITY_MUST" "No linter configuration found"
    ((score -= 3))
  fi

  # Check for strict linting rules (SHOULD)
  case "$project_type" in
    typescript|javascript)
      if [[ -f ".eslintrc.json" ]]; then
        if ! grep -q '"error"' .eslintrc.json 2>/dev/null; then
          add_finding "quality" "$SEVERITY_SHOULD" "ESLint config may not have strict rules (no 'error' level)" ".eslintrc.json"
          ((score -= 1))
        fi
      fi
      ;;
    rust)
      if ! grep -qE "deny|forbid" Cargo.toml 2>/dev/null && ! grep -qE "#!\[deny|#!\[forbid" "$(find . -name 'lib.rs' -o -name 'main.rs' | head -1)" 2>/dev/null; then
        add_finding "quality" "$SEVERITY_SHOULD" "Consider using #![deny(warnings)] or [lints] section for stricter checking"
        ((score -= 1))
      fi
      ;;
  esac

  # Check for pre-commit hooks (SHOULD)
  if [[ ! -f ".pre-commit-config.yaml" ]] && [[ ! -f ".husky/pre-commit" ]] && [[ ! -d ".git/hooks" || ! -f ".git/hooks/pre-commit" ]]; then
    add_finding "quality" "$SEVERITY_SHOULD" "No pre-commit hooks configured"
    ((score -= 1))
  fi

  # Check for type checking in JS/TS projects (SHOULD)
  if [[ "$project_type" == "javascript" ]]; then
    if [[ ! -f "jsconfig.json" ]] && [[ ! -f "tsconfig.json" ]]; then
      add_finding "quality" "$SEVERITY_SHOULD" "Consider adding jsconfig.json or tsconfig.json for type checking"
      ((score -= 1))
    fi
  fi

  # Check for error handling patterns (SHOULD) - sample check
  if [[ "$project_type" == "rust" ]]; then
    if grep -r "unwrap()" --include="*.rs" src/ 2>/dev/null | grep -v "test" | head -1 >/dev/null; then
      add_finding "quality" "$SEVERITY_SHOULD" "Found unwrap() calls in non-test code - consider using ? operator or expect()"
      ((score -= 1))
    fi
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "quality" "$score"
}
