# FFmpeg Converter App - Testing Guide

## 📋 Test Suite Overview

This project includes comprehensive automated testing:

- **Unit Tests** - Test individual functions and classes
- **Widget Tests** - Test UI components and interactions
- **Integration Tests** - Test complete workflows
- **CI/CD Tests** - Automated testing on every commit

## 🚀 Quick Start

### Run All Tests

**Windows (PowerShell):**
```powershell
.\scripts\run_tests.ps1
```

**Linux/macOS:**
```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

**Or use Flutter directly:**
```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

Coverage report will be saved to `coverage/lcov.info`

### Run Specific Tests

```bash
# Run a single test file
flutter test test/services/ffmpeg_service_mobile_test.dart

# Run tests in a directory
flutter test test/widgets/

# Run tests matching a pattern
flutter test --name "VideoValidator"
```

### Run Tests in Watch Mode

```bash
flutter test --watch
```

Tests will re-run automatically when files change.

## 📊 Test Structure

```
test/
├── services/
│   ├── ffmpeg_service_mobile_test.dart    # FFmpeg service tests
│   └── video_validator_test.dart          # (Already in widget_test.dart)
├── widgets/
│   ├── converter_tab_test.dart             # Converter tab UI tests
│   └── editor_tab_test.dart                # (Future)
└── widget_test.dart                        # Main app widget tests
```

## ✅ Test Coverage Goals

| Component | Current | Goal |
|-----------|---------|------|
| Services | 🟡 Medium | 🟢 80%+ |
| Widgets | 🟡 Medium | 🟢 70%+ |
| Utils | 🟢 High | 🟢 90%+ |
| Overall | 🟡 Medium | 🟢 75%+ |

## 🔍 What We Test

### Unit Tests

- ✅ Video format validation
- ✅ File size validation  
- ✅ CRF range validation
- ✅ Codec compatibility
- ✅ FFmpeg command building
- ✅ Progress parsing

### Widget Tests

- ✅ UI component rendering
- ✅ User interactions (buttons, sliders, dropdowns)
- ✅ State management
- ✅ Form validation
- ✅ Error handling
- ✅ Navigation between tabs

### Integration Tests

- ✅ Complete conversion workflow
- ✅ File picker integration
- ✅ Platform-specific features
- ✅ Multi-platform builds

## 🤖 CI/CD Automation

Tests run automatically on:

- ✅ Every push to `main` or `develop` branches
- ✅ Every pull request
- ✅ Manual workflow dispatch

### Automated Checks

1. **Code Quality**
   - Dart formatting check
   - Static analysis
   - Linting

2. **Unit & Widget Tests**
   - Run on Linux, Windows, macOS
   - Generate coverage reports
   - Upload to Codecov

3. **Platform Builds**
   - Build for Web
   - Build for Android
   - Build for Windows, Linux, macOS

4. **Security Scan**
   - Check for outdated dependencies
   - Scan for vulnerabilities

## 📈 Viewing Coverage Reports

### Generate HTML Report (requires lcov)

**Install lcov:**
```bash
# Ubuntu/Debian
sudo apt-get install lcov

# macOS
brew install lcov

# Windows (Chocolatey)
choco install lcov
```

**Generate report:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**View report:**
```bash
# Linux/macOS
open coverage/html/index.html

# Windows
start coverage/html/index.html
```

### View Coverage on Codecov

Coverage reports are automatically uploaded to Codecov on CI/CD runs.

View at: `https://codecov.io/gh/[your-username]/FFmpeg-Converter-App`

## 🐛 Debugging Tests

### Run Tests with Verbose Output

```bash
flutter test --verbose
```

### Run Single Test

```bash
flutter test test/services/ffmpeg_service_mobile_test.dart
```

### Debug in VS Code

1. Open test file
2. Click "Debug" above the test
3. Or press F5 with test file open

## 📝 Writing New Tests

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyService Tests', () {
    test('Should do something', () {
      // Arrange
      final service = MyService();
      
      // Act
      final result = service.doSomething();
      
      // Assert
      expect(result, equals(expected));
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should display widget', (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyWidget(),
      ),
    );
    
    // Verify
    expect(find.text('Hello'), findsOneWidget);
    
    // Interact
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // Verify state change
    expect(find.text('Clicked'), findsOneWidget);
  });
}
```

## 🎯 Best Practices

1. **Test First** - Write tests before implementing features (TDD)
2. **Descriptive Names** - Use clear test names: "Should reject invalid file format"
3. **One Assert per Test** - Each test should verify one specific behavior
4. **Use Groups** - Organize related tests with `group()`
5. **Mock External Dependencies** - Don't rely on real file system, network, etc.
6. **Fast Tests** - Tests should run quickly (< 1s each)
7. **Independent Tests** - Tests should not depend on each other

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Package](https://pub.dev/packages/mockito)

## 🤝 Contributing

When submitting PRs:

1. ✅ All tests must pass
2. ✅ Add tests for new features
3. ✅ Maintain or improve coverage
4. ✅ Follow existing test patterns

Run tests before committing:
```bash
flutter test && flutter analyze
```

## 📞 Support

If tests fail:

1. Check error messages carefully
2. Run single test to isolate issue
3. Check if dependencies are up to date: `flutter pub get`
4. Verify Flutter SDK version: `flutter --version`
5. Clean build: `flutter clean && flutter pub get`

---

**Happy Testing! 🧪**
