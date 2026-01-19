#!/usr/bin/env bash
# SDLC Check: Documentation
# Validates documentation completeness and quality

check_docs() {
  local score=10

  # Check for README.md (MUST)
  if [[ ! -f "README.md" ]]; then
    add_finding "docs" "$SEVERITY_MUST" "Missing README.md"
    ((score -= 3))
  else
    # Check README has required sections
    local readme_content
    readme_content=$(cat README.md 2>/dev/null || echo "")

    # Project description (MUST)
    if [[ ${#readme_content} -lt 100 ]]; then
      add_finding "docs" "$SEVERITY_MUST" "README.md appears too short - add project description" "README.md"
      ((score -= 1))
    fi

    # Installation instructions (MUST)
    if ! echo "$readme_content" | grep -qiE "install|getting started|setup|quick start"; then
      add_finding "docs" "$SEVERITY_MUST" "README.md missing installation/setup instructions" "README.md"
      ((score -= 1))
    fi

    # Usage section (MUST)
    if ! echo "$readme_content" | grep -qiE "usage|example|how to"; then
      add_finding "docs" "$SEVERITY_SHOULD" "README.md missing usage examples" "README.md"
      ((score -= 1))
    fi

    # License section or badge (SHOULD)
    if ! echo "$readme_content" | grep -qiE "license|MIT|Apache|GPL|BSD"; then
      add_finding "docs" "$SEVERITY_SHOULD" "README.md missing license information" "README.md"
      ((score -= 1))
    fi

    # Contributing mention (MAY)
    if ! echo "$readme_content" | grep -qiE "contribut|CONTRIBUTING"; then
      add_finding "docs" "$SEVERITY_MAY" "README.md could link to CONTRIBUTING.md"
    fi
  fi

  # Check for CONTRIBUTING.md (MUST for open source)
  if [[ ! -f "CONTRIBUTING.md" ]]; then
    add_finding "docs" "$SEVERITY_MUST" "Missing CONTRIBUTING.md"
    ((score -= 2))
  else
    local contrib_content
    contrib_content=$(cat CONTRIBUTING.md 2>/dev/null || echo "")

    # Check for development setup instructions
    if ! echo "$contrib_content" | grep -qiE "development|setup|build|install"; then
      add_finding "docs" "$SEVERITY_SHOULD" "CONTRIBUTING.md should include development setup" "CONTRIBUTING.md"
      ((score -= 1))
    fi

    # Check for PR/commit guidelines
    if ! echo "$contrib_content" | grep -qiE "pull request|commit|PR"; then
      add_finding "docs" "$SEVERITY_SHOULD" "CONTRIBUTING.md should include PR/commit guidelines" "CONTRIBUTING.md"
      ((score -= 1))
    fi
  fi

  # Check for CHANGELOG.md (MUST)
  if [[ ! -f "CHANGELOG.md" ]]; then
    add_finding "docs" "$SEVERITY_MUST" "Missing CHANGELOG.md"
    ((score -= 2))
  else
    local changelog_content
    changelog_content=$(cat CHANGELOG.md 2>/dev/null || echo "")

    # Check for Keep a Changelog format
    if ! echo "$changelog_content" | grep -qiE "unreleased|added|changed|deprecated|removed|fixed|security"; then
      add_finding "docs" "$SEVERITY_SHOULD" "CHANGELOG.md should follow Keep a Changelog format" "CHANGELOG.md"
      ((score -= 1))
    fi

    # Check for version entries
    if ! echo "$changelog_content" | grep -qE "\[[0-9]+\.[0-9]+\.[0-9]+\]|\[v?[0-9]+\.[0-9]+"; then
      add_finding "docs" "$SEVERITY_SHOULD" "CHANGELOG.md should include version entries" "CHANGELOG.md"
      ((score -= 1))
    fi
  fi

  # Check for LICENSE (MUST)
  if [[ ! -f "LICENSE" ]] && [[ ! -f "LICENSE.md" ]] && [[ ! -f "LICENSE.txt" ]]; then
    add_finding "docs" "$SEVERITY_MUST" "Missing LICENSE file"
    ((score -= 2))
  fi

  # Check for ADR directory (SHOULD)
  if [[ ! -d "docs/adrs" ]] && [[ ! -d "docs/adr" ]] && [[ ! -d "adr" ]] && [[ ! -d "adrs" ]]; then
    add_finding "docs" "$SEVERITY_SHOULD" "Consider adding ADR (Architecture Decision Records) directory"
    ((score -= 1))
  else
    # Check ADR directory has content
    local adr_dir
    for dir in "docs/adrs" "docs/adr" "adr" "adrs"; do
      if [[ -d "$dir" ]]; then
        adr_dir="$dir"
        break
      fi
    done

    if [[ -n "$adr_dir" ]]; then
      local adr_count
      adr_count=$(find "$adr_dir" -name "*.md" 2>/dev/null | wc -l)
      if [[ $adr_count -lt 2 ]]; then
        add_finding "docs" "$SEVERITY_MAY" "ADR directory has few entries - document architectural decisions"
      fi
    fi
  fi

  # Check for API documentation (SHOULD for libraries)
  local project_type
  project_type=$(detect_project_type)

  case "$project_type" in
    rust)
      # Rust generates docs from code comments
      if ! grep -r "//!" --include="*.rs" src/ 2>/dev/null | head -1 >/dev/null; then
        add_finding "docs" "$SEVERITY_SHOULD" "Consider adding module-level documentation (//! comments)"
        ((score -= 1))
      fi
      ;;
    typescript|javascript)
      # Check for JSDoc or TypeDoc
      if [[ ! -f "typedoc.json" ]] && ! grep -q "jsdoc" package.json 2>/dev/null; then
        add_finding "docs" "$SEVERITY_MAY" "Consider adding TypeDoc/JSDoc for API documentation"
      fi
      ;;
    python)
      # Check for docstrings or sphinx
      if [[ ! -f "docs/conf.py" ]] && [[ ! -d "docs/_build" ]]; then
        add_finding "docs" "$SEVERITY_MAY" "Consider adding Sphinx documentation"
      fi
      ;;
  esac

  # Check for docs/ directory (MAY)
  if [[ ! -d "docs" ]]; then
    add_finding "docs" "$SEVERITY_MAY" "Consider adding docs/ directory for detailed documentation"
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "docs" "$score"
}
