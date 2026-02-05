# FFmpeg Converter App - Test Runner Script (Windows)
# Run all tests with coverage

Write-Host "🧪 FFmpeg Converter App - Running Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Step 1: Get dependencies
    Write-Host "📦 Step 1: Getting dependencies..." -ForegroundColor Blue
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "Failed to get dependencies" }
    Write-Host ""

    # Step 2: Format check
    Write-Host "✨ Step 2: Checking code formatting..." -ForegroundColor Blue
    dart format --set-exit-if-changed .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Warning: Code formatting issues found. Run 'dart format .' to fix." -ForegroundColor Yellow
    }
    Write-Host ""

    # Step 3: Analyze code
    Write-Host "🔍 Step 3: Analyzing code..." -ForegroundColor Blue
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw "Code analysis failed" }
    Write-Host ""

    # Step 4: Run tests with coverage
    Write-Host "🧪 Step 4: Running tests with coverage..." -ForegroundColor Blue
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) { throw "Tests failed" }
    Write-Host ""

    # Step 5: Generate coverage report (optional - requires lcov)
    Write-Host "📊 Step 5: Generating coverage report..." -ForegroundColor Blue
    if (Get-Command genhtml -ErrorAction SilentlyContinue) {
        genhtml coverage/lcov.info -o coverage/html
        Write-Host "✅ Coverage report generated: coverage/html/index.html" -ForegroundColor Green
    } else {
        Write-Host "⚠️  lcov not installed. Skipping HTML coverage report." -ForegroundColor Yellow
        Write-Host "   Install with: choco install lcov (Chocolatey)" -ForegroundColor Yellow
    }
    Write-Host ""

    # Step 6: Test summary
    Write-Host "✅ All tests completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Test Results Summary:" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    flutter test --reporter compact 2>&1 | Select-Object -Last 5
    Write-Host ""

    # Step 7: Coverage summary
    if (Test-Path coverage/lcov.info) {
        Write-Host "📈 Coverage Summary:" -ForegroundColor Cyan
        Write-Host "   Coverage file: coverage/lcov.info" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "🎉 Test suite completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  - View coverage: open coverage\html\index.html" -ForegroundColor White
    Write-Host "  - Run specific test: flutter test test\path\to\test.dart" -ForegroundColor White
    Write-Host "  - Run in watch mode: flutter test --watch" -ForegroundColor White

} catch {
    Write-Host ""
    Write-Host "❌ Test suite failed: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
