#!/usr/bin/env bash
# SDLC Check: Testing
# Validates test organization, coverage, and testing practices

check_testing() {
  local score=10
  local project_type
  project_type=$(detect_project_type)

  # Check for test directory/files (MUST)
  local has_tests=false

  if [[ -d "tests" ]] || [[ -d "test" ]] || [[ -d "__tests__" ]] || [[ -d "spec" ]]; then
    has_tests=true
  fi

  # Check for inline tests (Rust)
  if [[ "$project_type" == "rust" ]]; then
    if grep -r "#\[test\]" --include="*.rs" . 2>/dev/null | head -1 >/dev/null; then
      has_tests=true
    fi
  fi

  # Check for test files by pattern
  if find . -name "*_test.go" -o -name "test_*.py" -o -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null | head -1 | grep -q .; then
    has_tests=true
  fi

  if [[ "$has_tests" == "false" ]]; then
    add_finding "testing" "$SEVERITY_MUST" "No test files or test directory found"
    ((score -= 4))
  fi

  # Check for test coverage configuration (MUST)
  local has_coverage_config=false

  case "$project_type" in
    rust)
      # Check for cargo-tarpaulin or llvm-cov config
      if [[ -f ".cargo/config.toml" ]] && grep -q "coverage" .cargo/config.toml 2>/dev/null; then
        has_coverage_config=true
      fi
      if [[ -f "codecov.yml" ]] || [[ -f ".codecov.yml" ]]; then
        has_coverage_config=true
      fi
      ;;
    typescript|javascript)
      # Check package.json for coverage config
      if jq -e '.jest.collectCoverage' package.json >/dev/null 2>&1; then
        has_coverage_config=true
      fi
      if jq -e '.c8 or .nyc' package.json >/dev/null 2>&1; then
        has_coverage_config=true
      fi
      if [[ -f "jest.config.js" ]] || [[ -f "jest.config.ts" ]] || [[ -f "vitest.config.ts" ]] || [[ -f "vitest.config.js" ]]; then
        has_coverage_config=true
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]] && grep -qE "\[tool\.(coverage|pytest)\]" pyproject.toml 2>/dev/null; then
        has_coverage_config=true
      fi
      if [[ -f ".coveragerc" ]] || [[ -f "coverage.xml" ]]; then
        has_coverage_config=true
      fi
      ;;
    go)
      # Go has built-in coverage, check for coverage in CI
      if [[ -f ".github/workflows/ci.yml" ]] && grep -q "coverage" .github/workflows/ci.yml 2>/dev/null; then
        has_coverage_config=true
      fi
      ;;
  esac

  # Check for codecov/coveralls config
  if [[ -f "codecov.yml" ]] || [[ -f ".codecov.yml" ]] || [[ -f ".coveralls.yml" ]]; then
    has_coverage_config=true
  fi

  if [[ "$has_coverage_config" == "false" ]] && [[ "$has_tests" == "true" ]]; then
    add_finding "testing" "$SEVERITY_MUST" "No test coverage configuration found"
    ((score -= 2))
  fi

  # Check for coverage threshold (SHOULD)
  local has_coverage_threshold=false

  case "$project_type" in
    typescript|javascript)
      if [[ -f "jest.config.js" ]] && grep -q "coverageThreshold" jest.config.js 2>/dev/null; then
        has_coverage_threshold=true
      fi
      if jq -e '.jest.coverageThreshold' package.json >/dev/null 2>&1; then
        has_coverage_threshold=true
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]] && grep -q "fail_under" pyproject.toml 2>/dev/null; then
        has_coverage_threshold=true
      fi
      ;;
  esac

  if [[ "$has_coverage_threshold" == "false" ]] && [[ "$has_coverage_config" == "true" ]]; then
    add_finding "testing" "$SEVERITY_SHOULD" "No coverage threshold configured (recommend 80% general, 95% critical paths)"
    ((score -= 1))
  fi

  # Check for test organization (SHOULD)
  case "$project_type" in
    rust)
      # Check for integration tests
      if [[ ! -d "tests" ]] && [[ "$has_tests" == "true" ]]; then
        add_finding "testing" "$SEVERITY_SHOULD" "Consider adding integration tests in tests/ directory"
        ((score -= 1))
      fi
      ;;
    typescript|javascript)
      # Check for test file co-location or separate directory
      local test_files
      test_files=$(find . -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null | wc -l)
      if [[ $test_files -eq 0 ]] && [[ ! -d "__tests__" ]] && [[ ! -d "test" ]]; then
        add_finding "testing" "$SEVERITY_SHOULD" "Organize tests: co-locate with source or use __tests__ directory"
        ((score -= 1))
      fi
      ;;
  esac

  # Check for test utilities/fixtures (MAY)
  if [[ ! -d "tests/fixtures" ]] && [[ ! -d "test/fixtures" ]] && [[ ! -d "__tests__/fixtures" ]]; then
    add_finding "testing" "$SEVERITY_MAY" "Consider adding test fixtures directory for test data"
  fi

  # Check for deterministic tests - look for timing issues (MAY)
  if grep -r "setTimeout\|sleep\|time.sleep" --include="*.test.*" --include="*_test.*" . 2>/dev/null | head -1 >/dev/null; then
    add_finding "testing" "$SEVERITY_MAY" "Found potential timing-dependent tests - consider using fake timers"
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "testing" "$score"
}
