@echo off
setlocal enabledelayedexpansion
REM Quick Test Script for Windows
REM Usage: scripts\quick_test.bat
REM Runs: format check, analyze, and tests

echo.
echo ========================================
echo  Quick Local Test - FFmpeg Converter
echo ========================================
echo.

REM Change to project root (parent of scripts folder)
cd /d "%~dp0.."
echo Working directory: %CD%
echo.

echo [1/3] Checking format...
call dart format --set-exit-if-changed . >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Format issues found. Run: dart format .
    goto :error
)
echo [PASS] Format OK

echo [2/3] Running analyze...
call flutter analyze >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Analysis issues found
    call flutter analyze
    goto :error
)
echo [PASS] Analysis OK

echo [3/3] Running tests...
call flutter test
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Tests failed
    goto :error
)

echo.
echo ========================================
echo  All checks passed! Ready to push.
echo ========================================
echo.
endlocal
exit /b 0

:error
echo.
echo ========================================
echo  Some checks failed!
echo ========================================
echo.
endlocal
exit /b 1
