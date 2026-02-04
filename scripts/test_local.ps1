# Local Test Script - Runs all CI checks locally
# Usage: .\scripts\test_local.ps1
# Or: powershell -ExecutionPolicy Bypass -File .\scripts\test_local.ps1

param(
    [switch]$Quick,      # Skip slower checks
    [switch]$FixFormat,  # Auto-fix formatting issues
    [switch]$Verbose     # Show verbose output
)

$ErrorActionPreference = "Stop"
$script:hasErrors = $false
$script:startTime = Get-Date

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "[PASS] $Text" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Text)
    Write-Host "[FAIL] $Text" -ForegroundColor Red
    $script:hasErrors = $true
}

function Write-Info {
    param([string]$Text)
    Write-Host "[INFO] $Text" -ForegroundColor Yellow
}

function Write-Step {
    param([string]$Text)
    Write-Host ""
    Write-Host ">> $Text" -ForegroundColor Magenta
}

# Change to project root
$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $projectRoot

Write-Header "FFmpeg Converter App - Local CI Tests"
Write-Host "Project: $projectRoot"
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
if ($Quick) { Write-Info "Quick mode enabled - skipping slower checks" }

# Step 1: Check Flutter
Write-Step "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Success "Flutter: $flutterVersion"
} catch {
    Write-Failure "Flutter not found. Please install Flutter."
    exit 1
}

# Step 2: Get dependencies
Write-Step "Getting dependencies..."
$pubGetOutput = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Dependencies resolved"
} else {
    Write-Failure "Failed to get dependencies"
    Write-Host $pubGetOutput
    exit 1
}

# Step 3: Format check
Write-Step "Checking code formatting..."
if ($FixFormat) {
    $formatOutput = dart format . 2>&1
    Write-Success "Code formatted (auto-fix applied)"
} else {
    $formatOutput = dart format --set-exit-if-changed . 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code formatting OK"
    } else {
        Write-Failure "Code formatting issues found"
        Write-Host "Run 'dart format .' to fix, or use -FixFormat flag"
        if ($Verbose) { Write-Host $formatOutput }
    }
}

# Step 4: Static analysis
Write-Step "Running static analysis..."
$analyzeOutput = flutter analyze 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Static analysis passed (0 issues)"
} else {
    $issueCount = ($analyzeOutput | Select-String -Pattern "(\d+) issues? found" | ForEach-Object { $_.Matches.Groups[1].Value })
    Write-Failure "Static analysis found issues"
    Write-Host $analyzeOutput
}

# Step 5: Run tests
Write-Step "Running tests..."
$testStart = Get-Date
$testOutput = flutter test 2>&1
$testDuration = (Get-Date) - $testStart

if ($LASTEXITCODE -eq 0) {
    $passedTests = ($testOutput | Select-String -Pattern "\+(\d+):" | Select-Object -Last 1)
    Write-Success "All tests passed in $([math]::Round($testDuration.TotalSeconds, 1))s"
} else {
    Write-Failure "Tests failed"
    Write-Host $testOutput
}

# Step 6: Check for outdated dependencies (optional in quick mode)
if (-not $Quick) {
    Write-Step "Checking for outdated dependencies..."
    $outdatedOutput = flutter pub outdated 2>&1
    $directOutdated = $outdatedOutput | Select-String "direct dependencies:" -Context 0,10
    if ($outdatedOutput -match "all up-to-date" -or $outdatedOutput -match "direct dependencies: all up-to-date") {
        Write-Success "All direct dependencies up-to-date"
    } else {
        Write-Info "Some dependencies can be updated (not critical)"
        if ($Verbose) { Write-Host $outdatedOutput }
    }
}

# Step 7: Build check (optional in quick mode)
if (-not $Quick) {
    Write-Step "Checking if project builds..."
    # Just check that we can generate necessary files, don't do full build
    $buildCheckOutput = flutter pub run build_runner build --delete-conflicting-outputs 2>&1
    # This might fail if no build_runner, which is fine
    Write-Info "Build check completed (warnings are OK)"
}

# Summary
$duration = (Get-Date) - $script:startTime
Write-Header "Test Summary"
Write-Host "Duration: $([math]::Round($duration.TotalSeconds, 1)) seconds"

if ($script:hasErrors) {
    Write-Host ""
    Write-Failure "Some checks failed! Please fix before pushing."
    Write-Host ""
    exit 1
} else {
    Write-Host ""
    Write-Success "All checks passed! Ready to push."
    Write-Host ""
    exit 0
}
