---
name: Testing Standards
description: This skill should be used when the user asks about "testing", "test coverage", "unit tests", "integration tests", "test organization", "test best practices", "flaky tests", "test isolation", "TDD", "regression tests", or needs guidance on test structure, coverage requirements, and test execution.
version: 1.0.0
---

# Testing Standards

Guidance for implementing comprehensive testing that meets SDLC requirements.

## Tooling

> **Available Tools**: If using Claude Code, the `pr-review-toolkit:pr-test-analyzer` agent reviews test coverage and identifies gaps. Use after creating PRs to ensure adequate test coverage.

## Test Organization

### Required Test Categories (MUST)

Projects MUST maintain these test categories:

| Category | Location | Purpose |
|----------|----------|---------|
| Unit tests | Alongside source code | Test individual functions/methods |
| Integration tests | Dedicated test directory | Test component interactions |
| Documentation tests | Within doc comments | Verify examples work |
| End-to-end tests | Dedicated e2e directory | Test full system behavior |

### Naming Convention (MUST)

Test files MUST be clearly identifiable by naming convention:

| Language | Unit Tests | Integration Tests |
|----------|------------|-------------------|
| Rust | `mod tests` in source | `tests/` directory |
| TypeScript | `*.test.ts`, `*.spec.ts` | `tests/integration/` |
| Python | `test_*.py`, `*_test.py` | `tests/integration/` |
| Java | `*Test.java` | `*IntegrationTest.java` |
| Go | `*_test.go` | `*_integration_test.go` |

## Test Coverage

### Coverage Requirements

| Requirement | Level |
|-------------|-------|
| New functionality | MUST include tests |
| Bug fixes | MUST include regression tests |
| Coverage measurement | MUST be tracked |
| Minimum coverage | SHOULD target 80% |
| Critical paths | MUST have 95%+ coverage |
| Coverage reports | MUST be uploaded to tracking service |

### Regression Tests (MUST)

Bug fixes MUST include regression tests that:
1. Fail before the fix is applied
2. Pass after the fix is applied
3. Document the bug being fixed

```rust
#[test]
fn test_issue_123_null_pointer_on_empty_input() {
    // Regression test for issue #123
    // Previously caused null pointer when input was empty
    let result = process_input("");
    assert!(result.is_ok());
}
```

### Critical Path Coverage (MUST)

Critical paths requiring 95%+ coverage:
- Authentication and authorization
- Data validation and sanitization
- Financial calculations
- Security-sensitive operations
- Data persistence operations

## Test Execution

### Pre-Merge Requirements (MUST)

1. All tests MUST pass before code can be merged
2. Tests MUST be deterministic (no flaky tests)
3. Tests MUST be isolated (no shared state between tests)
4. Tests MUST run on all supported platforms in CI

### Performance Guidelines (SHOULD)

| Test Type | Target Duration |
|-----------|-----------------|
| Unit tests | < 1 second each |
| Integration tests | < 30 seconds each |
| Full test suite | < 10 minutes |

### Flaky Test Policy

Flaky tests (tests that sometimes pass, sometimes fail) MUST be:
1. Identified and tracked
2. Fixed or quarantined immediately
3. Never ignored or re-run until green

## Test Best Practices

### Arrange-Act-Assert Pattern (MUST)

Tests MUST follow the AAA pattern:

```typescript
test('should calculate total with discount', () => {
  // Arrange
  const cart = new ShoppingCart();
  cart.addItem({ price: 100, quantity: 2 });
  const discount = 0.1;

  // Act
  const total = cart.calculateTotal(discount);

  // Assert
  expect(total).toBe(180);
});
```

### Test Naming (MUST)

Test names MUST clearly describe what is being tested:

**Good:**
```
test_user_creation_with_valid_email_succeeds
test_login_with_invalid_password_returns_401
test_empty_cart_returns_zero_total
```

**Bad:**
```
test1
testUser
test_it_works
```

### Coverage Requirements (MUST)

Tests MUST cover:
- **Happy path**: Expected inputs produce expected outputs
- **Error cases**: Invalid inputs produce appropriate errors
- **Edge cases**: Boundary conditions handled correctly

### Edge Cases to Test

| Category | Examples |
|----------|----------|
| Empty inputs | Empty strings, empty arrays, null/None |
| Boundary values | 0, -1, MAX_INT, empty, single item |
| Invalid inputs | Wrong types, malformed data |
| Concurrent access | Race conditions, deadlocks |
| Resource limits | Large inputs, memory constraints |

## Implementation Checklist

- [ ] Organize tests by category (unit, integration, e2e)
- [ ] Follow naming conventions for test files
- [ ] Set up coverage measurement
- [ ] Configure coverage reporting in CI
- [ ] Ensure all tests are deterministic
- [ ] Verify test isolation
- [ ] Add regression tests for bug fixes
- [ ] Cover critical paths with 95%+ coverage

## Compliance Verification

```bash
# Run all tests
make test

# Check coverage
make coverage

# Verify no flaky tests (run multiple times)
for i in {1..5}; do make test || exit 1; done

# Check critical path coverage (language-specific)
coverage report --include="src/auth/*,src/security/*" --fail-under=95
```

## Additional Resources

### Reference Files

- **`references/test-patterns.md`** - Common test patterns and anti-patterns
- **`references/coverage-config.md`** - Coverage tool configuration

### Examples

- **`examples/rust-test-setup.md`** - Rust test organization
- **`examples/typescript-jest.config.js`** - Jest configuration
- **`examples/python-pytest.ini`** - Pytest configuration
