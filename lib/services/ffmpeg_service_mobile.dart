import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'ffmpeg_service_interface.dart';

class FFmpegServiceMobile implements FFmpegService {
  String? _sessionId;

  String? _getSessionId() => _sessionId;

  @override
  Future<void> initialize() async {
    // FFmpegKit doesn't strictly need initialization like WASM
    // But we use this to verify it's working or set up configs
    debugPrint("FFmpegKit Mobile Initialized");
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
    final tempDir = await getTemporaryDirectory();
    final inputName =
        'input_${DateTime.now().millisecondsSinceEpoch}.${input.path.split('.').last}';
    final outputName =
        outputFilename ??
        'output_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';

    // Copy input to temp to ensure access (especially if from content:// URI)
    final inputFile = File('${tempDir.path}/$inputName');
    await inputFile.writeAsBytes(await input.readAsBytes());

    // Output path in temp directory
    final outputPath = '${tempDir.path}/$outputName';

    // Build arguments
    // Ensure all args are safe.
    final finalArgs = ['-i', inputFile.path, ...args, outputPath];

    // Enable stats for progress (simplified, just showing activity as we don't calculate % yet without total duration)
    if (onProgress != null) {
      FFmpegKitConfig.enableStatisticsCallback((stats) {
        // stats.getTime() gives current time in milliseconds of video processed
        // Without knowing total duration, we can't give accurate 0.0-1.0
        // But the UI expects 0.0-1.0.
        // We can just fake it or leave it indeterminate (linear progress indicator can be indeterminate)
        // For now, let's just push meaningless updates to show it's alive.
        try {
          final timeMs = stats.getTime();
          final timeStr = '${(timeMs / 1000).toStringAsFixed(1)}s';
          onProgress(0.0, 'Processing... Time: $timeStr');
        } catch (e) {
          onProgress(0.0, 'Processing...');
        }
      });
    }

    // FFmpegKit.execute accepts a string command. We need to escape spaces properly.
    // However, executeWithArguments is safer if available?
    // FFmpegKit.executeWithArguments is the preferred way to avoid shell escape issues
    final session = await FFmpegKit.executeWithArguments(finalArgs);
    _sessionId = _getSessionId();

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return XFile(outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed with code $returnCode\nBox logs: $logs');
    }
  }

  @override
  Future<void> cancel() async {
    if (_sessionId == null) return;

    debugPrint('Cancelling FFmpeg session $_sessionId');
    try {
      final sessionIdInt = int.tryParse(_sessionId!);
      if (sessionIdInt != null) {
        await FFmpegKit.cancel(sessionIdInt!);
      }
    } catch (e) {
      debugPrint('Error cancelling: $e');
    }
    _sessionId = null;
  }
}
