---
name: test-report
description: Generate test execution report in markdown format
arguments:
  - name: output
    description: Output file path (defaults to stdout)
    required: false
---

# Generate Test Report

Create a comprehensive report of test execution results.

## Report Generation

<step name="check-state">
Verify test state exists:

```bash
if [[ ! -f ".claude/test-state.json" ]]; then
  echo "No test results found. Run /run-tests first."
  exit 1
fi
```

</step>

<step name="generate-report">
Call the runner to generate the report:

```bash
"./tests/functional/runner.sh" report --format md
```

</step>

<step name="output-report">
If output path specified, write to file:

```bash
"./tests/functional/runner.sh" report --format md > {{output}}
```

Otherwise, display in conversation.
</step>

## Report Format

### Markdown

```markdown
# Test Execution Report

**Generated:** 2024-01-20T15:30:00Z

## Summary

| Status    | Count  | Percentage |
| --------- | ------ | ---------- |
| Passed    | 48     | 90.6%      |
| Failed    | 3      | 5.7%       |
| Skipped   | 2      | 3.8%       |
| **Total** | **53** | **100%**   |

## Failed Tests

### search_empty

**Category:** search
**Description:** Search with no results returns empty message

**Expected:**

- contains: "no results"

**Actual Response:**

> Found 0 matches for query

**Failure:** Missing 'no results'

---

## Passed Tests

<details>
<summary>48 tests passed (click to expand)</summary>

- init_basic
- init_with_recall
- crud_create
- crud_read
...
</details>

## Skipped Tests

- external_api_test (tagged: slow)
- integration_full (depends_on: external_api_test)
```

## Historical Reports

Reports are saved to `tests/functional/reports/` by default:

```
tests/functional/reports/
├── 2024-01-20T15-30-00.md
└── latest.md -> 2024-01-20T15-30-00.md
```

Access historical reports:

```bash
ls tests/functional/reports/
cat tests/functional/reports/latest.md
```
