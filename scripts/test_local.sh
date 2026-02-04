#!/bin/bash
# Local Test Script - Runs all CI checks locally
# Usage: ./scripts/test_local.sh
# Options:
#   -q, --quick      Skip slower checks
#   -f, --fix        Auto-fix formatting issues
#   -v, --verbose    Show verbose output

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Flags
QUICK=false
FIX_FORMAT=false
VERBOSE=false
HAS_ERRORS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quick) QUICK=true; shift ;;
        -f|--fix) FIX_FORMAT=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        *) shift ;;
    esac
done

# Helper functions
header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    HAS_ERRORS=true
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

step() {
    echo ""
    echo -e "${MAGENTA}>> $1${NC}"
}

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

START_TIME=$(date +%s)

header "FFmpeg Converter App - Local CI Tests"
echo "Project: $PROJECT_ROOT"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
if $QUICK; then info "Quick mode enabled - skipping slower checks"; fi

# Step 1: Check Flutter
step "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
    success "Flutter: $FLUTTER_VERSION"
else
    failure "Flutter not found. Please install Flutter."
    exit 1
fi

# Step 2: Get dependencies
step "Getting dependencies..."
if flutter pub get > /dev/null 2>&1; then
    success "Dependencies resolved"
else
    failure "Failed to get dependencies"
    flutter pub get
    exit 1
fi

# Step 3: Format check
step "Checking code formatting..."
if $FIX_FORMAT; then
    dart format .
    success "Code formatted (auto-fix applied)"
else
    if dart format --set-exit-if-changed . > /dev/null 2>&1; then
        success "Code formatting OK"
    else
        failure "Code formatting issues found"
        echo "Run 'dart format .' to fix, or use -f/--fix flag"
    fi
fi

# Step 4: Static analysis
step "Running static analysis..."
ANALYZE_OUTPUT=$(flutter analyze 2>&1) || true
if echo "$ANALYZE_OUTPUT" | grep -q "No issues found"; then
    success "Static analysis passed (0 issues)"
else
    failure "Static analysis found issues"
    echo "$ANALYZE_OUTPUT"
fi

# Step 5: Run tests
step "Running tests..."
TEST_START=$(date +%s)
TEST_OUTPUT=$(flutter test 2>&1) || true
TEST_END=$(date +%s)
TEST_DURATION=$((TEST_END - TEST_START))

if echo "$TEST_OUTPUT" | grep -q "All tests passed"; then
    success "All tests passed in ${TEST_DURATION}s"
else
    failure "Tests failed"
    echo "$TEST_OUTPUT"
fi

# Step 6: Check for outdated dependencies (optional in quick mode)
if ! $QUICK; then
    step "Checking for outdated dependencies..."
    OUTDATED_OUTPUT=$(flutter pub outdated 2>&1)
    if echo "$OUTDATED_OUTPUT" | grep -q "all up-to-date"; then
        success "All direct dependencies up-to-date"
    else
        info "Some dependencies can be updated (not critical)"
        if $VERBOSE; then echo "$OUTDATED_OUTPUT"; fi
    fi
fi

# Summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

header "Test Summary"
echo "Duration: ${DURATION} seconds"

if $HAS_ERRORS; then
    echo ""
    failure "Some checks failed! Please fix before pushing."
    echo ""
    exit 1
else
    echo ""
    success "All checks passed! Ready to push."
    echo ""
    exit 0
fi
