# Environment Setup Guide

Complete guide for setting up the FFmpeg Converter App development environment from scratch.

## Table of Contents

- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Detailed Setup by Platform](#detailed-setup-by-platform)
  - [Windows Setup](#windows-setup)
  - [Linux Setup](#linux-setup)
  - [macOS Setup](#macos-setup)
  - [Android Development Setup](#android-development-setup)
  - [Web Development Setup](#web-development-setup)
- [Project Configuration](#project-configuration)
- [Verify Installation](#verify-installation)
- [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum Requirements
- **RAM**: 8GB minimum (16GB recommended for Android development)
- **Storage**: 15GB free space (30GB+ for Android SDK)
- **OS**: 
  - Windows 10/11 (64-bit)
  - Ubuntu 20.04+ / Debian 11+ / Fedora 35+
  - macOS 11.0 (Big Sur) or newer
- **Internet**: Required for initial setup and dependency downloads

### Software Requirements
- Flutter SDK 3.24.0 or newer
- Dart SDK 3.10.7 or newer (included with Flutter)
- Git 2.30+ for version control
- Code editor (VS Code recommended)

---

## Quick Start

For experienced developers who want to get started immediately:

```bash
# Clone the repository
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App

# Install dependencies
flutter pub get

# Create environment file (optional for local dev)
cp .env.example .env

# Run on your preferred platform
flutter run -d windows    # Windows
flutter run -d linux      # Linux
flutter run -d chrome     # Web
flutter run -d android    # Android (requires device/emulator)
```

For detailed platform-specific instructions, continue reading below.

---

## Detailed Setup by Platform

### Windows Setup

#### 1. Install Flutter SDK

**Option A: Using Official Installer (Recommended)**
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter` (avoid Program Files due to spaces)
3. Add to PATH:
   - Open "Edit environment variables for your account"
   - Add `C:\src\flutter\bin` to Path
   - Restart terminal

**Option B: Using Chocolatey**
```powershell
# Install Chocolatey first (if not installed)
# Then run:
choco install flutter
```

**Option C: Using Winget**
```powershell
winget install --id=Google.Flutter -e
```

#### 2. Install Git
```powershell
winget install --id=Git.Git -e
```

Or download from: https://git-scm.com/download/win

#### 3. Install Visual Studio 2022
Required for Windows desktop development:

1. Download Visual Studio 2022 Community: https://visualstudio.microsoft.com/
2. During installation, select:
   - "Desktop development with C++"
   - Windows 10 SDK (10.0.17763.0 or newer)

**Alternative**: Visual Studio Build Tools (smaller download)
```powershell
winget install --id=Microsoft.VisualStudio.2022.BuildTools -e
```

#### 4. Verify Flutter Installation
```powershell
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.24.x)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Visual Studio - develop Windows apps
[✓] VS Code (version 1.x)
```

#### 5. Clone and Setup Project
```powershell
# Navigate to your projects directory
cd C:\Users\YourName\Documents\Github

# Clone repository
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App

# Install dependencies
flutter pub get

# Run the app
flutter run -d windows
```

---

### Linux Setup

#### 1. Install Flutter SDK

**Ubuntu/Debian:**
```bash
# Install required dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Fedora:**
```bash
sudo dnf install curl git unzip xz zip mesa-libGLU

cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Arch Linux:**
```bash
# Install from AUR
yay -S flutter

# Or install manually
sudo pacman -S git curl unzip xz zip mesa
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 2. Install Linux Desktop Dependencies
```bash
# Ubuntu/Debian
sudo apt-get install -y \
  clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-12-dev \
  libmpv-dev mpv

# Fedora
sudo dnf install clang cmake ninja-build \
  gtk3-devel xz-devel \
  mpv-devel

# Arch Linux
sudo pacman -S clang cmake ninja gtk3 xz mpv
```

#### 3. Verify Installation
```bash
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.24.x)
[✓] Linux toolchain - develop for Linux desktop
[✓] VS Code (version 1.x)
```

#### 4. Clone and Setup Project
```bash
# Navigate to projects directory
cd ~/Documents/Github

# Clone repository
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App

# Install dependencies
flutter pub get

# Run the app
flutter run -d linux
```

---

### macOS Setup

#### 1. Install Xcode
Required for iOS and macOS development:

1. Install from App Store: https://apps.apple.com/app/xcode/id497799835
2. Accept license:
```bash
sudo xcodebuild -license accept
```

3. Install command-line tools:
```bash
xcode-select --install
```

#### 2. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 3. Install Flutter
```bash
# Using Homebrew
brew install flutter

# Or manual installation
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### 4. Install CocoaPods (for iOS/macOS dependencies)
```bash
sudo gem install cocoapods
pod setup
```

#### 5. Verify Installation
```bash
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.24.x)
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] VS Code (version 1.x)
```

#### 6. Clone and Setup Project
```bash
cd ~/Documents/Github
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App
flutter pub get
flutter run -d macos
```

---

### Android Development Setup

#### Prerequisites
- Complete the Windows/Linux/macOS setup first
- Android device or emulator

#### 1. Install Android Studio

**Windows:**
```powershell
winget install --id=Google.AndroidStudio -e
```

**Linux (Ubuntu/Debian):**
```bash
# Download from: https://developer.android.com/studio
sudo snap install android-studio --classic
```

**macOS:**
```bash
brew install --cask android-studio
```

#### 2. Configure Android SDK
1. Open Android Studio
2. Go to `Settings/Preferences` → `Appearance & Behavior` → `System Settings` → `Android SDK`
3. Install:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools 34.0.0
   - Android SDK Platform 34 (API 34)
   - Android SDK Platform 24 (API 24 - minimum supported)
   - Android Emulator

#### 3. Accept Android Licenses
```bash
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

#### 4. Install Java 17 (Required)

**Windows:**
```powershell
winget install --id=EclipseAdoptium.Temurin.17.JDK -e
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install openjdk-17-jdk
```

**macOS:**
```bash
brew install openjdk@17
```

Set JAVA_HOME:
```bash
# Linux/macOS - add to ~/.bashrc or ~/.zshrc
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64  # Ubuntu
export JAVA_HOME=/usr/local/opt/openjdk@17            # macOS

# Windows - use System Environment Variables
# Set JAVA_HOME to: C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\
```

#### 5. Setup Android Emulator (Optional)
```bash
# List available emulator targets
flutter emulators

# Create a new emulator
flutter emulators --create --name pixel_7

# Launch emulator
flutter emulators --launch pixel_7
```

**Or use Android Studio:**
1. Open `Tools` → `Device Manager`
2. Click `Create Device`
3. Select `Pixel 7` → `Next`
4. Download system image (API 34 recommended) → `Next`
5. Finish and launch

#### 6. Connect Physical Device (Alternative)

**Enable USB Debugging:**
1. Go to `Settings` → `About Phone`
2. Tap `Build Number` 7 times to enable Developer Options
3. Go to `Settings` → `Developer Options`
4. Enable `USB Debugging`
5. Connect device via USB
6. Accept debugging prompt on phone

**Verify connection:**
```bash
flutter devices
```

Should show your connected device or emulator.

#### 7. Build and Run on Android
```bash
cd FFmpeg-Converter-App

# Run in debug mode
flutter run -d android

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### 8. Install APK on Device
```bash
# Using ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer APK to phone and install manually
```

---

### Web Development Setup

#### 1. Install Chrome/Edge Browser
Flutter web requires Chrome or Edge for development.

**Verify Chrome is detected:**
```bash
flutter devices
```

Should show:
```
Chrome (web) • chrome • web-javascript • Google Chrome 120.x
```

#### 2. Enable Web Support (if not enabled)
```bash
flutter config --enable-web
```

#### 3. Run Web Version
```bash
cd FFmpeg-Converter-App

# Run in Chrome
flutter run -d chrome

# Run in Edge
flutter run -d edge

# Build for production
flutter build web --release

# Output: build/web/
```

#### 4. Test Web Build Locally
```bash
# Using Python (if installed)
cd build/web
python -m http.server 8000

# Or using Flutter's built-in server
flutter run -d web-server --web-port=8000

# Open browser: http://localhost:8000
```

---

## Project Configuration

### Environment Variables (.env)

The app uses environment variables for analytics configuration (optional for development).

#### 1. Create .env File
```bash
cp .env.example .env
```

#### 2. Edit .env
```bash
# Windows
notepad .env

# Linux/macOS
nano .env
```

#### 3. Configure Analytics (Optional)
```env
# Cloudflare Worker URL (leave as-is for testing)
ANALYTICS_WORKER_URL=https://ffmpeg-analytics-worker.thuanc177.workers.dev

# API Key (generate secure key for production)
ANALYTICS_API_KEY=your-api-key
```

**Generate secure API key:**
```bash
# Using OpenSSL
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

**Note**: Analytics are optional. The app works without valid credentials (logs warnings only).

---

## Verify Installation

### Run Comprehensive Checks
```bash
# Flutter system check
flutter doctor -v

# Check for connected devices
flutter devices

# Analyze project health
flutter analyze

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated
```

### Expected Flutter Doctor Output
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.x, on [OS], locale en-US)
[✓] Windows/Linux/macOS toolchain
[✓] Chrome - develop for the web
[✓] Visual Studio/Xcode (if applicable)
[✓] Android toolchain (if Android setup completed)
[✓] VS Code (version 1.x)
[✓] Connected device (if any)
[✓] Network resources

• No issues found!
```

### Test Build on Each Platform

**Windows:**
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

**Linux:**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

**macOS:**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

**Android:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Web:**
```bash
flutter build web --release
# Output: build/web/
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Flutter command not found"
**Solution:**
```bash
# Verify PATH is set correctly
echo $PATH  # Linux/macOS
echo %PATH%  # Windows

# Re-add Flutter to PATH
# Linux/macOS: edit ~/.bashrc or ~/.zshrc
export PATH="$HOME/flutter/bin:$PATH"

# Windows: Edit System Environment Variables
# Add: C:\src\flutter\bin
```

#### Issue: "cmdline-tools component is missing"
**Solution:**
```bash
# Open Android Studio
# Settings → Android SDK → SDK Tools
# Install "Android SDK Command-line Tools"

# Or use sdkmanager
flutter doctor --android-licenses
```

#### Issue: "Visual Studio not found" (Windows)
**Solution:**
1. Install Visual Studio 2022 Community
2. Select "Desktop development with C++"
3. Restart terminal and run `flutter doctor`

#### Issue: "CocoaPods not installed" (macOS)
**Solution:**
```bash
sudo gem install cocoapods
pod setup
```

#### Issue: "Gradle build failed" (Android)
**Solution:**
```bash
# Clean build
cd android
./gradlew clean
cd ..

# Rebuild
flutter clean
flutter pub get
flutter build apk
```

#### Issue: "Java version mismatch" (Android)
**Solution:**
```bash
# Check Java version
java -version  # Should be 17.x

# Set JAVA_HOME correctly
# Linux/macOS
export JAVA_HOME=/path/to/jdk-17
echo $JAVA_HOME

# Windows
# System Properties → Environment Variables
# Set JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\
```

#### Issue: "Package dependencies conflict"
**Solution:**
```bash
# Update dependencies
flutter pub upgrade

# Reset dependencies
rm -rf pubspec.lock
flutter clean
flutter pub get
```

#### Issue: "Android license not accepted"
**Solution:**
```bash
flutter doctor --android-licenses
# Press 'y' for all prompts
```

#### Issue: "FFmpeg not found" (Linux desktop)
**Note**: FFmpeg is bundled in the app for desktop platforms.

If you encounter issues:
```bash
# Ubuntu/Debian
sudo apt-get install ffmpeg

# Fedora
sudo dnf install ffmpeg

# Arch
sudo pacman -S ffmpeg
```

#### Issue: "Permission denied" when running on Linux
**Solution:**
```bash
# Make scripts executable
chmod +x build-linux-portable.sh
chmod +x scripts/run_tests.sh

# Run Flutter with proper permissions
sudo usermod -aG plugdev $USER
# Logout and login again
```

#### Issue: "Web build extremely slow"
**Solution:**
```bash
# Use CanvasKit renderer (better performance)
flutter run -d chrome --web-renderer canvaskit

# Or HTML renderer (faster loading)
flutter run -d chrome --web-renderer html
```

#### Issue: "Cannot find libmpv" (Linux)
**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install libmpv-dev mpv

# Fedora
sudo dnf install mpv-devel

# Arch
sudo pacman -S mpv
```

#### Issue: ".env file not loaded"
**Solution:**
- Verify `.env` file exists in project root
- Check file is not named `.env.txt` (Windows may hide extensions)
- Ensure no syntax errors in `.env` file
- Rebuild app: `flutter clean && flutter pub get && flutter run`

---

## Next Steps

After completing environment setup:

1. **Read Development Guide**: See `DEVELOPMENT.md` for architecture overview
2. **Run Tests**: `./scripts/run_tests.sh` or `./scripts/run_tests.ps1`
3. **Explore Codebase**: Start with `lib/main.dart`
4. **Check Recent Changes**: `git log --oneline -10`
5. **Build Documentation**: See `BUILD.md` for portable package builds

---

## Getting Help

- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Project Issues**: https://github.com/AtelierMizumi/FFmpeg-Converter-App/issues
- **Flutter Docs**: https://docs.flutter.dev
- **FFmpeg Docs**: https://ffmpeg.org/documentation.html

---

**Last Updated**: February 2026  
**Tested with**: Flutter 3.24.x, Dart 3.10.7
