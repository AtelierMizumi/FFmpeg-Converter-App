# FFmpeg Converter App

![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Android%20%7C%20Web-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Status](https://img.shields.io/badge/Status-Active-success)

An efficient, cross-platform video conversion application built with Flutter and FFmpeg. Convert video formats, adjust quality, resize resolutions, and modify audio settings with a simple and intuitive interface.

**NEW: Full Android support with native FFmpeg processing!**

---

## Quick Start

### Download Pre-built Releases

Get the latest version for your platform:
- **Windows**: Download `.zip` → Extract → Run `FFmpeg-Converter.exe`
- **Linux**: Download `.tar.gz` → Extract → Run `./ffmpeg-converter`
- **Android**: Download `.apk` → Install → Open app
- **Web**: Visit [https://ateliermizumi.github.io/FFmpeg-Converter-App](https://ateliermizumi.github.io/FFmpeg-Converter-App)

### Build from Source

```bash
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App
flutter pub get
flutter run -d windows  # or linux, android, chrome
```

See [SETUP.md](SETUP.md) for detailed environment setup instructions.

---

## Features

### Core Features
- **Cross-Platform**: Windows, Linux, macOS, Android, and Web support
- **Drag & Drop**: Easily drag video files directly into the application
- **Format Flexibility**: Support for MP4, WebM, MKV, and MOV containers
- **Quality Control**: Adjustable CRF (Constant Rate Factor) and encoding presets
- **Resolution Scaling**: Resize videos to 1080p, 720p, 480p, or custom dimensions
- **Audio Management**: Transcode (AAC), copy stream (lossless), or mute audio
- **Video Editing**: Trim videos and merge multiple clips
- **Video Comparison**: Compare original and converted videos side-by-side
- **Multi-language**: English, Vietnamese, German, and Japanese

### Platform-Specific Features

| Feature | Windows | Linux | macOS | Android | Web |
|---------|---------|-------|-------|---------|-----|
| Video Conversion | ✅ | ✅ | ✅ | ✅ | ✅ (500MB limit) |
| Hardware Acceleration | ✅ | ✅ | ✅ | ❌ | ❌ |
| Video Trimming | ✅ | ✅ | ✅ | ✅ | ✅ |
| Video Merging | ✅ | ✅ | ✅ | ✅ | ✅ |
| No File Size Limit | ✅ | ✅ | ✅ | ✅ (2GB recommended) | ❌ |
| Offline Use | ✅ | ✅ | ✅ | ✅ | ❌ |

---

## Getting Started

### Prerequisites

**For Users**: No prerequisites! Just download and run the pre-built releases.

**For Developers**:
- [Flutter SDK 3.24+](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/)
- Platform-specific tools (see [SETUP.md](SETUP.md))

### Installation

#### End Users

**Windows**:
1. Download `FFmpeg-Converter-Windows-Portable.zip` from [Releases](https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases)
2. Extract the ZIP file
3. Double-click `FFmpeg-Converter.exe`
4. Start converting!

**Linux**:
1. Download `FFmpeg-Converter-Linux-Portable.tar.gz` from [Releases](https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases)
2. Extract: `tar -xzf FFmpeg-Converter-Linux-Portable.tar.gz`
3. Run: `./ffmpeg-converter`

**Android**:
1. Download `FFmpeg-Converter-Android.apk` from [Releases](https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases)
2. Install the APK (enable "Install from unknown sources" if needed)
3. Open the app
4. Grant storage permissions when prompted

**Web**:
- Visit [https://ateliermizumi.github.io/FFmpeg-Converter-App](https://ateliermizumi.github.io/FFmpeg-Converter-App)
- No installation required!
- Note: 500MB file size limit

#### Developers

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
   cd FFmpeg-Converter-App
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **(Optional) Setup environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your analytics credentials (optional)
   ```

4. **Run the application**:
   ```bash
   # Windows
   flutter run -d windows
   
   # Linux
   flutter run -d linux
   
   # macOS
   flutter run -d macos
   
   # Android (requires device/emulator)
   flutter run -d android
   
   # Web
   flutter run -d chrome
   ```

For detailed setup instructions, see [SETUP.md](SETUP.md).

---

## Usage

### Basic Conversion

1. **Select a Video File**:
   - Click "Select File" button, or
   - Drag and drop a video file into the app

2. **Choose Output Folder** (Desktop only):
   - Click "Select Output Folder"
   - Choose where to save the converted file

3. **Configure Settings**:
   - **Container**: MP4, WebM, MKV, or MOV
   - **Video Codec**: H.264 (libx264), H.265 (libx265), VP9, or AV1
   - **Preset**: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
   - **Quality (CRF)**: Lower = better quality, larger file (0-51 for H.264/265, 0-63 for VP9/AV1)
   - **Resolution**: 1080p, 720p, 480p, or custom
   - **Audio**: Transcode to AAC, Copy (lossless), or Mute

4. **Start Conversion**:
   - Click "Convert" button
   - Monitor progress bar
   - Wait for completion

5. **Review Output**:
   - Click "Open File" to view result
   - Use "Compare Videos" to see before/after

### Video Editing

**Trim Videos**:
1. Go to "Editor" tab
2. Select video file
3. Set start and end times using sliders
4. Click "Trim Video"

**Merge Videos**:
1. Go to "Editor" tab
2. Select "Merge" mode
3. Add multiple video files
4. Click "Merge Videos"

### Tips for Best Results

**Quality vs Speed**:
- Use `ultrafast` or `superfast` presets for quick previews
- Use `slow` or `slower` for final, high-quality outputs
- Use `medium` for balanced speed/quality

**File Size Optimization**:
- Increase CRF value (e.g., 23-28) to reduce file size
- Lower resolution (e.g., 720p) significantly reduces size
- Use H.265 codec for better compression (but slower encoding)

**Android Performance**:
- Use `ultrafast` or `superfast` presets
- Avoid converting files larger than 2GB
- Close other apps during conversion
- Keep device plugged in for long conversions

**Web Limitations**:
- Maximum file size: 500MB
- Encoding is slower than desktop
- Large files may cause browser memory issues

---

## Documentation

- **[SETUP.md](SETUP.md)** - Complete environment setup guide for developers
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Architecture, coding guidelines, and contribution guide
- **[BUILD.md](BUILD.md)** - Instructions for building portable packages
- **[docs/FFMPEG_OPTIMIZATION.md](docs/FFMPEG_OPTIMIZATION.md)** - FFmpeg optimization tips

---

## Technology Stack

- **Framework**: Flutter 3.24+ / Dart 3.10.7+
- **FFmpeg**:
  - Desktop (Windows/Linux/macOS): Native FFmpeg binaries (v6.0+)
  - Mobile (Android/iOS): ffmpeg_kit_flutter_new v4.1.0 (FFmpeg v8.0.0)
  - Web: ffmpeg_wasm v1.0.3
- **Video Playback**: media_kit v1.2.6 (mpv backend)
- **Localization**: flutter_localizations + intl
- **Analytics**: Custom Cloudflare Workers backend (optional)

---

## Project Structure

```
FFmpeg-Converter-App/
├── lib/
│   ├── services/          # Business logic
│   │   ├── ffmpeg_service_desktop.dart   # Windows/Linux/macOS
│   │   ├── ffmpeg_service_mobile.dart    # Android/iOS
│   │   └── ffmpeg_service_web.dart       # Web
│   ├── ui/                # User interface
│   │   ├── tabs/          # Main conversion UI
│   │   └── editor/        # Video editing UI
│   └── main.dart          # App entry point
├── test/                  # Unit & widget tests
├── android/               # Android configuration
├── assets/bin/            # Bundled FFmpeg binaries
└── .github/workflows/     # CI/CD automation
```

---

## Recent Changes

### v1.1.0 (Latest) - Android Support & Stability Improvements

**New Features**:
- Full Android support with native FFmpeg processing
- Real video duration detection for accurate trimming
- 2GB file size warning for mobile devices
- Improved Android 13+ permission handling

**Bug Fixes**:
- Fixed memory leak in mobile FFmpeg callbacks
- Removed conflicting storage permission requests
- Fixed incorrect cancel logic in desktop service
- Enhanced error handling for FFmpeg operations

**Testing**:
- Added comprehensive unit tests for FFmpeg services
- Added widget tests for converter UI
- CI/CD testing on all platforms
- 150+ test cases covering core functionality

**Breaking Changes**:
- Package renamed from `flutter_test_application` to `ffmpeg_converter_app`
- Android users must uninstall old version before upgrading

See commit history for detailed changes:
```bash
git log --oneline -10
```

---

## Building

### Quick Build

```bash
# Windows
build-windows-portable.bat

# Linux
./build-linux-portable.sh

# Android
./build-android-java17.sh

# Web
flutter build web --release
```

See [BUILD.md](BUILD.md) for detailed instructions.

---

## Testing

Run all tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

Run specific test file:
```bash
flutter test test/services/ffmpeg_service_mobile_test.dart
```

See [test/README.md](test/README.md) for testing documentation.

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write tests for new functionality
5. Run tests (`flutter test`)
6. Commit changes (`git commit -m 'feat: add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

See [DEVELOPMENT.md](DEVELOPMENT.md) for coding guidelines.

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [FFmpeg](https://ffmpeg.org) - Video processing engine
- [ffmpeg_kit_flutter_new](https://pub.dev/packages/ffmpeg_kit_flutter_new) - Mobile FFmpeg bindings
- [media_kit](https://pub.dev/packages/media_kit) - Video playback

---

## Support

- **Issues**: [GitHub Issues](https://github.com/AtelierMizumi/FFmpeg-Converter-App/issues)
- **Discussions**: [GitHub Discussions](https://github.com/AtelierMizumi/FFmpeg-Converter-App/discussions)
- **Documentation**: See [SETUP.md](SETUP.md) and [DEVELOPMENT.md](DEVELOPMENT.md)

---

Built with ❤️ using [Flutter](https://flutter.dev)
