#!/bin/bash
# FFmpeg Converter App - Test Runner Script
# Run all tests with coverage

set -e

echo "🧪 FFmpeg Converter App - Running Tests"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Get dependencies
echo -e "${BLUE}📦 Step 1: Getting dependencies...${NC}"
flutter pub get
echo ""

# Step 2: Format check
echo -e "${BLUE}✨ Step 2: Checking code formatting...${NC}"
dart format --set-exit-if-changed . || {
    echo -e "${RED}⚠️  Warning: Code formatting issues found. Run 'dart format .' to fix.${NC}"
}
echo ""

# Step 3: Analyze code
echo -e "${BLUE}🔍 Step 3: Analyzing code...${NC}"
flutter analyze
echo ""

# Step 4: Run tests with coverage
echo -e "${BLUE}🧪 Step 4: Running tests with coverage...${NC}"
flutter test --coverage
echo ""

# Step 5: Generate coverage report
echo -e "${BLUE}📊 Step 5: Generating coverage report...${NC}"
if command -v lcov &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage report generated: coverage/html/index.html${NC}"
else
    echo -e "${RED}⚠️  lcov not installed. Skipping HTML coverage report.${NC}"
    echo "   Install with: sudo apt-get install lcov (Ubuntu) or brew install lcov (macOS)"
fi
echo ""

# Step 6: Test summary
echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo ""
echo "📊 Test Results Summary:"
echo "========================"
flutter test --reporter compact 2>&1 | tail -5
echo ""

# Step 7: Coverage summary
if [ -f coverage/lcov.info ]; then
    echo "📈 Coverage Summary:"
    if command -v lcov &> /dev/null; then
        lcov --summary coverage/lcov.info
    else
        echo "   Coverage file: coverage/lcov.info"
    fi
fi
echo ""

echo -e "${GREEN}🎉 Test suite completed!${NC}"
echo ""
echo "Next steps:"
echo "  - View coverage: open coverage/html/index.html"
echo "  - Run specific test: flutter test test/path/to/test.dart"
echo "  - Run in watch mode: flutter test --watch"
