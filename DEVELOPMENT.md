# Development Guide

Comprehensive guide to understanding and developing the FFmpeg Converter App.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Core Components](#core-components)
- [Platform-Specific Implementation](#platform-specific-implementation)
- [Recent Changes](#recent-changes)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style](#code-style)
- [Adding New Features](#adding-new-features)

---

## Project Overview

### What is FFmpeg Converter App?

A cross-platform video conversion application that:
- Converts videos between formats (MP4, WebM, MKV, MOV)
- Adjusts quality, resolution, and audio settings
- Trims and merges video clips
- Provides video comparison tools
- Supports multiple languages (English, Vietnamese, German, Japanese)

### Supported Platforms

| Platform | Status | FFmpeg Implementation |
|----------|--------|----------------------|
| Windows  | ✅ Full Support | Bundled FFmpeg binary |
| Linux    | ✅ Full Support | Bundled FFmpeg binary |
| macOS    | ✅ Full Support | Bundled FFmpeg binary |
| Android  | ✅ Full Support | ffmpeg_kit_flutter_new |
| iOS      | ✅ Partial Support | ffmpeg_kit_flutter_new |
| Web      | ✅ Limited Support | ffmpeg_wasm (500MB limit) |

### Technology Stack

- **Framework**: Flutter 3.24+ / Dart 3.10.7+
- **FFmpeg**: 
  - Desktop: Native binaries (v6.0+)
  - Mobile: ffmpeg_kit_flutter_new v4.1.0 (FFmpeg v8.0.0)
  - Web: ffmpeg_wasm v1.0.3
- **Video Playback**: media_kit v1.2.6 (mpv backend)
- **State Management**: Built-in setState (no external state management)
- **Localization**: flutter_localizations + intl
- **Analytics**: Custom Cloudflare Workers backend

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ ConverterTab│  │  EditorTab  │  │ Landing Page│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          FFmpegServiceInterface                       │  │
│  │  (Abstract contract for all platforms)               │  │
│  └──────────────────────────────────────────────────────┘  │
│           │              │              │                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │  Desktop   │  │   Mobile   │  │    Web     │          │
│  │  Service   │  │  Service   │  │  Service   │          │
│  └────────────┘  └────────────┘  └────────────┘          │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │ Analytics  │  │ Validator  │  │   Error    │          │
│  │  Service   │  │  Service   │  │  Reporter  │          │
│  └────────────┘  └────────────┘  └────────────┘          │
└─────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│                    Platform Layer                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │   FFmpeg   │  │  FFmpeg    │  │  FFmpeg    │          │
│  │   Binary   │  │    Kit     │  │   WASM     │          │
│  │  (Desktop) │  │  (Mobile)  │  │   (Web)    │          │
│  └────────────┘  └────────────┘  └────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Design Patterns

1. **Factory Pattern**: `FFmpegServiceFactory` creates platform-specific service instances
2. **Interface/Abstract Class**: `FFmpegServiceInterface` defines contract
3. **Singleton**: `AnalyticsService.instance` for global analytics access
4. **Strategy Pattern**: Different FFmpeg execution strategies per platform
5. **Observer Pattern**: Callbacks for progress updates during conversion

---

## Directory Structure

```
FFmpeg-Converter-App/
├── .github/
│   └── workflows/
│       ├── automated_tests.yml    # CI/CD testing pipeline
│       └── build_and_release.yml  # Build and release automation
├── android/                       # Android-specific configuration
│   └── app/
│       ├── build.gradle.kts       # Build configuration
│       └── src/main/
│           └── AndroidManifest.xml # Permissions & app config
├── assets/
│   └── bin/
│       ├── linux/                 # FFmpeg binary for Linux
│       └── windows/               # FFmpeg binary for Windows
├── docs/
│   └── FFMPEG_OPTIMIZATION.md     # FFmpeg usage tips
├── lib/
│   ├── config/
│   │   └── analytics_config.dart  # Analytics configuration
│   ├── l10n/                      # Localization files (auto-generated)
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_vi.dart
│   │   ├── app_localizations_de.dart
│   │   └── app_localizations_ja.dart
│   ├── models/                    # Data models
│   │   ├── analytics_error.dart
│   │   ├── analytics_event.dart
│   │   └── analytics_session.dart
│   ├── services/                  # Business logic layer
│   │   ├── ffmpeg_service.dart            # Factory for creating services
│   │   ├── ffmpeg_service_interface.dart  # Abstract interface
│   │   ├── ffmpeg_service_desktop.dart    # Windows/Linux/macOS impl
│   │   ├── ffmpeg_service_mobile.dart     # Android/iOS impl
│   │   ├── ffmpeg_service_web.dart        # Web impl
│   │   ├── ffmpeg_service_stub.dart       # Stub for unsupported platforms
│   │   ├── analytics_service.dart         # Analytics orchestrator
│   │   ├── device_info_service.dart       # Device information
│   │   ├── error_reporter.dart            # Error tracking
│   │   ├── event_tracker.dart             # Event tracking
│   │   ├── network_service.dart           # Network requests
│   │   ├── session_manager.dart           # Session management
│   │   └── video_validator.dart           # Input validation
│   ├── ui/                        # User interface
│   │   ├── editor/
│   │   │   └── editor_tab.dart            # Video trim/merge UI
│   │   ├── landing/
│   │   │   └── landing_page.dart          # Web landing page
│   │   ├── tabs/
│   │   │   ├── converter_tab.dart         # Main conversion UI
│   │   │   ├── credits_tab.dart           # About/Credits
│   │   │   └── guide_tab.dart             # User guide
│   │   └── widgets/
│   │       └── video_comparison.dart      # Video comparison tool
│   ├── utils/
│   │   └── crypto_utils.dart      # Cryptography utilities
│   └── main.dart                  # App entry point
├── linux/                         # Linux desktop configuration
├── macos/                         # macOS configuration
├── scripts/
│   ├── run_tests.ps1              # Windows test runner
│   └── run_tests.sh               # Linux/macOS test runner
├── test/                          # Unit & widget tests
│   ├── services/
│   │   └── ffmpeg_service_mobile_test.dart
│   ├── widgets/
│   │   └── converter_tab_test.dart
│   └── README.md                  # Testing documentation
├── web/                           # Web-specific files
├── windows/                       # Windows desktop configuration
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore rules
├── BUILD.md                       # Build instructions
├── DEVELOPMENT.md                 # This file
├── README.md                      # Project overview
├── SETUP.md                       # Environment setup guide
├── build-android-java17.sh        # Android build script
├── build-linux-portable.sh        # Linux build script
├── build-windows-portable.bat     # Windows build script
└── pubspec.yaml                   # Dependencies & project config
```

---

## Core Components

### 1. Service Layer

#### FFmpegServiceInterface (`lib/services/ffmpeg_service_interface.dart`)

Abstract interface defining the contract for all FFmpeg implementations:

```dart
abstract class FFmpegServiceInterface {
  // Core conversion method
  Future<void> convertVideo({
    required String inputPath,
    required String outputPath,
    required String format,
    required String codec,
    required String preset,
    required int crf,
    required String resolution,
    required String audioOption,
    String? customResolution,
    Function(double)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  });

  // Video information
  Future<double> getVideoDuration(String videoPath);

  // Control methods
  void cancel();
  bool isProcessing();
}
```

#### FFmpegServiceDesktop (`lib/services/ffmpeg_service_desktop.dart`)

Desktop implementation (Windows/Linux/macOS):

**Key Features:**
- Executes bundled FFmpeg binary via `Process.start()`
- Parses FFmpeg stderr output for progress calculation
- Extracts video duration using `ffprobe` (or FFmpeg `-i` output)
- Supports all FFmpeg features (no limitations)
- Cancellation via `Process.kill()`

**FFmpeg Command Structure:**
```dart
String buildCommand() {
  return '-i "$inputPath" '           // Input file
         '-c:v $codec '                // Video codec
         '-preset $preset '            // Encoding speed
         '-crf $crf '                  // Quality (lower = better)
         '-vf scale=$resolution '      // Resolution
         '$audioOption '               // Audio settings
         '"$outputPath"';              // Output file
}
```

**Progress Tracking:**
```dart
// Parse FFmpeg output: "time=00:01:23.45"
final timeMatch = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)').firstMatch(line);
if (timeMatch != null) {
  final currentSeconds = parseTime(timeMatch);
  final progress = (currentSeconds / totalDuration) * 100;
  onProgress?.call(progress);
}
```

#### FFmpegServiceMobile (`lib/services/ffmpeg_service_mobile.dart`)

Mobile implementation (Android/iOS) using `ffmpeg_kit_flutter_new`:

**Key Features:**
- Uses `FFmpegKit.executeAsync()` for non-blocking execution
- Progress callbacks via `StatisticsCallback`
- Duration detection via `FFprobeKit.getMediaInformation()`
- Memory-efficient: callbacks disabled after completion
- Error handling for callback registration failures

**Recent Improvements (Commit 08dd601):**
- Fixed memory leak by disabling callbacks after conversion
- Added proper error handling for FFmpeg callback registration
- Implemented real video duration detection
- Removed conflicting `manageExternalStorage` permission request

**Example Usage:**
```dart
await FFmpegKit.executeAsync(
  command,
  (session) async {
    // Completion callback
    final returnCode = await session.getReturnCode();
    if (returnCode?.isValueSuccess() == true) {
      onComplete?.call();
    } else {
      onError?.call('Conversion failed');
    }
    // Disable callbacks to prevent memory leak
    FFmpegKitConfig.disableStatisticsCallback();
  },
  null, // Log callback (optional)
  (statistics) {
    // Progress callback
    final time = statistics.getTime();
    if (time > 0 && _videoDuration > 0) {
      final progress = (time / (_videoDuration * 1000)) * 100;
      onProgress?.call(progress.clamp(0, 100));
    }
  },
);
```

#### FFmpegServiceWeb (`lib/services/ffmpeg_service_web.dart`)

Web implementation using `ffmpeg_wasm`:

**Key Features:**
- Runs FFmpeg compiled to WebAssembly
- **500MB file size limit** (browser memory constraints)
- Slower than native implementations
- No installation required for users

**Limitations:**
- No hardware acceleration
- Limited codec support
- High memory usage
- Slower encoding speeds

#### VideoValidator (`lib/services/video_validator.dart`)

Input validation service:

**Recent Improvements (Commit 08dd601):**
- Added 2GB file size warning for mobile platforms
- Platform-specific validation rules
- Improved user feedback for large files

**Validation Rules:**
```dart
// Web: 500MB limit (hard limit)
if (kIsWeb && fileSize > 500 * 1024 * 1024) {
  return 'File too large for web (max 500MB)';
}

// Mobile: 2GB warning (soft limit)
if (isMobile && fileSize > 2 * 1024 * 1024 * 1024) {
  // Show warning dialog but allow conversion
  showWarningDialog();
}

// Desktop: No file size limit
```

### 2. UI Layer

#### ConverterTab (`lib/ui/tabs/converter_tab.dart`)

Main conversion interface:

**Features:**
- Drag & drop file selection
- Output folder picker (desktop only)
- Format, codec, preset, quality controls
- Resolution selector
- Audio options (transcode, copy, mute)
- Real-time progress bar
- Permission handling (Android 13+)

**Recent Changes (Commit 08dd601):**
- Removed conflicting `manageExternalStorage` permission request
- Improved Android 13+ permission flow
- Added file size warnings

**State Management:**
```dart
class _ConverterTabState extends State<ConverterTab> {
  File? _selectedFile;
  String? _outputDirectory;
  double _conversionProgress = 0.0;
  bool _isConverting = false;
  
  void _handleFileSelection(XFile file) async {
    // Validate file
    final validation = await VideoValidator.validate(file);
    if (validation.isValid) {
      setState(() {
        _selectedFile = File(file.path);
      });
    } else {
      _showError(validation.errorMessage);
    }
  }
}
```

#### EditorTab (`lib/ui/editor/editor_tab.dart`)

Video editing interface (trim/merge):

**Features:**
- Video trimming with start/end time selection
- Video merging (combine multiple clips)
- Real-time video preview using media_kit
- Timeline slider for precise control

**Recent Changes (Commit 08dd601):**
- Replaced hardcoded 300s duration with real video duration detection
- Accurate trim range calculation
- Better user feedback for long videos

**Duration Detection:**
```dart
Future<void> _loadVideoDuration() async {
  final ffmpegService = FFmpegServiceFactory.getService();
  final duration = await ffmpegService.getVideoDuration(_videoPath);
  setState(() {
    _videoDuration = duration;
    _endTime = duration; // Set end time to full duration
  });
}
```

#### LandingPage (`lib/ui/landing/landing_page.dart`)

Web-only landing page with feature highlights, benefits, and call-to-action.

### 3. Analytics System

#### Architecture

```
┌──────────────┐
│ UI Component │
└──────┬───────┘
       │ Track event
       ▼
┌──────────────────────┐
│ AnalyticsService     │
│ (Singleton)          │
└──────┬───────────────┘
       │
       ├─► SessionManager     (Manages user sessions)
       ├─► EventTracker       (Queues events)
       ├─► ErrorReporter      (Handles errors)
       ├─► DeviceInfoService  (Collects device info)
       ├─► NetworkService     (Sends to backend)
       └─► CryptoUtils        (Signs requests)
                │
                ▼
        ┌──────────────────┐
        │ Cloudflare Worker│
        │ (Backend API)    │
        └──────────────────┘
```

#### Usage Example

```dart
// Track conversion event
await AnalyticsService.instance.trackEvent(
  eventType: 'video_conversion',
  properties: {
    'format': format,
    'codec': codec,
    'resolution': resolution,
    'file_size': fileSize,
    'duration': duration,
  },
);

// Track errors
await AnalyticsService.instance.trackError(
  error: exception,
  stackTrace: stackTrace,
  context: 'video_conversion',
);
```

---

## Platform-Specific Implementation

### Desktop (Windows/Linux/macOS)

**FFmpeg Binary Location:**
```
assets/bin/windows/ffmpeg.exe
assets/bin/linux/ffmpeg
```

**Binary Loading:**
```dart
// Extract bundled FFmpeg to temp directory
final ffmpegPath = await _extractFFmpegBinary();

// Execute
final process = await Process.start(ffmpegPath, arguments);
```

**Build Commands:**
```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

### Android

**Minimum SDK**: API 24 (Android 7.0)  
**Target SDK**: API 34 (Android 14)

**Dependencies:**
```yaml
ffmpeg_kit_flutter_new: ^4.1.0  # FFmpeg v8.0.0
permission_handler: ^12.0.1
```

**Permissions (`AndroidManifest.xml`):**
```xml
<!-- Android 13+ Granular Permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Internet for analytics -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Build Command:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Key Considerations:**
- File size limit: 2GB recommended (soft limit)
- Slower encoding than desktop (mobile CPUs)
- Storage permissions required (handled by permission_handler)
- Use efficient presets (ultrafast, superfast) for better UX

### iOS

**Minimum iOS**: 12.0  
**FFmpeg**: Same as Android (ffmpeg_kit_flutter_new)

**Build Command:**
```bash
flutter build ios --release
```

**Considerations:**
- Requires Apple Developer account for distribution
- Code signing required
- App Store review process

### Web

**FFmpeg Implementation**: ffmpeg_wasm v1.0.3

**Limitations:**
- **500MB file size limit** (hard limit)
- No hardware acceleration
- Slower encoding (runs in JavaScript)
- High memory usage

**Build Command:**
```bash
flutter build web --release
# Output: build/web/
```

**Deployment:**
- GitHub Pages (automatic via CI/CD)
- Any static hosting service (Netlify, Vercel, etc.)

---

## Recent Changes

### Commit History (Last 5 commits)

#### 1. `08dd601` - fix: resolve critical bugs and improve mobile stability
**Date**: Today  
**Changes**:
- Removed `manageExternalStorage` permission conflict
- Fixed memory leak (FFmpeg callbacks not disabled)
- Implemented real video duration detection
- Added 2GB file size warning for mobile
- Enhanced error handling for FFmpeg callbacks

**Files Modified**:
- `lib/services/ffmpeg_service_interface.dart` - Added `getVideoDuration()` method
- `lib/services/ffmpeg_service_mobile.dart` - Error handling + memory leak fix + duration detection
- `lib/services/ffmpeg_service_desktop.dart` - Added duration detection
- `lib/services/ffmpeg_service_web.dart` - Added duration detection stub
- `lib/services/video_validator.dart` - 2GB mobile warning
- `lib/ui/tabs/converter_tab.dart` - Fixed permissions
- `lib/ui/editor/editor_tab.dart` - Real duration detection

#### 2. `e7509c2` - feat: enable Android video conversion with comprehensive testing
**Date**: Recent  
**Changes**:
- Enabled mobile support (removed platform detection barrier)
- Rewrote `FFmpegServiceMobile` using `ffmpeg_kit_flutter_new`
- Updated Android permissions for Android 13+ compliance
- Added comprehensive testing infrastructure
- Changed default locale to English
- Fixed cancel method bug in desktop service

**Files Modified**:
- `lib/main.dart` - Enabled mobile support
- `lib/services/ffmpeg_service_mobile.dart` - Complete rewrite
- `android/app/src/main/AndroidManifest.xml` - Modern permissions
- `pubspec.yaml` - Added `ffmpeg_kit_flutter_new`
- `.github/workflows/automated_tests.yml` - CI/CD testing
- `test/services/ffmpeg_service_mobile_test.dart` - Unit tests (NEW)
- `test/widgets/converter_tab_test.dart` - Widget tests (NEW)

#### 3. `d8d933a` - feat: Add video editing features with trim and merge
**Date**: Recent  
**Changes**:
- Created EditorTab for video trimming and merging
- Integrated media_kit for video playback
- Added timeline controls for precise editing

**Files Modified**:
- `lib/ui/editor/editor_tab.dart` - NEW
- `lib/main.dart` - Added EditorTab to navigation

#### 4. `871cd02` - feat: Add permission handling and event channel for FFmpeg
**Date**: Recent  
**Changes**:
- Implemented permission_handler for Android storage
- Added event channel for FFmpeg progress updates

**Impact**: Foundation for mobile support

#### 5. Earlier commits
- Project setup and initial features
- Desktop implementation (Windows/Linux)
- Web support with ffmpeg_wasm
- Localization support
- Analytics system

---

## Development Workflow

### 1. Setting Up Development Environment

See `SETUP.md` for detailed instructions.

**Quick setup:**
```bash
git clone https://github.com/AtelierMizumi/FFmpeg-Converter-App.git
cd FFmpeg-Converter-App
flutter pub get
cp .env.example .env
flutter run -d windows  # or linux, macos, android, chrome
```

### 2. Branch Strategy

- `main` - Production-ready code
- Feature branches: `feature/feature-name`
- Bug fixes: `fix/bug-description`
- Documentation: `docs/update-name`

### 3. Making Changes

**Step 1: Create feature branch**
```bash
git checkout -b feature/new-feature
```

**Step 2: Make changes**
- Follow code style guidelines (see below)
- Write tests for new functionality
- Update documentation if needed

**Step 3: Test changes**
```bash
# Run tests
flutter test

# Run specific test file
flutter test test/services/ffmpeg_service_mobile_test.dart

# Test on multiple platforms
flutter run -d windows
flutter run -d android
```

**Step 4: Commit**
```bash
git add .
git commit -m "feat: add new feature description"
```

**Commit message format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `test:` - Adding/updating tests
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `chore:` - Maintenance tasks

**Step 5: Push and create PR**
```bash
git push origin feature/new-feature
# Create Pull Request on GitHub
```

### 4. Code Review Process

1. Automated tests run via GitHub Actions
2. Code review by maintainer
3. Address feedback
4. Merge to main
5. Automatic build and release

---

## Testing

### Test Structure

```
test/
├── services/                      # Unit tests for services
│   └── ffmpeg_service_mobile_test.dart
├── widgets/                       # Widget tests for UI
│   └── converter_tab_test.dart
└── README.md                      # Testing documentation
```

### Running Tests

**All tests:**
```bash
flutter test
```

**With coverage:**
```bash
flutter test --coverage
```

**Specific test file:**
```bash
flutter test test/services/ffmpeg_service_mobile_test.dart
```

**Using test scripts:**
```bash
# Windows
./scripts/run_tests.ps1

# Linux/macOS
./scripts/run_tests.sh
```

### Writing Tests

**Unit Test Example:**
```dart
// test/services/my_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ffmpeg_converter_app/services/my_service.dart';

void main() {
  group('MyService', () {
    test('should return expected value', () {
      final service = MyService();
      final result = service.doSomething();
      expect(result, equals(expectedValue));
    });
  });
}
```

**Widget Test Example:**
```dart
// test/widgets/my_widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ffmpeg_converter_app/ui/widgets/my_widget.dart';

void main() {
  testWidgets('MyWidget renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyWidget()),
    );
    
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

### CI/CD Testing

Automated tests run on every push/PR via GitHub Actions:
- Unit tests on all platforms
- Widget tests
- Build tests (Linux, Windows, macOS, Android, Web)
- Code analysis (`flutter analyze`)

See `.github/workflows/automated_tests.yml`

---

## Code Style

### Dart Style Guide

Follow official Dart style guide: https://dart.dev/guides/language/effective-dart

**Key conventions:**
- Use `lowerCamelCase` for variables, functions, parameters
- Use `UpperCamelCase` for classes, enums, typedefs
- Use `snake_case` for file names
- Prefer `final` over `var` when value doesn't change
- Use trailing commas for better formatting
- Maximum line length: 80 characters (flexible to 100)

**Example:**
```dart
class MyService {
  final String _privateField;
  
  MyService(this._privateField);
  
  Future<String> doSomething({
    required String param1,
    required int param2,
  }) async {
    // Implementation
    return 'result';
  }
}
```

### Code Formatting

**Auto-format:**
```bash
dart format .
```

**Configure VS Code:**
```json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.rulers": [80]
  }
}
```

### Linting

Project uses `flutter_lints` for static analysis.

**Run linter:**
```bash
flutter analyze
```

**Common lint rules:**
- `avoid_print` - Use `debugPrint` instead
- `prefer_const_constructors` - Use const when possible
- `require_trailing_commas` - Add trailing commas
- `always_use_package_imports` - Use package: imports

---

## Adding New Features

### Example: Adding a New Codec

**Step 1: Update UI**

`lib/ui/tabs/converter_tab.dart`:
```dart
final codecs = ['libx264', 'libx265', 'libvpx-vp9', 'libaom-av1', 'new_codec'];
```

**Step 2: Update FFmpeg Command Builder**

`lib/services/ffmpeg_service_desktop.dart`:
```dart
String _buildFFmpegCommand() {
  // Add codec-specific parameters
  if (codec == 'new_codec') {
    return '-c:v new_codec -custom_param value ...';
  }
  // Existing logic
}
```

**Step 3: Update Validation**

`lib/services/video_validator.dart`:
```dart
bool isSupportedCodec(String codec) {
  return ['libx264', 'libx265', 'libvpx-vp9', 'libaom-av1', 'new_codec']
      .contains(codec);
}
```

**Step 4: Add Tests**

`test/services/ffmpeg_service_test.dart`:
```dart
test('should support new_codec', () {
  final command = service.buildCommand(codec: 'new_codec');
  expect(command, contains('new_codec'));
});
```

**Step 5: Update Documentation**

- Update README.md with supported codecs
- Add codec description to guide_tab.dart

### Example: Adding a New Platform

**Step 1: Create Service Implementation**

`lib/services/ffmpeg_service_newplatform.dart`:
```dart
import 'ffmpeg_service_interface.dart';

class FFmpegServiceNewPlatform implements FFmpegServiceInterface {
  @override
  Future<void> convertVideo({...}) async {
    // Platform-specific implementation
  }
  
  @override
  Future<double> getVideoDuration(String videoPath) async {
    // Implementation
  }
  
  @override
  void cancel() {
    // Cancel logic
  }
  
  @override
  bool isProcessing() => _isProcessing;
}
```

**Step 2: Update Factory**

`lib/services/ffmpeg_service.dart`:
```dart
import 'ffmpeg_service_newplatform.dart'
    if (dart.library.io) 'ffmpeg_service_desktop.dart'
    if (dart.library.html) 'ffmpeg_service_web.dart';

class FFmpegServiceFactory {
  static FFmpegServiceInterface getService() {
    if (Platform.isNewPlatform) {
      return FFmpegServiceNewPlatform();
    }
    // Existing logic
  }
}
```

**Step 3: Add Platform Detection**

`lib/main.dart`:
```dart
if (Platform.isNewPlatform) {
  // Platform-specific initialization
}
```

**Step 4: Update Build Configuration**

Create `newplatform/` directory with platform-specific files.

**Step 5: Add CI/CD Support**

`.github/workflows/build_and_release.yml`:
```yaml
build-newplatform:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    - run: flutter build newplatform --release
```

---

## Best Practices

### 1. Error Handling

**Always handle errors gracefully:**
```dart
try {
  await ffmpegService.convertVideo(...);
} catch (e, stackTrace) {
  debugPrint('Conversion failed: $e');
  await AnalyticsService.instance.trackError(
    error: e,
    stackTrace: stackTrace,
    context: 'video_conversion',
  );
  // Show user-friendly error message
  _showErrorDialog('Conversion failed. Please try again.');
}
```

### 2. Memory Management

**Dispose resources:**
```dart
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

**Cancel ongoing operations:**
```dart
void _cancelConversion() {
  ffmpegService.cancel();
  setState(() {
    _isConverting = false;
  });
}
```

### 3. Async/Await

**Prefer async/await over then():**
```dart
// Good
Future<void> loadData() async {
  final data = await fetchData();
  setState(() {
    _data = data;
  });
}

// Avoid
Future<void> loadData() {
  return fetchData().then((data) {
    setState(() {
      _data = data;
    });
  });
}
```

### 4. State Management

**Use setState for local state:**
```dart
void _updateProgress(double progress) {
  setState(() {
    _progress = progress;
  });
}
```

**Consider StatefulWidget lifecycle:**
```dart
@override
void initState() {
  super.initState();
  _initialize();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Update when dependencies change
}

@override
void dispose() {
  _cleanup();
  super.dispose();
}
```

### 5. Localization

**Use AppLocalizations:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.convertButton);
```

**Add new strings:**

1. Update `lib/l10n/app_en.arb`:
```json
{
  "newString": "New String",
  "@newString": {
    "description": "Description of new string"
  }
}
```

2. Translate to other languages (app_vi.arb, app_de.arb, app_ja.arb)

3. Rebuild:
```bash
flutter pub get
# Localization files auto-generated
```

---

## Debugging Tips

### 1. FFmpeg Command Debugging

**Print commands before execution:**
```dart
debugPrint('FFmpeg command: $command');
await FFmpegKit.executeAsync(command, ...);
```

### 2. Progress Tracking Debugging

**Log progress values:**
```dart
void _handleProgress(double progress) {
  debugPrint('Progress: ${progress.toStringAsFixed(2)}%');
  setState(() {
    _progress = progress;
  });
}
```

### 3. Platform-Specific Debugging

**Check platform at runtime:**
```dart
if (kIsWeb) {
  debugPrint('Running on Web');
} else if (Platform.isAndroid) {
  debugPrint('Running on Android');
} else if (Platform.isWindows) {
  debugPrint('Running on Windows');
}
```

### 4. Flutter DevTools

**Launch DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Features:**
- Widget Inspector
- Memory profiler
- Performance view
- Network inspector

---

## Resources

### Official Documentation
- Flutter: https://docs.flutter.dev
- Dart: https://dart.dev/guides
- FFmpeg: https://ffmpeg.org/documentation.html

### Project-Specific
- SETUP.md - Environment setup
- BUILD.md - Build instructions
- test/README.md - Testing guide
- docs/FFMPEG_OPTIMIZATION.md - FFmpeg tips

### Community
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: [flutter] tag
- GitHub Issues: https://github.com/AtelierMizumi/FFmpeg-Converter-App/issues

---

**Last Updated**: February 2026  
**Flutter Version**: 3.24+  
**Dart Version**: 3.10.7+
