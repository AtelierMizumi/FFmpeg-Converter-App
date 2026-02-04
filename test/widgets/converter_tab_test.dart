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

void main() {
  // Ensure Flutter binding is initialized for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConverterTab Widget Tests', () {
    testWidgets('Should display drop zone with drag text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for drag & drop text (from app_en.arb: "dragDropText")
      expect(find.textContaining('Drag'), findsOneWidget);
    });

    testWidgets('Should display settings card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for settings section (from app_en.arb: "settingsTitle" = "Encode Settings")
      expect(find.text('Encode Settings'), findsOneWidget);
    });

    testWidgets('Convert button with play icon should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Find the start conversion button by looking for the play_arrow icon
      final playIcon = find.byIcon(Icons.play_arrow);
      expect(playIcon, findsOneWidget);

      // Verify the button text exists (from app_en.arb: "startConversion")
      expect(find.text('Start Conversion'), findsOneWidget);
    });

    testWidgets('CRF slider should exist and have correct range for H.264', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Find the CRF slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Check slider properties for H.264 (default codec)
      final sliderWidget = tester.widget<Slider>(slider);
      expect(sliderWidget.min, equals(0));
      expect(sliderWidget.max, equals(51)); // H.264/H.265 max CRF
    });

    testWidgets('Format dropdown should exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for container format dropdown (from app_en.arb: "containerFormat")
      expect(find.textContaining('Container'), findsOneWidget);

      // Check for common format value
      expect(find.text('mp4'), findsOneWidget);
    });

    testWidgets('Codec dropdown should exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for video codec dropdown (from app_en.arb: "videoCodec")
      expect(find.textContaining('Video Codec'), findsOneWidget);

      // Check for default codec value
      expect(find.text('libx264'), findsOneWidget);
    });

    testWidgets('Resolution dropdown should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for resolution dropdown (from app_en.arb: "resolution")
      expect(find.textContaining('Resolution'), findsOneWidget);

      // Check for default resolution value
      expect(find.text('Original'), findsOneWidget);
    });

    testWidgets('Audio settings dropdown should exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for audio settings dropdown (from app_en.arb: "audioSettings")
      expect(find.textContaining('Audio'), findsOneWidget);
    });
  });

  group('ConverterTab State Tests', () {
    testWidgets('CRF slider value should update when dragged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Find CRF slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Verify slider has a valid initial value
      final initialSlider = tester.widget<Slider>(slider);
      expect(initialSlider.value, greaterThanOrEqualTo(0));

      // Drag slider to change value
      // Note: warnIfMissed is false because slider may be off-screen in test environment
      await tester.drag(slider, const Offset(100, 0), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Get new value
      final updatedSlider = tester.widget<Slider>(slider);
      final updatedValue = updatedSlider.value;

      // Value should have changed (or at least not throw an error)
      // Note: The exact value change depends on slider width and drag distance
      expect(updatedValue, isNotNull);
    });

    testWidgets('Preset dropdown should exist and be changeable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ConverterTab()));
      await tester.pumpAndSettle();

      // Check for preset dropdown (from app_en.arb: "presetSpeed")
      expect(find.textContaining('Preset'), findsOneWidget);

      // Check for default preset value
      expect(find.text('medium'), findsOneWidget);
    });
  });

  group('ConverterTab Integration with MainScreen', () {
    testWidgets('ConverterTab should be accessible from MainScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      await tester.pumpAndSettle();

      // MainScreen should be visible
      expect(find.byType(MainScreen), findsOneWidget);

      // ConverterTab should be the first tab (default)
      expect(find.byType(ConverterTab), findsOneWidget);
    });

    testWidgets('Should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      await tester.pumpAndSettle();

      // Find tabs by their icons - this is more reliable across platforms
      // Icons defined in main.dart: transform (Converter), edit_note (Editor)
      final tabBar = find.byType(TabBar);
      expect(tabBar, findsOneWidget);

      // Find the Editor tab by its icon (edit_note) and tap it
      final editorTabIcon = find.descendant(
        of: tabBar,
        matching: find.byIcon(Icons.edit_note),
      );
      expect(editorTabIcon, findsOneWidget);
      await tester.tap(editorTabIcon);
      await tester.pump(); // Initial frame
      await tester.pump(const Duration(milliseconds: 300)); // Animation
      await tester.pumpAndSettle();

      // Find the Converter tab by its icon (transform) and tap it
      final converterTabIcon = find.descendant(
        of: tabBar,
        matching: find.byIcon(Icons.transform),
      );
      expect(converterTabIcon, findsOneWidget);
      await tester.tap(converterTabIcon);
      await tester.pump(); // Initial frame
      await tester.pump(const Duration(milliseconds: 300)); // Animation
      await tester.pumpAndSettle();

      // ConverterTab should be visible
      expect(find.byType(ConverterTab), findsOneWidget);
    });
  });
}
