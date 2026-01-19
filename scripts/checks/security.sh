#!/usr/bin/env bash
# SDLC Check: Security
# Validates security scanning, supply chain, and security policies

check_security() {
  local score=10
  local project_type
  project_type=$(detect_project_type)

  # Check for SECURITY.md (MUST)
  if [[ ! -f "SECURITY.md" ]]; then
    add_finding "security" "$SEVERITY_MUST" "Missing SECURITY.md - document security policy and vulnerability reporting"
    ((score -= 2))
  else
    # Check SECURITY.md has required sections
    if ! grep -qi "reporting\|disclosure\|contact" SECURITY.md 2>/dev/null; then
      add_finding "security" "$SEVERITY_SHOULD" "SECURITY.md should include vulnerability reporting instructions" "SECURITY.md"
      ((score -= 1))
    fi
  fi

  # Check for vulnerability scanning configuration (MUST)
  local has_vuln_scanning=false

  case "$project_type" in
    rust)
      if [[ -f "cargo-deny.toml" ]] || [[ -f "deny.toml" ]] || [[ -f ".cargo/audit.toml" ]]; then
        has_vuln_scanning=true
      fi
      # Check CI for cargo-audit or cargo-deny
      if grep -rq "cargo-audit\|cargo-deny" .github/workflows/ 2>/dev/null; then
        has_vuln_scanning=true
      fi
      ;;
    typescript|javascript)
      # Check for npm audit in CI or scripts
      if grep -q '"audit"' package.json 2>/dev/null; then
        has_vuln_scanning=true
      fi
      if grep -rq "npm audit\|yarn audit\|pnpm audit" .github/workflows/ 2>/dev/null; then
        has_vuln_scanning=true
      fi
      ;;
    python)
      # Check for safety, bandit, or pip-audit
      if grep -rq "safety\|bandit\|pip-audit" .github/workflows/ 2>/dev/null; then
        has_vuln_scanning=true
      fi
      if [[ -f "pyproject.toml" ]] && grep -qE "\[tool\.bandit\]" pyproject.toml 2>/dev/null; then
        has_vuln_scanning=true
      fi
      ;;
    go)
      # Check for govulncheck or nancy
      if grep -rq "govulncheck\|nancy" .github/workflows/ 2>/dev/null; then
        has_vuln_scanning=true
      fi
      ;;
    java-maven|java-gradle)
      # Check for OWASP dependency-check or snyk
      if grep -rq "dependency-check\|snyk" .github/workflows/ 2>/dev/null; then
        has_vuln_scanning=true
      fi
      ;;
  esac

  # Check for common third-party scanners
  if grep -rq "snyk\|trivy\|grype\|dependabot" .github/ 2>/dev/null; then
    has_vuln_scanning=true
  fi

  if [[ "$has_vuln_scanning" == "false" ]]; then
    add_finding "security" "$SEVERITY_MUST" "No vulnerability scanning configured - add cargo-audit, npm audit, snyk, or similar"
    ((score -= 3))
  fi

  # Check for license compliance (SHOULD)
  local has_license_check=false

  if [[ -f "cargo-deny.toml" ]] && grep -q "licenses" cargo-deny.toml 2>/dev/null; then
    has_license_check=true
  fi
  if grep -rq "license-checker\|licensee\|fossa" .github/ package.json 2>/dev/null; then
    has_license_check=true
  fi

  if [[ "$has_license_check" == "false" ]]; then
    add_finding "security" "$SEVERITY_SHOULD" "Consider adding license compliance checking"
    ((score -= 1))
  fi

  # Check for secret scanning (SHOULD)
  local has_secret_scanning=false

  if [[ -f ".gitleaks.toml" ]] || [[ -f "gitleaks.toml" ]]; then
    has_secret_scanning=true
  fi
  if grep -rq "gitleaks\|trufflesecurity\|detect-secrets" .github/ 2>/dev/null; then
    has_secret_scanning=true
  fi
  # GitHub secret scanning is automatic for public repos
  if [[ -f ".github/settings.yml" ]] && grep -q "secret_scanning" .github/settings.yml 2>/dev/null; then
    has_secret_scanning=true
  fi

  if [[ "$has_secret_scanning" == "false" ]]; then
    add_finding "security" "$SEVERITY_SHOULD" "Consider adding secret scanning (gitleaks, detect-secrets)"
    ((score -= 1))
  fi

  # Check for supply chain security (SHOULD)
  local has_supply_chain=false

  # Check for signed commits config
  if [[ -f ".github/settings.yml" ]] && grep -q "require_signed_commits" .github/settings.yml 2>/dev/null; then
    has_supply_chain=true
  fi
  # Check for SLSA/provenance
  if grep -rq "slsa\|provenance\|sigstore\|cosign" .github/workflows/ 2>/dev/null; then
    has_supply_chain=true
  fi
  # Pinned actions are part of supply chain
  if [[ -f ".github/workflows/ci.yml" ]] && ! grep -E "uses:.*@(main|master|latest)" .github/workflows/ci.yml 2>/dev/null | head -1 >/dev/null; then
    has_supply_chain=true
  fi

  if [[ "$has_supply_chain" == "false" ]]; then
    add_finding "security" "$SEVERITY_SHOULD" "Consider improving supply chain security (pinned deps, signed commits, SLSA)"
    ((score -= 1))
  fi

  # Check for .env files in repo (MUST NOT)
  if find . -name ".env" -not -path "./.git/*" 2>/dev/null | head -1 | grep -q .; then
    add_finding "security" "$SEVERITY_MUST" "Found .env file in repository - secrets should not be committed"
    ((score -= 2))
  fi

  # Check .gitignore includes sensitive patterns (SHOULD)
  if [[ -f ".gitignore" ]]; then
    local missing_patterns=()
    local patterns=(".env" "*.pem" "*.key" "secrets" "credentials")

    for pattern in "${patterns[@]}"; do
      if ! grep -q "$pattern" .gitignore 2>/dev/null; then
        missing_patterns+=("$pattern")
      fi
    done

    if [[ ${#missing_patterns[@]} -gt 0 ]]; then
      add_finding "security" "$SEVERITY_SHOULD" ".gitignore missing patterns: ${missing_patterns[*]}" ".gitignore"
      ((score -= 1))
    fi
  fi

  # Check for unsafe code documentation (Rust specific) (SHOULD)
  if [[ "$project_type" == "rust" ]]; then
    if grep -r "unsafe" --include="*.rs" src/ 2>/dev/null | grep -v "SAFETY:" | head -1 >/dev/null; then
      add_finding "security" "$SEVERITY_SHOULD" "Unsafe code found without SAFETY comments - document safety invariants"
      ((score -= 1))
    fi
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "security" "$score"
}
