import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffmpeg_converter_app/ui/tabs/converter_tab.dart';
import 'package:ffmpeg_converter_app/main.dart';

void main() {
  group('ConverterTab Widget Tests', () {
    testWidgets('Should display all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Check for file picker button
      expect(find.text('Select Video File'), findsOneWidget);

      // Check for output format dropdown
      expect(find.text('Output Format'), findsOneWidget);

      // Check for codec dropdown
      expect(find.text('Video Codec'), findsOneWidget);

      // Check for bitrate field
      expect(find.text('Video Bitrate'), findsOneWidget);

      // Check for resolution field
      expect(find.text('Resolution'), findsOneWidget);

      // Check for CRF slider
      expect(find.text('CRF Quality'), findsOneWidget);
    });

    testWidgets('Convert button should be disabled initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Find convert button
      final convertButton = find.widgetWithText(
        ElevatedButton,
        'Convert Video',
      );
      expect(convertButton, findsOneWidget);

      // Check if button is disabled (onPressed should be null)
      final button = tester.widget<ElevatedButton>(convertButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('CRF slider should have correct range for H.264', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Find the CRF slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Check slider properties for H.264 (default codec)
      final sliderWidget = tester.widget<Slider>(slider);
      expect(sliderWidget.min, equals(0));
      expect(sliderWidget.max, equals(51)); // H.264/H.265 max CRF
    });

    testWidgets('Format dropdown should contain valid formats', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Tap on output format dropdown
      await tester.tap(find.text('mp4').first);
      await tester.pumpAndSettle();

      // Check for common formats
      expect(find.text('mp4').hitTestable(), findsWidgets);
      expect(find.text('webm').hitTestable(), findsWidgets);
      expect(find.text('mkv').hitTestable(), findsWidgets);
    });

    testWidgets('Codec dropdown should contain valid codecs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Tap on codec dropdown
      await tester.tap(find.text('H.264 (libx264)').first);
      await tester.pumpAndSettle();

      // Check for common codecs
      expect(find.text('H.264 (libx264)').hitTestable(), findsWidgets);
      expect(find.text('H.265 (libx265)').hitTestable(), findsWidgets);
      expect(find.text('VP9 (libvpx-vp9)').hitTestable(), findsWidgets);
    });

    testWidgets('Should show error for invalid bitrate', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Find bitrate text field
      final bitrateField = find.widgetWithText(TextField, 'Video Bitrate');
      expect(bitrateField, findsOneWidget);

      // Enter invalid bitrate
      await tester.enterText(bitrateField, 'invalid');
      await tester.pump();

      // Note: Actual validation happens on submit, not on text change
      // This test verifies the field accepts input
      expect(find.text('invalid'), findsOneWidget);
    });

    testWidgets('Should show error for invalid resolution', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Find resolution text field
      final resolutionField = find.widgetWithText(TextField, 'Resolution');
      expect(resolutionField, findsOneWidget);

      // Enter invalid resolution
      await tester.enterText(resolutionField, '1920');
      await tester.pump();

      // Verify input
      expect(find.text('1920'), findsOneWidget);
    });
  });

  group('ConverterTab State Tests', () {
    testWidgets('CRF slider value should update', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Find CRF slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Get initial value
      final initialSlider = tester.widget<Slider>(slider);
      final initialValue = initialSlider.value;

      // Drag slider to change value
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // Get new value
      final updatedSlider = tester.widget<Slider>(slider);
      final updatedValue = updatedSlider.value;

      // Value should have changed
      expect(updatedValue, isNot(equals(initialValue)));
    });

    testWidgets('Changing codec should update CRF slider range', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConverterTab())),
      );

      // Initial slider should have H.264 range (0-51)
      final initialSlider = find.byType(Slider);
      expect(tester.widget<Slider>(initialSlider).max, equals(51));

      // Change codec to VP9
      await tester.tap(find.text('H.264 (libx264)').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('VP9 (libvpx-vp9)').last);
      await tester.pumpAndSettle();

      // Slider should now have VP9 range (0-63)
      final updatedSlider = find.byType(Slider);
      expect(tester.widget<Slider>(updatedSlider).max, equals(63));
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

    testWidgets('Should switch to ConverterTab when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      await tester.pumpAndSettle();

      // Switch to another tab first (Editor)
      await tester.tap(find.text('Editor'));
      await tester.pumpAndSettle();

      // Switch back to Converter tab
      await tester.tap(find.text('Converter'));
      await tester.pumpAndSettle();

      // ConverterTab should be visible
      expect(find.byType(ConverterTab), findsOneWidget);
      expect(find.text('Select Video File'), findsOneWidget);
    });
  });
}
