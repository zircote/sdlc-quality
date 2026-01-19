#!/usr/bin/env bash
# SDLC Compliance Check - Main Entry Point
# This script orchestrates all domain-specific checks and produces compliance reports.
#
# Usage: source sdlc-check.sh && run_sdlc_checks [domains] [config_file]
#
# Environment variables:
#   SDLC_REPORT_DIR - Directory to write reports (default: .sdlc-reports)
#   SDLC_WORKING_DIR - Directory to check (default: .)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration
: "${SDLC_REPORT_DIR:=.sdlc-reports}"
: "${SDLC_WORKING_DIR:=.}"

# Severity levels
SEVERITY_MUST=3    # Critical - blocks release
SEVERITY_SHOULD=2  # Important - should fix
SEVERITY_MAY=1     # Suggestion - nice to have

# Results arrays
declare -A DOMAIN_SCORES
declare -A DOMAIN_FINDINGS
CRITICAL_COUNT=0
IMPORTANT_COUNT=0
SUGGESTION_COUNT=0
TOTAL_SCORE=0

# Source domain check modules
source "${SCRIPT_DIR}/checks/build.sh"
source "${SCRIPT_DIR}/checks/quality.sh"
source "${SCRIPT_DIR}/checks/testing.sh"
source "${SCRIPT_DIR}/checks/ci.sh"
source "${SCRIPT_DIR}/checks/security.sh"
source "${SCRIPT_DIR}/checks/docs.sh"
source "${SCRIPT_DIR}/checks/vcs.sh"
source "${SCRIPT_DIR}/checks/release.sh"
source "${SCRIPT_DIR}/checks/observability.sh"
source "${SCRIPT_DIR}/checks/ai.sh"

# Utility functions
log_info() {
  echo "::notice::$*"
}

log_warning() {
  echo "::warning::$*"
}

log_error() {
  echo "::error::$*"
}

# Add a finding to the results
# Usage: add_finding <domain> <severity> <message> [file] [line]
add_finding() {
  local domain="$1"
  local severity="$2"
  local message="$3"
  local file="${4:-}"
  local line="${5:-}"

  local finding="${severity}|${message}|${file}|${line}"

  if [[ -z "${DOMAIN_FINDINGS[$domain]:-}" ]]; then
    DOMAIN_FINDINGS[$domain]="$finding"
  else
    DOMAIN_FINDINGS[$domain]="${DOMAIN_FINDINGS[$domain]}"$'\n'"$finding"
  fi

  case "$severity" in
    "$SEVERITY_MUST")
      ((CRITICAL_COUNT++))
      log_error "[$domain] MUST: $message"
      ;;
    "$SEVERITY_SHOULD")
      ((IMPORTANT_COUNT++))
      log_warning "[$domain] SHOULD: $message"
      ;;
    "$SEVERITY_MAY")
      ((SUGGESTION_COUNT++))
      log_info "[$domain] MAY: $message"
      ;;
  esac
}

# Set domain score (0-10)
set_domain_score() {
  local domain="$1"
  local score="$2"
  DOMAIN_SCORES[$domain]=$score
}

# Detect project language/framework
detect_project_type() {
  local project_type="unknown"

  if [[ -f "Cargo.toml" ]]; then
    project_type="rust"
  elif [[ -f "package.json" ]]; then
    if [[ -f "tsconfig.json" ]]; then
      project_type="typescript"
    else
      project_type="javascript"
    fi
  elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
    project_type="python"
  elif [[ -f "go.mod" ]]; then
    project_type="go"
  elif [[ -f "pom.xml" ]]; then
    project_type="java-maven"
  elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    project_type="java-gradle"
  elif [[ -f "Gemfile" ]]; then
    project_type="ruby"
  elif [[ -f "composer.json" ]]; then
    project_type="php"
  elif [[ -f "*.csproj" ]] || [[ -f "*.sln" ]]; then
    project_type="dotnet"
  fi

  echo "$project_type"
}

# Get project name
get_project_name() {
  local name=""

  if [[ -f "package.json" ]]; then
    name=$(jq -r '.name // empty' package.json 2>/dev/null || true)
  elif [[ -f "Cargo.toml" ]]; then
    name=$(grep -m1 '^name' Cargo.toml | sed 's/.*= *"\([^"]*\)".*/\1/' 2>/dev/null || true)
  elif [[ -f "pyproject.toml" ]]; then
    name=$(grep -m1 '^name' pyproject.toml | sed 's/.*= *"\([^"]*\)".*/\1/' 2>/dev/null || true)
  fi

  if [[ -z "$name" ]]; then
    name=$(basename "$(pwd)")
  fi

  echo "$name"
}

# Parse domains input
parse_domains() {
  local input="$1"
  local domains=()

  if [[ "$input" == "all" ]]; then
    domains=(build quality testing ci security docs vcs release observability ai)
  else
    IFS=',' read -ra domains <<< "$input"
    # Trim whitespace
    domains=("${domains[@]// /}")
  fi

  echo "${domains[@]}"
}

# Calculate overall score from domain scores
calculate_overall_score() {
  local total=0
  local count=0

  for domain in "${!DOMAIN_SCORES[@]}"; do
    total=$((total + DOMAIN_SCORES[$domain]))
    ((count++))
  done

  if [[ $count -gt 0 ]]; then
    TOTAL_SCORE=$((total * 10 / count))
  else
    TOTAL_SCORE=0
  fi

  echo "$TOTAL_SCORE"
}

# Determine status based on findings
determine_status() {
  if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "fail"
  elif [[ $IMPORTANT_COUNT -gt 0 ]]; then
    echo "warn"
  else
    echo "pass"
  fi
}

# Write output files
write_outputs() {
  local score
  local status

  score=$(calculate_overall_score)
  status=$(determine_status)

  mkdir -p "$SDLC_REPORT_DIR"

  echo "$score" > "$SDLC_REPORT_DIR/score.txt"
  echo "$status" > "$SDLC_REPORT_DIR/status.txt"
  echo "$CRITICAL_COUNT" > "$SDLC_REPORT_DIR/critical-count.txt"
  echo "$IMPORTANT_COUNT" > "$SDLC_REPORT_DIR/important-count.txt"
  echo "$SUGGESTION_COUNT" > "$SDLC_REPORT_DIR/suggestion-count.txt"

  # Write domain scores
  for domain in "${!DOMAIN_SCORES[@]}"; do
    echo "${DOMAIN_SCORES[$domain]}" > "$SDLC_REPORT_DIR/${domain}-score.txt"
  done

  # Write findings
  for domain in "${!DOMAIN_FINDINGS[@]}"; do
    echo "${DOMAIN_FINDINGS[$domain]}" > "$SDLC_REPORT_DIR/${domain}-findings.txt"
  done

  # Write project metadata
  cat > "$SDLC_REPORT_DIR/metadata.json" << EOF
{
  "project_name": "$(get_project_name)",
  "project_type": "$(detect_project_type)",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "score": $score,
  "status": "$status",
  "critical_count": $CRITICAL_COUNT,
  "important_count": $IMPORTANT_COUNT,
  "suggestion_count": $SUGGESTION_COUNT,
  "domains_checked": [$(printf '"%s",' "${!DOMAIN_SCORES[@]}" | sed 's/,$//')]
}
EOF
}

# Main entry point
run_sdlc_checks() {
  local domains_input="${1:-all}"
  local config_file="${2:-}"

  # Change to working directory
  cd "$SDLC_WORKING_DIR"

  log_info "Starting SDLC compliance check"
  log_info "Project: $(get_project_name)"
  log_info "Type: $(detect_project_type)"
  log_info "Domains: $domains_input"

  # Parse domains
  local -a domains
  read -ra domains <<< "$(parse_domains "$domains_input")"

  # Load custom config if provided
  if [[ -n "$config_file" ]] && [[ -f "$config_file" ]]; then
    log_info "Loading custom configuration: $config_file"
    # shellcheck source=/dev/null
    source "$config_file"
  fi

  # Run domain checks
  for domain in "${domains[@]}"; do
    log_info "Checking domain: $domain"
    case "$domain" in
      build)
        check_build
        ;;
      quality)
        check_quality
        ;;
      testing)
        check_testing
        ;;
      ci)
        check_ci
        ;;
      security)
        check_security
        ;;
      docs)
        check_docs
        ;;
      vcs)
        check_vcs
        ;;
      release)
        check_release
        ;;
      observability)
        check_observability
        ;;
      ai)
        check_ai
        ;;
      *)
        log_warning "Unknown domain: $domain"
        ;;
    esac
  done

  # Write outputs
  write_outputs

  # Summary
  local score
  local status
  score=$(calculate_overall_score)
  status=$(determine_status)

  log_info "===================="
  log_info "SDLC Compliance Check Complete"
  log_info "Score: $score/100"
  log_info "Status: $status"
  log_info "Critical: $CRITICAL_COUNT | Important: $IMPORTANT_COUNT | Suggestions: $SUGGESTION_COUNT"
  log_info "===================="

  return 0
}

# Export functions for use by other scripts
export -f log_info log_warning log_error add_finding set_domain_score
export -f detect_project_type get_project_name
export SEVERITY_MUST SEVERITY_SHOULD SEVERITY_MAY
