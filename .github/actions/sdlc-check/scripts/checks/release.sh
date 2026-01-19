#!/usr/bin/env bash
# SDLC Check: Release Management
# Validates release processes and versioning

check_release() {
  local score=10
  local project_type
  project_type=$(detect_project_type)

  # Check for version in manifest (MUST)
  local has_version=false
  local version=""

  case "$project_type" in
    rust)
      if [[ -f "Cargo.toml" ]]; then
        version=$(grep -m1 '^version' Cargo.toml | sed 's/.*= *"\([^"]*\)".*/\1/' 2>/dev/null || true)
        [[ -n "$version" ]] && has_version=true
      fi
      ;;
    typescript|javascript)
      if [[ -f "package.json" ]]; then
        version=$(jq -r '.version // empty' package.json 2>/dev/null || true)
        [[ -n "$version" ]] && has_version=true
      fi
      ;;
    python)
      if [[ -f "pyproject.toml" ]]; then
        version=$(grep -m1 '^version' pyproject.toml | sed 's/.*= *"\([^"]*\)".*/\1/' 2>/dev/null || true)
        [[ -n "$version" ]] && has_version=true
      fi
      ;;
    go)
      # Go uses git tags for versioning
      if git describe --tags --abbrev=0 2>/dev/null | grep -q "v"; then
        has_version=true
        version=$(git describe --tags --abbrev=0 2>/dev/null || true)
      fi
      ;;
    java-maven)
      if [[ -f "pom.xml" ]]; then
        version=$(grep -m1 '<version>' pom.xml | sed 's/.*<version>\([^<]*\)<.*/\1/' 2>/dev/null || true)
        [[ -n "$version" ]] && has_version=true
      fi
      ;;
    java-gradle)
      if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        version=$(grep -m1 "version" build.gradle* | sed "s/.*['\"]\\([^'\"]*\\)['\"].*/\\1/" 2>/dev/null || true)
        [[ -n "$version" ]] && has_version=true
      fi
      ;;
  esac

  if [[ "$has_version" == "false" ]]; then
    add_finding "release" "$SEVERITY_MUST" "No version found in project manifest"
    ((score -= 3))
  fi

  # Check for semantic versioning (MUST)
  if [[ -n "$version" ]]; then
    if ! echo "$version" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$"; then
      add_finding "release" "$SEVERITY_MUST" "Version '$version' doesn't follow Semantic Versioning format"
      ((score -= 2))
    fi
  fi

  # Check for release workflow (SHOULD)
  local has_release_workflow=false

  if [[ -f ".github/workflows/release.yml" ]] || [[ -f ".github/workflows/release.yaml" ]]; then
    has_release_workflow=true
  fi

  # Check for release-please or semantic-release
  if grep -rq "release-please\|semantic-release\|changesets" .github/ 2>/dev/null; then
    has_release_workflow=true
  fi

  if [[ "$has_release_workflow" == "false" ]]; then
    add_finding "release" "$SEVERITY_SHOULD" "No automated release workflow found"
    ((score -= 2))
  fi

  # Check for tag-based releases (SHOULD)
  local tag_count
  tag_count=$(git tag -l 2>/dev/null | wc -l || echo "0")

  if [[ $tag_count -eq 0 ]]; then
    add_finding "release" "$SEVERITY_SHOULD" "No git tags found - use tags for release versioning"
    ((score -= 1))
  fi

  # Check CHANGELOG is updated (SHOULD)
  if [[ -f "CHANGELOG.md" ]]; then
    # Check if there's an unreleased section or recent version
    if ! grep -qiE "unreleased|\[${version}\]" CHANGELOG.md 2>/dev/null; then
      add_finding "release" "$SEVERITY_SHOULD" "CHANGELOG.md may not be up to date with current version" "CHANGELOG.md"
      ((score -= 1))
    fi
  fi

  # Check for release artifacts configuration (SHOULD for binaries)
  case "$project_type" in
    rust)
      if [[ -f ".github/workflows/release.yml" ]]; then
        if ! grep -q "cargo-dist\|cross\|target/release" .github/workflows/release.yml 2>/dev/null; then
          add_finding "release" "$SEVERITY_SHOULD" "Consider adding cross-platform binary release"
          ((score -= 1))
        fi
      fi
      ;;
    go)
      if [[ -f ".github/workflows/release.yml" ]]; then
        if ! grep -q "goreleaser\|GOOS\|GOARCH" .github/workflows/release.yml 2>/dev/null; then
          add_finding "release" "$SEVERITY_SHOULD" "Consider using goreleaser for cross-platform releases"
          ((score -= 1))
        fi
      fi
      ;;
  esac

  # Check for checksums/signatures (SHOULD for published artifacts)
  if [[ -f ".github/workflows/release.yml" ]]; then
    if ! grep -qE "sha256sum|checksums|cosign|gpg" .github/workflows/release.yml 2>/dev/null; then
      add_finding "release" "$SEVERITY_SHOULD" "Consider adding checksums/signatures for release artifacts"
      ((score -= 1))
    fi
  fi

  # Check for release notes automation (MAY)
  if [[ -f ".github/workflows/release.yml" ]]; then
    if ! grep -qE "generate.*notes|release.notes|changelog" .github/workflows/release.yml 2>/dev/null; then
      add_finding "release" "$SEVERITY_MAY" "Consider automating release notes generation"
    fi
  fi

  # Check for multi-channel distribution (MAY)
  case "$project_type" in
    rust)
      # Check for crates.io publishing
      if [[ -f "Cargo.toml" ]] && ! grep -q "publish = false" Cargo.toml 2>/dev/null; then
        if ! grep -rq "cargo publish\|crates.io" .github/workflows/ 2>/dev/null; then
          add_finding "release" "$SEVERITY_MAY" "Consider publishing to crates.io"
        fi
      fi
      ;;
    typescript|javascript)
      # Check for npm publishing
      if [[ -f "package.json" ]] && ! jq -e '.private == true' package.json >/dev/null 2>&1; then
        if ! grep -rq "npm publish" .github/workflows/ 2>/dev/null; then
          add_finding "release" "$SEVERITY_MAY" "Consider publishing to npm registry"
        fi
      fi
      ;;
    python)
      # Check for PyPI publishing
      if [[ -f "pyproject.toml" ]]; then
        if ! grep -rq "twine\|pypi" .github/workflows/ 2>/dev/null; then
          add_finding "release" "$SEVERITY_MAY" "Consider publishing to PyPI"
        fi
      fi
      ;;
  esac

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "release" "$score"
}
