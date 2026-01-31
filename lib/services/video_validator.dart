import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

class VideoValidator {
  // File size limits:
  // - Desktop/Mobile: No limit (FFmpeg uses stream processing, doesn't load entire file into RAM)
  // - Web: 500MB limit (ffmpeg.wasm loads entire file into browser memory)
  static const maxFileSizeBytesWeb = 500 * 1024 * 1024; // 500MB

  static const supportedVideoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'wmv',
    'm4v',
    'mpg',
    'mpeg',
  ];

  static const supportedOutputFormats = ['mp4', 'webm', 'mkv', 'mov'];

  static Future<ValidationResult> validateInputFile(XFile file) async {
    // Check file extension
    final extension = _getFileExtension(file.name);
    if (extension == null) {
      return ValidationResult(isValid: false, error: 'Unknown file format');
    }

    if (!supportedVideoExtensions.contains(extension)) {
      return ValidationResult(
        isValid: false,
        error: 'Unsupported video format: $extension',
      );
    }

    // Check file size (only for Web platform)
    // Desktop/Mobile: FFmpeg uses stream processing, no RAM limit needed
    // Web: ffmpeg.wasm loads entire file into browser memory
    if (kIsWeb) {
      final fileSize = await _getFileSize(file);
      if (fileSize > maxFileSizeBytesWeb) {
        return ValidationResult(
          isValid: false,
          error:
              'File too large for web. Maximum size: ${maxFileSizeBytesWeb ~/ (1024 * 1024)}MB',
        );
      }
    }
    // Desktop/Mobile: No file size validation - FFmpeg handles any size via streaming

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateOutputFormat(String format) {
    if (!supportedOutputFormats.contains(format.toLowerCase())) {
      return ValidationResult(
        isValid: false,
        error: 'Unsupported output format: $format',
      );
    }
    return ValidationResult(isValid: true);
  }

  static ValidationResult validateCRF(double crf, String codec) {
    if (codec == 'copy') {
      return ValidationResult(isValid: true);
    }

    // Codec-specific ranges
    if (codec.contains('264') || codec.contains('265')) {
      // H.264 and H.265 support CRF 0-51
      if (crf < 0 || crf > 51) {
        return ValidationResult(
          isValid: false,
          error: 'H.264/H.265 CRF must be between 0 and 51',
        );
      }
    } else if (codec.contains('vp9')) {
      // VP9 supports CRF 0-63
      if (crf < 0 || crf > 63) {
        return ValidationResult(
          isValid: false,
          error: 'VP9 CRF must be between 0 and 63',
        );
      }
    } else if (codec.contains('av1')) {
      // AV1 supports CRF 0-63
      if (crf < 0 || crf > 63) {
        return ValidationResult(
          isValid: false,
          error: 'AV1 CRF must be between 0 and 63',
        );
      }
    } else if (codec.contains('xvid') || codec.contains('mpeg4')) {
      // Xvid (MPEG-4) typically uses qscale 1-31, but often mapped to CRF in wrappers or -q:v
      // For simplicity we allow the standard range but warn or map internally if needed.
      // But -crf doesn't always work for mpeg4, usually it's -q:v.
      // FFmpegService might need to handle this mapping.
      if (crf < 0 || crf > 51) {
        return ValidationResult(
          isValid: false,
          error: 'MPEG-4 CRF/qscale should be between 0 and 51',
        );
      }
    } else {
      // Default validation for unknown codecs - use standard range 0-51
      if (crf < 0 || crf > 51) {
        return ValidationResult(
          isValid: false,
          error: 'CRF must be between 0 and 51',
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  static String? _getFileExtension(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return filename.substring(dotIndex + 1).toLowerCase();
  }

  static Future<int> _getFileSize(XFile file) async {
    return await file.length();
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({required this.isValid, this.error});
}
