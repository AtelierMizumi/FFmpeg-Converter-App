# Makefile for FFmpeg Converter App
# Usage: make test, make quick, make format, etc.

.PHONY: help test quick format analyze clean deps

# Default target
help:
	@echo "FFmpeg Converter App - Available Commands:"
	@echo ""
	@echo "  make test     - Run all CI checks (format, analyze, test)"
	@echo "  make quick    - Quick test (just flutter test)"
	@echo "  make format   - Auto-format code"
	@echo "  make analyze  - Run static analysis"
	@echo "  make deps     - Update dependencies"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make build    - Build for current platform"
	@echo ""

# Full CI test
test:
	@echo ">> Getting dependencies..."
	@flutter pub get
	@echo ""
	@echo ">> Checking format..."
	@dart format --set-exit-if-changed .
	@echo ""
	@echo ">> Running analysis..."
	@flutter analyze
	@echo ""
	@echo ">> Running tests..."
	@flutter test
	@echo ""
	@echo "All checks passed!"

# Quick test (just run tests)
quick:
	@flutter test

# Format code
format:
	@dart format .
	@echo "Code formatted!"

# Static analysis
analyze:
	@flutter analyze

# Update dependencies
deps:
	@flutter pub get
	@flutter pub upgrade
	@flutter pub outdated

# Clean
clean:
	@flutter clean
	@echo "Cleaned!"

# Build for current platform
build:
	@flutter build

# Watch tests (re-run on file changes)
watch:
	@flutter test --watch

# Run specific test file
test-file:
	@flutter test $(FILE)

# Generate coverage report
coverage:
	@flutter test --coverage
	@echo "Coverage report generated in coverage/lcov.info"
