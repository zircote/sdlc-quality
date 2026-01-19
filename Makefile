.PHONY: all build test lint lint-strict format format-check clean help ci docs install

# Default target
all: lint test

# Build (no-op for markdown plugin)
build:
	@echo "No build step required for markdown plugin"

# Run tests
test:
	@echo "Running tests..."
	@./scripts/test.sh

# Run linting (markdown)
lint:
	@echo "Running markdown linter..."
	@npx markdownlint-cli2 "**/*.md" "#node_modules" || true

# Run strict linting
lint-strict:
	@echo "Running strict markdown linter..."
	@npx markdownlint-cli2 "**/*.md" "#node_modules"

# Format markdown files
format:
	@echo "Formatting markdown files..."
	@npx prettier --write "**/*.md" "**/*.yml" "**/*.yaml" "**/*.json"

# Check formatting
format-check:
	@echo "Checking formatting..."
	@npx prettier --check "**/*.md" "**/*.yml" "**/*.yaml" "**/*.json"

# Clean artifacts
clean:
	@echo "Cleaning..."
	@rm -rf node_modules coverage tmp

# Install development dependencies
install:
	@echo "Installing development dependencies..."
	@npm install -D markdownlint-cli2 prettier

# Generate documentation
docs:
	@echo "Documentation is in docs/"
	@ls -la docs/

# Run all CI checks
ci: format-check lint-strict test
	@echo "All CI checks passed!"

# Display help
help:
	@echo "SDLC Standards Plugin - Available targets:"
	@echo ""
	@echo "  all          - Run lint and test (default)"
	@echo "  build        - Build (no-op for this plugin)"
	@echo "  test         - Run tests"
	@echo "  lint         - Run markdown linter"
	@echo "  lint-strict  - Run linter with warnings as errors"
	@echo "  format       - Format all files"
	@echo "  format-check - Check formatting without changes"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install dev dependencies"
	@echo "  docs         - List documentation"
	@echo "  ci           - Run all CI checks"
	@echo "  help         - Display this help"
