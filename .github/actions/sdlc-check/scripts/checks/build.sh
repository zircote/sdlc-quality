#!/usr/bin/env bash
# SDLC Check: Build System
# Validates build system configuration and standard targets

check_build() {
  local score=10
  local has_makefile=false
  local has_justfile=false

  # Check for unified entry point (MUST)
  if [[ -f "Makefile" ]]; then
    has_makefile=true
  elif [[ -f "justfile" ]] || [[ -f "Justfile" ]]; then
    has_justfile=true
  fi

  if [[ "$has_makefile" == "false" ]] && [[ "$has_justfile" == "false" ]]; then
    add_finding "build" "$SEVERITY_MUST" "Missing unified build entry point (Makefile or justfile)"
    ((score -= 4))
  fi

  # Check standard targets (MUST)
  if [[ "$has_makefile" == "true" ]]; then
    local required_targets=("build" "test" "lint" "format" "clean")
    for target in "${required_targets[@]}"; do
      if ! grep -qE "^${target}:" Makefile 2>/dev/null; then
        add_finding "build" "$SEVERITY_MUST" "Makefile missing required target: $target" "Makefile"
        ((score -= 1))
      fi
    done

    # Check for ci target (SHOULD)
    if ! grep -qE "^ci:" Makefile 2>/dev/null; then
      add_finding "build" "$SEVERITY_SHOULD" "Makefile missing 'ci' target for CI orchestration" "Makefile"
      ((score -= 1))
    fi
  fi

  # Check dependency lock files (MUST)
  local has_lockfile=false
  local lockfiles=("Cargo.lock" "package-lock.json" "yarn.lock" "pnpm-lock.yaml" "poetry.lock" "Pipfile.lock" "go.sum" "Gemfile.lock" "composer.lock")

  for lockfile in "${lockfiles[@]}"; do
    if [[ -f "$lockfile" ]]; then
      has_lockfile=true
      break
    fi
  done

  if [[ "$has_lockfile" == "false" ]]; then
    # Only flag if there's a package manager file
    if [[ -f "package.json" ]] || [[ -f "Cargo.toml" ]] || [[ -f "pyproject.toml" ]] || [[ -f "go.mod" ]]; then
      add_finding "build" "$SEVERITY_MUST" "Missing dependency lock file for reproducible builds"
      ((score -= 2))
    fi
  fi

  # Check for MSV (Minimum Supported Version) documentation (SHOULD)
  local project_type
  project_type=$(detect_project_type)

  case "$project_type" in
    rust)
      if ! grep -q "rust-version" Cargo.toml 2>/dev/null; then
        add_finding "build" "$SEVERITY_SHOULD" "Missing rust-version (MSRV) in Cargo.toml" "Cargo.toml"
        ((score -= 1))
      fi
      ;;
    typescript|javascript)
      if ! jq -e '.engines.node' package.json >/dev/null 2>&1; then
        add_finding "build" "$SEVERITY_SHOULD" "Missing engines.node (minimum Node version) in package.json" "package.json"
        ((score -= 1))
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]]; then
        if ! grep -q "requires-python" pyproject.toml 2>/dev/null; then
          add_finding "build" "$SEVERITY_SHOULD" "Missing requires-python in pyproject.toml" "pyproject.toml"
          ((score -= 1))
        fi
      fi
      ;;
  esac

  # Check build works (if possible)
  if [[ "$has_makefile" == "true" ]]; then
    if ! make -n build >/dev/null 2>&1; then
      add_finding "build" "$SEVERITY_MAY" "'make build' target may have issues (dry-run failed)" "Makefile"
    fi
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "build" "$score"
}
