---
name: Code Quality Standards
description: This skill should be used when the user asks about "code quality", "formatting", "linting", "lint rules", "code style", "error handling", "unsafe code", "documentation comments", "doc comments", "rustfmt", "prettier", "eslint", "clippy", or needs guidance on code quality enforcement and configuration.
version: 1.0.0
---

# Code Quality Standards

Guidance for implementing code quality requirements including formatting, linting, error handling, and documentation.

## Tooling

> **Available Tools**: If using Claude Code, the `pr-review-toolkit:code-reviewer` agent can assess code quality against these standards. Use `/pr-review-toolkit:review-pr` for comprehensive PR review.

## Formatting Requirements

### Automated Formatting (MUST)

1. All source code MUST pass automated formatting checks before merge
2. Projects MUST define and commit formatting configuration files
3. Import/include statements MUST be automatically sorted and grouped

### Formatting Standards (MUST)

| Standard | Requirement |
|----------|-------------|
| Line length | MUST be 100 characters maximum |
| Indentation | MUST be consistent (spaces or tabs, not mixed) |
| Line endings | MUST be Unix-style (LF) |
| Trailing whitespace | MUST be removed |
| Final newline | MUST be present |

### Formatter Configuration by Language

| Language | Tool | Config File |
|----------|------|-------------|
| Rust | rustfmt | `rustfmt.toml` |
| TypeScript/JS | Prettier | `.prettierrc` |
| Python | Black/Ruff | `pyproject.toml` |
| Java | google-java-format | `.editorconfig` |
| Go | gofmt | (built-in) |

## Linting Requirements

### Static Analysis (MUST)

1. Projects MUST use static analysis tools appropriate to the language
2. CI pipelines MUST run linting with warnings treated as errors
3. Lint rule exceptions MUST be documented with justification

### Lint Categories

| Category | Enforcement |
|----------|-------------|
| Correctness | MUST be enabled |
| Performance | MUST be enabled |
| Style | SHOULD be enabled |
| Complexity | SHOULD be enabled |
| Documentation | SHOULD be enabled |
| Pedantic | SHOULD be enabled |
| Nursery/Experimental | MAY be enabled |

### Linter Configuration by Language

| Language | Tool | Config File |
|----------|------|-------------|
| Rust | Clippy | `clippy.toml`, `Cargo.toml` |
| TypeScript | ESLint | `eslint.config.js` |
| Python | Ruff | `pyproject.toml` |
| Java | SpotBugs, PMD | `spotbugs.xml`, `pmd.xml` |
| Go | golangci-lint | `.golangci.yml` |

### Documenting Lint Exceptions

When disabling a lint rule, document the justification:

```rust
// Rust
#[allow(clippy::too_many_arguments)]
// Justification: This function wraps an external API that requires these parameters
fn external_api_wrapper(...) {}
```

```typescript
// TypeScript
// eslint-disable-next-line @typescript-eslint/no-explicit-any
// Justification: Third-party library returns untyped data
const data: any = externalLib.getData();
```

## Error Handling Requirements

### Library Code (MUST NOT)

Library code MUST NOT:
- Panic, abort, or terminate the process unexpectedly
- Use unchecked unwrapping of optional/nullable values
- Use unchecked type assertions/casts
- Leave exceptions unhandled
- Call process exit functions

### Structured Error Handling (MUST)

All error conditions MUST be handled via structured error types or result types:

| Language | Pattern |
|----------|---------|
| Rust | `Result<T, E>`, `Option<T>` |
| TypeScript | `Result` type, explicit error returns |
| Python | Custom exceptions, explicit raises |
| Java | Checked exceptions, `Optional<T>` |
| Go | Multiple return values `(T, error)` |

### Exceptions for Test/CLI Code

Test code and CLI entry points MAY use simplified error handling where appropriate (e.g., `.unwrap()` in tests, `panic!` at CLI boundaries).

## Unsafe Code Requirements

### Minimization (MUST)

Unsafe code blocks MUST be minimized.

### Documentation (MUST)

All unsafe code MUST be:
1. Documented with safety invariants
2. Encapsulated in safe abstractions
3. Reviewed by at least one additional maintainer

### Compiler Warnings (MUST)

Projects MUST enable compiler/linter warnings for unsafe code usage:

```rust
// Rust - in Cargo.toml or lib.rs
#![warn(unsafe_code)]
```

## Documentation Comments

### Public API Documentation (MUST)

All public APIs MUST have documentation comments including:
- Brief description of purpose
- Parameter descriptions
- Return value descriptions
- Error conditions (what errors can occur and when)

### Recommended Documentation

Documentation SHOULD include:
- Usage examples (preferably as tested code)
- References to related APIs
- Notes on thread safety or concurrency

### Documentation Validation (MUST)

Documentation MUST be validated as part of CI:
- No broken links
- Valid examples (doc tests where supported)

## Implementation Checklist

- [ ] Configure formatter with config file committed
- [ ] Set up linter with strict rules
- [ ] Enable all MUST lint categories
- [ ] Configure unsafe code warnings
- [ ] Establish error handling patterns
- [ ] Document all public APIs
- [ ] Add CI checks for formatting and linting

## Compliance Verification

```bash
# Verify formatting passes
make format-check

# Verify linting passes (strict)
make lint-strict

# Check for unsafe code (Rust example)
grep -r "unsafe" src/ --include="*.rs"

# Verify doc coverage (language-specific)
cargo doc --no-deps  # Rust
```

## Additional Resources

### Reference Files

- **`references/linter-configs.md`** - Comprehensive linter configurations
- **`references/error-patterns.md`** - Error handling patterns by language

### Examples

- **`examples/clippy.toml`** - Rust Clippy configuration
- **`examples/eslint.config.js`** - TypeScript ESLint configuration
- **`examples/pyproject-ruff.toml`** - Python Ruff configuration
