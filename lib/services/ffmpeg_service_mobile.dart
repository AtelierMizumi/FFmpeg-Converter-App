import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'ffmpeg_service_interface.dart';

class FFmpegServiceMobile implements FFmpegService {
  static const platform = MethodChannel(
    'com.example.ffmpeg_converter_app/ffmpeg',
  );

  @override
  Future<void> initialize() async {
    // Native library is initialized lazily
    debugPrint("FFmpegKit Mobile - Native Bridge Initialized");
  }

  @override
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension, {
    String? outputDirectory,
    String? outputFilename,
    ProgressCallback? onProgress,
  }) async {
    String targetDir;
    if (outputDirectory != null) {
      targetDir = outputDirectory;
    } else {
      final tempDir = await getTemporaryDirectory();
      targetDir = tempDir.path;
    }

    final outputName =
        outputFilename ??
        'output_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
    final outputPath = p.join(targetDir, outputName);

    // Build arguments: -i INPUT ARGS OUTPUT
    // Note: 'yes' overwrite (-y) is usually standard for temp files
    final ffmpegArgs = <String>['-y', '-i', input.path, ...args, outputPath];

    debugPrint('Running Native FFmpeg: ${ffmpegArgs.join(' ')}');

    try {
      if (onProgress != null) {
        onProgress(0.0, 'Starting conversion...');
      }

      // TODO: Implement progress updates via EventChannel if needed.
      // Current implementation awaits completion.
      // Simulating progress for better UX in absence of real-time callbacks from MethodChannel
      if (onProgress != null) {
        onProgress(0.1, 'Converting...');
      }

      await platform.invokeMethod('execute', {'args': ffmpegArgs});

      if (onProgress != null) {
        onProgress(1.0, 'Completed');
      }

      return XFile(outputPath);
    } on PlatformException catch (e) {
      debugPrint("FFmpeg Native Error: ${e.message}");
      throw Exception('FFmpeg conversion failed: ${e.message}');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await platform.invokeMethod('cancel');
    } on PlatformException catch (e) {
      debugPrint("Failed to cancel FFmpeg: ${e.message}");
    }
  }
}
