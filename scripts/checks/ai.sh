#!/usr/bin/env bash
# SDLC Check: AI Context Configuration
# Validates AI coding assistant configuration files

check_ai() {
  local score=10

  # Check for AI context files (SHOULD)
  local has_ai_context=false
  local ai_context_files=()

  # Claude Code
  if [[ -f "CLAUDE.md" ]] || [[ -f ".claude/CLAUDE.md" ]]; then
    has_ai_context=true
    ai_context_files+=("CLAUDE.md")
  fi

  # GitHub Copilot
  if [[ -f ".github/copilot-instructions.md" ]] || [[ -f "copilot-instructions.md" ]]; then
    has_ai_context=true
    ai_context_files+=("copilot-instructions.md")
  fi

  # OpenAI Codex
  if [[ -f "AGENTS.md" ]]; then
    has_ai_context=true
    ai_context_files+=("AGENTS.md")
  fi

  # Cursor
  if [[ -f ".cursorrules" ]] || [[ -f ".cursor/rules" ]]; then
    has_ai_context=true
    ai_context_files+=(".cursorrules")
  fi

  # Aider
  if [[ -f ".aider.conf.yml" ]] || [[ -f "aider.conf.yml" ]]; then
    has_ai_context=true
    ai_context_files+=("aider.conf")
  fi

  # Cody
  if [[ -f ".cody/cody.json" ]]; then
    has_ai_context=true
    ai_context_files+=(".cody/cody.json")
  fi

  if [[ "$has_ai_context" == "false" ]]; then
    add_finding "ai" "$SEVERITY_SHOULD" "No AI assistant context files found (CLAUDE.md, copilot-instructions.md, AGENTS.md)"
    ((score -= 3))
  fi

  # Check content quality of AI context files
  for file in "${ai_context_files[@]}"; do
    local file_path=""

    # Resolve actual file path
    case "$file" in
      "CLAUDE.md")
        [[ -f "CLAUDE.md" ]] && file_path="CLAUDE.md"
        [[ -f ".claude/CLAUDE.md" ]] && file_path=".claude/CLAUDE.md"
        ;;
      "copilot-instructions.md")
        [[ -f ".github/copilot-instructions.md" ]] && file_path=".github/copilot-instructions.md"
        [[ -f "copilot-instructions.md" ]] && file_path="copilot-instructions.md"
        ;;
      "AGENTS.md")
        file_path="AGENTS.md"
        ;;
      *)
        continue
        ;;
    esac

    if [[ -n "$file_path" ]] && [[ -f "$file_path" ]]; then
      local content
      content=$(cat "$file_path" 2>/dev/null || echo "")

      # Check file is not empty/minimal
      if [[ ${#content} -lt 200 ]]; then
        add_finding "ai" "$SEVERITY_SHOULD" "AI context file appears minimal - add more guidance" "$file_path"
        ((score -= 1))
      fi

      # Check for common required sections
      case "$file" in
        "CLAUDE.md")
          # Check for project overview
          if ! echo "$content" | grep -qiE "overview|about|description|purpose"; then
            add_finding "ai" "$SEVERITY_SHOULD" "CLAUDE.md should include project overview" "$file_path"
            ((score -= 1))
          fi

          # Check for technology stack
          if ! echo "$content" | grep -qiE "stack|technology|language|framework|dependencies"; then
            add_finding "ai" "$SEVERITY_MAY" "CLAUDE.md could describe technology stack" "$file_path"
          fi

          # Check for conventions
          if ! echo "$content" | grep -qiE "convention|style|pattern|standard"; then
            add_finding "ai" "$SEVERITY_MAY" "CLAUDE.md could include coding conventions" "$file_path"
          fi
          ;;

        "copilot-instructions.md")
          # Check for coding standards
          if ! echo "$content" | grep -qiE "standard|convention|style|pattern"; then
            add_finding "ai" "$SEVERITY_SHOULD" "copilot-instructions.md should include coding standards" "$file_path"
            ((score -= 1))
          fi
          ;;

        "AGENTS.md")
          # Check for guidelines
          if ! echo "$content" | grep -qiE "guideline|rule|instruction|must|should"; then
            add_finding "ai" "$SEVERITY_SHOULD" "AGENTS.md should include clear guidelines" "$file_path"
            ((score -= 1))
          fi
          ;;
      esac
    fi
  done

  # Check for secrets in AI context files (MUST NOT)
  for file_path in "CLAUDE.md" ".claude/CLAUDE.md" ".github/copilot-instructions.md" "AGENTS.md"; do
    if [[ -f "$file_path" ]]; then
      # Check for potential secrets
      if grep -qiE "api.key|secret|password|token.*=|credentials" "$file_path" 2>/dev/null; then
        # Exclude false positives like "don't include secrets"
        if ! grep -qiE "don't|do not|never|avoid.*secret" "$file_path" 2>/dev/null; then
          add_finding "ai" "$SEVERITY_MUST" "AI context file may contain secrets - review and remove" "$file_path"
          ((score -= 3))
        fi
      fi
    fi
  done

  # Check for Copilot setup steps (MAY for GitHub Actions integration)
  if [[ -f ".github/workflows/copilot-setup-steps.yml" ]]; then
    # Validate it's properly configured
    if ! grep -q "runs-on:" .github/workflows/copilot-setup-steps.yml 2>/dev/null; then
      add_finding "ai" "$SEVERITY_SHOULD" "copilot-setup-steps.yml appears incomplete" ".github/workflows/copilot-setup-steps.yml"
      ((score -= 1))
    fi
  else
    add_finding "ai" "$SEVERITY_MAY" "Consider adding copilot-setup-steps.yml for GitHub Copilot agent integration"
  fi

  # Check for .claude directory structure (MAY)
  if [[ -d ".claude" ]]; then
    # Good - has Claude Code plugin structure
    :
  elif [[ -f "CLAUDE.md" ]]; then
    add_finding "ai" "$SEVERITY_MAY" "Consider moving CLAUDE.md to .claude/CLAUDE.md for better organization"
  fi

  # Bonus: Check for AI-assisted development mentions in docs
  if [[ -f "CONTRIBUTING.md" ]]; then
    if grep -qiE "claude|copilot|ai.assist|codex" CONTRIBUTING.md 2>/dev/null; then
      # Project has AI development guidance - good!
      :
    else
      add_finding "ai" "$SEVERITY_MAY" "Consider documenting AI-assisted development workflow in CONTRIBUTING.md"
    fi
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "ai" "$score"
}
