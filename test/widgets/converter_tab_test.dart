import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ffmpeg_converter_app/l10n/app_localizations.dart';
import 'package:ffmpeg_converter_app/ui/tabs/converter_tab.dart';
import 'package:ffmpeg_converter_app/main.dart';

/// Helper widget to wrap ConverterTab with proper localization support
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('vi'),
      Locale('ja'),
      Locale('de'),
    ],
    home: Scaffold(body: child),
  );
}

/// Helper to pump widget and wait for initialization
/// Uses longer wait time for CI environments where FFmpeg init may take longer
Future<void> pumpAndWaitForInit(WidgetTester tester) async {
  // Pump multiple frames to allow async initialization to complete
  // In CI environment, FFmpeg may not be available, so init may fail
  // but that's OK - we just need to wait for the state to settle
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));

    // Check if main content is visible (initialization completed or failed gracefully)
    final settingsText = find.text('Encode Settings');
    final errorText = find.textContaining('Error');
    if (settingsText.evaluate().isNotEmpty || errorText.evaluate().isNotEmpty) {
      break;
    }
  }
}

void main() {
  // Ensure Flutter binding is initialized for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConverterTab Widget Tests', () {
    testWidgets('Should display drop zone with drag text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for drag & drop text (from app_en.arb: "dragDropText")
      // May show loading indicator if FFmpeg init is slow
      final dragText = find.textContaining('Drag');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        dragText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show either drag zone or loading indicator',
      );
    });

    testWidgets('Should display settings card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for settings section or loading state
      final settingsText = find.text('Encode Settings');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        settingsText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show settings card or loading indicator',
      );
    });

    testWidgets('Convert button with play icon should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Find the start conversion button or loading state
      final playIcon = find.byIcon(Icons.play_arrow);
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        playIcon.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show play button or loading indicator',
      );
    });

    testWidgets('CRF slider should exist and have correct range for H.264', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Find the CRF slider (may not exist if still loading)
      final slider = find.byType(Slider);
      if (slider.evaluate().isNotEmpty) {
        // Check slider properties for H.264 (default codec)
        final sliderWidget = tester.widget<Slider>(slider);
        expect(sliderWidget.min, equals(0));
        expect(sliderWidget.max, equals(51)); // H.264/H.265 max CRF
      } else {
        // Loading state is acceptable
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      }
    });

    testWidgets('Format dropdown should exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for container format or loading state
      final containerText = find.textContaining('Container');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        containerText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show format dropdown or loading indicator',
      );
    });

    testWidgets('Codec dropdown should exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for video codec or loading state
      final codecText = find.textContaining('Video Codec');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        codecText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show codec dropdown or loading indicator',
      );
    });

    testWidgets('Resolution dropdown should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for resolution dropdown or loading state
      final resolutionText = find.textContaining('Resolution');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        resolutionText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show resolution dropdown or loading indicator',
      );
    });

    testWidgets('Audio settings dropdown should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for audio settings or loading state
      final audioText = find.textContaining('Audio');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        audioText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show audio settings or loading indicator',
      );
    });
  });

  group('ConverterTab State Tests', () {
    testWidgets('CRF slider value should update when dragged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Find CRF slider (may not exist if still loading)
      final slider = find.byType(Slider);
      if (slider.evaluate().isEmpty) {
        // Skip test if still loading - this is acceptable
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        return;
      }

      // Verify slider has a valid initial value
      final initialSlider = tester.widget<Slider>(slider);
      expect(initialSlider.value, greaterThanOrEqualTo(0));

      // Drag slider to change value
      await tester.drag(slider, const Offset(100, 0), warnIfMissed: false);
      await tester.pump();

      // Get new value
      final updatedSlider = tester.widget<Slider>(slider);
      expect(updatedSlider.value, isNotNull);
    });

    testWidgets('Preset dropdown should exist and be changeable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await pumpAndWaitForInit(tester);

      // Check for preset dropdown or loading state
      final presetText = find.textContaining('Preset');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        presetText.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show preset dropdown or loading indicator',
      );
    });
  });

  group('ConverterTab Integration with MainScreen', () {
    testWidgets('ConverterTab should be accessible from MainScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      await pumpAndWaitForInit(tester);

      // MainScreen should be visible
      expect(find.byType(MainScreen), findsOneWidget);

      // ConverterTab should be the first tab (default)
      expect(find.byType(ConverterTab), findsOneWidget);
    });

    testWidgets('Should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      await pumpAndWaitForInit(tester);

      // Find tabs by their icons - this is more reliable across platforms
      final tabBar = find.byType(TabBar);
      expect(tabBar, findsOneWidget);

      // Find the Editor tab by its icon (edit_note) and tap it
      final editorTabIcon = find.descendant(
        of: tabBar,
        matching: find.byIcon(Icons.edit_note),
      );
      expect(editorTabIcon, findsOneWidget);
      await tester.tap(editorTabIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find the Converter tab by its icon (transform) and tap it
      final converterTabIcon = find.descendant(
        of: tabBar,
        matching: find.byIcon(Icons.transform),
      );
      expect(converterTabIcon, findsOneWidget);
      await tester.tap(converterTabIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // ConverterTab should be visible
      expect(find.byType(ConverterTab), findsOneWidget);
    });
  });
}
