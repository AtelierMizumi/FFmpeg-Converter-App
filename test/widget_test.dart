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
}
