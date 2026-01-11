# Build Instructions

This document explains how to build portable packages for FFmpeg Converter.

## Prerequisites

- Flutter SDK installed and in PATH
- Platform-specific dependencies installed

## Quick Build

### Linux
```bash
./build-linux-portable.sh
```
**Output:** `FFmpeg-Converter-Linux-Portable.tar.gz`

When extracted, users get:
- `ffmpeg-converter` (launch script) - Main executable
- `README.txt` - Instructions
- All required files in same directory

### Windows
```cmd
build-windows-portable.bat
```
**Output:** `FFmpeg-Converter-Windows-Portable.zip`

When extracted, users get:
- `FFmpeg-Converter.exe` - Main executable (renamed from flutter_test_application.exe)
- `README.txt` - Instructions with nice formatting
- All DLLs and data folder in same directory

**No .bat wrapper needed!** Just double-click the EXE file.

### Android
```bash
./build-android-java17.sh
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

## What Makes These "Portable"?

### Windows ✨
- File EXE đã được **đổi tên thành FFmpeg-Converter.exe** cho dễ nhận biết
- Khi giải nén ZIP, tất cả files nằm ở **root folder**:
  ```
  📁 Extracted folder/
  ├── FFmpeg-Converter.exe  ← Double-click này!
  ├── README.txt            ← Hướng dẫn đẹp
  ├── *.dll files           ← Dependencies
  └── data/                 ← Assets
  ```
- **Không cần .bat file!** Trực tiếp chạy .exe
- Có thể tạo shortcut ngay từ .exe file
- Copy toàn bộ folder sang máy khác vẫn chạy

### Linux 🐧
- Launch script `ffmpeg-converter` tự động setup LD_LIBRARY_PATH
- Tất cả files ở cùng thư mục
- Chỉ cần `./ffmpeg-converter` là chạy

### Android 📱
- Standard APK file
- Note: Video conversion not available on Android

## Platform-Specific Instructions

### Linux

**Requirements:**
```bash
# Ubuntu/Debian
sudo apt-get install ninja-build libgtk-3-dev libmpv-dev mpv

# Fedora
sudo dnf install ninja-build gtk3-devel mpv-devel

# Arch Linux
sudo pacman -S ninja gtk3 mpv
```

**Build:**
```bash
./build-linux-portable.sh
```

**Test:**
```bash
tar -xzf FFmpeg-Converter-Linux-Portable.tar.gz
cd FFmpeg-Converter/
./ffmpeg-converter
```

### Windows

**Requirements:**
- Visual Studio 2022 or Visual Studio Build Tools
- Flutter SDK

**Build:**
```cmd
build-windows-portable.bat
```

**What happens:**
1. Builds the Flutter app
2. Renames `flutter_test_application.exe` → `FFmpeg-Converter.exe`
3. Creates user-friendly README.txt
4. Packages everything in ZIP

**Test:**
```cmd
# Extract the ZIP
# Navigate to extracted folder
FFmpeg-Converter.exe
```

**User Experience:**
- Download ZIP
- Extract anywhere
- Double-click `FFmpeg-Converter.exe`
- That's it! 🎉

### Android

**Requirements:**
- Android SDK
- Java 17 (Temurin or OpenJDK)

**Install Java 17 (Arch Linux):**
```bash
sudo pacman -S jdk17-temurin
```

**Build:**
```bash
./build-android-java17.sh
```

**Install on device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Actions

The project automatically builds on push to main branch.

**Release artifacts:**
- `FFmpeg-Converter-Linux-Portable.tar.gz` ← Extract and run `./ffmpeg-converter`
- `FFmpeg-Converter-Windows-Portable.zip` ← Extract and run `FFmpeg-Converter.exe`
- `FFmpeg-Converter-Android.apk` ← Install APK
- `LINUX_README.txt` ← Linux instructions

**Key improvements:**
- ✅ Windows EXE has user-friendly name
- ✅ No wrapper scripts needed
- ✅ Files at root level when extracted
- ✅ Beautiful, localized README files
- ✅ Clear release notes with step-by-step instructions

## Distribution

### Windows 🪟
Users:
1. Download ZIP
2. Extract (Right-click → Extract All)
3. Double-click `FFmpeg-Converter.exe`

**That's it!** No installation, no setup, just run.

### Linux 🐧
Users:
1. Download tar.gz
2. Extract: `tar -xzf FFmpeg-Converter-Linux-Portable.tar.gz`
3. Run: `./ffmpeg-converter`

### Android 🤖
Users:
1. Download APK
2. Install
3. Note: Video conversion not available

## Why This Approach?

**Before (Bad):**
- ❌ Generic exe name: `flutter_test_application.exe`
- ❌ Extra .bat file cluttering the directory
- ❌ Users confused which file to click
- ❌ Nested folders in ZIP

**After (Good):**
- ✅ Clear name: `FFmpeg-Converter.exe`
- ✅ One clear executable
- ✅ Beautiful README with emoji guide
- ✅ Flat structure when extracted
- ✅ Professional appearance

## Notes

- **Android**: FFmpeg video conversion not available (discontinued package)
- **Web**: Deployed automatically to GitHub Pages
- **All packages are truly portable** - extract and run immediately!
- **No installation wizards** - just files that work
