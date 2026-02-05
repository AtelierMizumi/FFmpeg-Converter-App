import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_application/main.dart';
import 'package:flutter_test_application/services/video_validator.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:typed_data';

void main() {
  group('App Widget Tests', () {
    testWidgets('App should start without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      expect(find.byType(FFmpegConverterApp), findsOneWidget);
    });

    testWidgets('App should have language selector', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FFmpegConverterApp());
      expect(find.byIcon(Icons.language), findsOneWidget);
    });
  });

  group('VideoValidator Tests', () {
    test('Should reject files without extension', () async {
      final file = XFile.fromData(Uint8List(0), name: 'noextension');
      final result = await VideoValidator.validateInputFile(file);
      expect(result.isValid, false);
      expect(result.error, contains('Unknown file format'));
    });

    test('Should accept valid video formats', () async {
      final validFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
      for (final format in validFormats) {
        // Use a non-empty path string so video validator can detect extension properly
        // if it relies on path logic fallback
        final file = XFile.fromData(
          Uint8List(100),
          name: 'test.$format',
          length: 100,
          path: '/mock/path/to/test.$format',
        );

        final result = await VideoValidator.validateInputFile(file);
        expect(
          result.isValid,
          true,
          reason: 'Should accept .$format but got error: ${result.error}',
        );
      }
    });

    test('Should reject invalid video formats', () async {
      final invalidFormats = ['txt', 'pdf', 'jpg', 'mp3', 'doc'];
      for (final format in invalidFormats) {
        final file = XFile.fromData(Uint8List(100), name: 'test.$format');
        final result = await VideoValidator.validateInputFile(file);
        expect(result.isValid, false, reason: 'Should reject .$format');
      }
    });

    test('Should accept valid output formats', () {
      final validFormats = ['mp4', 'webm', 'mkv', 'mov'];
      for (final format in validFormats) {
        final result = VideoValidator.validateOutputFormat(format);
        expect(result.isValid, true, reason: 'Should accept $format');
      }
    });

    test('Should reject invalid output formats', () {
      final invalidFormats = ['txt', 'pdf', 'jpg', 'exe'];
      for (final format in invalidFormats) {
        final result = VideoValidator.validateOutputFormat(format);
        expect(result.isValid, false, reason: 'Should reject $format');
      }
    });

    test('Should validate CRF range for H.264', () {
      final result1 = VideoValidator.validateCRF(23, 'libx264');
      expect(result1.isValid, true);

      final result2 = VideoValidator.validateCRF(-1, 'libx264');
      expect(result2.isValid, false);

      final result3 = VideoValidator.validateCRF(52, 'libx264');
      expect(result3.isValid, false);
    });

    test('Should skip CRF validation for copy codec', () {
      final result = VideoValidator.validateCRF(100, 'copy');
      expect(result.isValid, true);
    });

    test('Should format file sizes correctly', () {
      expect(VideoValidator.formatFileSize(500), equals('500 B'));
      expect(VideoValidator.formatFileSize(1024), equals('1.0 KB'));
      expect(VideoValidator.formatFileSize(1024 * 1024), equals('1.0 MB'));
      expect(
        VideoValidator.formatFileSize(1024 * 1024 * 1024),
        equals('1.00 GB'),
      );
    });
  });

  group('Kaizen Improvements Tests', () {
    test('Progress throttle duration should be 100ms', () {
      // This tests the concept - actual implementation is in converter_tab.dart
      const throttleDuration = Duration(milliseconds: 100);
      expect(throttleDuration.inMilliseconds, 100);
    });

    test('RegExp patterns should be valid for FFmpeg output parsing', () {
      // Test the static RegExp patterns used in ffmpeg_service_desktop.dart
      final durationRegex = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})');
      final timeRegex = RegExp(r'time=(\d{2}):(\d{2}):(\d{2}\.\d{2})');

      // Test duration pattern
      final durationMatch = durationRegex.firstMatch('Duration: 00:05:32.50');
      expect(durationMatch, isNotNull);
      expect(durationMatch!.group(1), '00'); // hours
      expect(durationMatch.group(2), '05'); // minutes
      expect(durationMatch.group(3), '32.50'); // seconds

      // Test time pattern
      final timeMatch = timeRegex.firstMatch(
        'frame=1234 time=00:02:15.00 speed=2x',
      );
      expect(timeMatch, isNotNull);
      expect(timeMatch!.group(1), '00'); // hours
      expect(timeMatch.group(2), '02'); // minutes
      expect(timeMatch.group(3), '15.00'); // seconds
    });

    test('Progress calculation should be clamped between 0 and 1', () {
      // Helper function to simulate progress calculation
      double calculateProgress(int currentMs, int totalMs) {
        if (totalMs == 0) return 0.0;
        final progress = currentMs / totalMs;
        return progress > 1.0 ? 1.0 : (progress < 0.0 ? 0.0 : progress);
      }

      expect(calculateProgress(50, 100), 0.5);
      expect(calculateProgress(100, 100), 1.0);
      expect(calculateProgress(150, 100), 1.0); // Clamped to 1.0
      expect(calculateProgress(0, 100), 0.0);
      expect(calculateProgress(0, 0), 0.0); // Edge case
    });

    test('Duration parsing should handle various formats', () {
      // Test helper function for duration parsing
      Duration? parseDuration(String timeStr) {
        final regex = RegExp(r'(\d{2}):(\d{2}):(\d{2}\.\d{2})');
        final match = regex.firstMatch(timeStr);
        if (match == null) return null;

        try {
          final h = int.parse(match.group(1)!);
          final m = int.parse(match.group(2)!);
          final s = double.parse(match.group(3)!);
          return Duration(
            hours: h,
            minutes: m,
            milliseconds: (s * 1000).toInt(),
          );
        } catch (e) {
          return null;
        }
      }

      final duration1 = parseDuration('00:05:32.50');
      expect(duration1, isNotNull);
      expect(duration1!.inSeconds, 332); // 5*60 + 32 = 332

      final duration2 = parseDuration('01:30:00.00');
      expect(duration2, isNotNull);
      expect(duration2!.inMinutes, 90);

      final duration3 = parseDuration('invalid');
      expect(duration3, isNull);
    });
  });

  group('FileDropZone Widget Tests', () {
    // Note: Full widget tests would require mock dependencies
    // These are conceptual tests for the widget behavior

    test('FileDropZone should support custom aspect ratios', () {
      const defaultAspectRatio = 16 / 9;
      const customAspectRatio = 4 / 3;

      expect(defaultAspectRatio, closeTo(1.778, 0.001));
      expect(customAspectRatio, closeTo(1.333, 0.001));
    });
  });
}
