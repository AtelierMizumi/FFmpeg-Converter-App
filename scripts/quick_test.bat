@echo off
REM Quick Test Script for Windows
REM Usage: scripts\quick_test.bat
REM Runs: format check, analyze, and tests

echo.
echo ========================================
echo  Quick Local Test - FFmpeg Converter
echo ========================================
echo.

cd /d "%~dp0.."

echo [1/3] Checking format...
dart format --set-exit-if-changed . >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Format issues found. Run: dart format .
    exit /b 1
)
echo [PASS] Format OK

echo [2/3] Running analyze...
flutter analyze >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Analysis issues found
    flutter analyze
    exit /b 1
)
echo [PASS] Analysis OK

echo [3/3] Running tests...
flutter test
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Tests failed
    exit /b 1
)

echo.
echo ========================================
echo  All checks passed! Ready to push.
echo ========================================
echo.
