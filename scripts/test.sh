#!/usr/bin/env bash
set -euo pipefail

echo "=== SDLC Plugin Tests ==="

# Test 1: Verify plugin.json exists and is valid JSON
echo -n "Checking plugin.json... "
if [ -f ".claude-plugin/plugin.json" ]; then
    if jq empty .claude-plugin/plugin.json 2>/dev/null; then
        echo "OK"
    else
        echo "FAIL (invalid JSON)"
        exit 1
    fi
else
    echo "FAIL (not found)"
    exit 1
fi

# Test 2: Verify all skills have SKILL.md
echo -n "Checking skills... "
skill_count=0
for dir in skills/*/; do
    if [ -f "${dir}SKILL.md" ]; then
        skill_count=$((skill_count + 1))
    else
        echo "FAIL (missing ${dir}SKILL.md)"
        exit 1
    fi
done
echo "OK ($skill_count skills found)"

# Test 3: Verify all agents have markdown files
echo -n "Checking agents... "
agent_count=$(find agents -name "*.md" | wc -l | tr -d ' ')
if [ "$agent_count" -gt 0 ]; then
    echo "OK ($agent_count agents found)"
else
    echo "WARN (no agents found)"
fi

# Test 4: Verify all commands have markdown files
echo -n "Checking commands... "
cmd_count=$(find commands -name "*.md" | wc -l | tr -d ' ')
if [ "$cmd_count" -gt 0 ]; then
    echo "OK ($cmd_count commands found)"
else
    echo "WARN (no commands found)"
fi

# Test 5: Verify required documentation exists
echo -n "Checking documentation... "
required_docs=("README.md" "LICENSE" "CONTRIBUTING.md" "CHANGELOG.md" "SECURITY.md")
for doc in "${required_docs[@]}"; do
    if [ ! -f "$doc" ]; then
        echo "FAIL (missing $doc)"
        exit 1
    fi
done
echo "OK (all required docs present)"

# Test 6: Verify PROJECT_REQUIREMENTS.md exists
echo -n "Checking PROJECT_REQUIREMENTS.md... "
if [ -f "docs/PROJECT_REQUIREMENTS.md" ]; then
    echo "OK"
else
    echo "FAIL (not found)"
    exit 1
fi

# Test 7: Check for broken internal links (basic)
echo -n "Checking for broken links... "
# This is a basic check - a real implementation would be more thorough
broken_links=0
if grep -r "\[.*\](.*\.md)" --include="*.md" . | grep -v node_modules | grep -v ".git" > /tmp/links.txt 2>/dev/null; then
    while IFS= read -r line; do
        file=$(echo "$line" | cut -d: -f1)
        link=$(echo "$line" | grep -oP '\(([^)]+\.md)\)' | tr -d '()' | head -1)
        if [ -n "$link" ] && [[ ! "$link" == *"http"* ]]; then
            dir=$(dirname "$file")
            target="$dir/$link"
            if [ ! -f "$target" ] && [ ! -f "$link" ]; then
                # Check if it's a root-relative link
                if [ ! -f "./$link" ]; then
                    broken_links=$((broken_links + 1))
                fi
            fi
        fi
    done < /tmp/links.txt
fi
if [ "$broken_links" -gt 0 ]; then
    echo "WARN ($broken_links potential broken links)"
else
    echo "OK"
fi

echo ""
echo "=== All tests passed ==="
