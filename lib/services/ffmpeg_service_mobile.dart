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
  static const eventChannel = EventChannel(
    'com.example.ffmpeg_converter_app/ffmpeg/events',
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

    // Duration parsing state variables
    Duration? totalDuration;

    // Listen to events
    final subscription = eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final type = event['type'];

          if (type == 'log') {
            final message = event['message'] as String;
            // Parse Duration from logs if not yet found
            if (totalDuration == null) {
              final durMatch = RegExp(
                r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})',
              ).firstMatch(message);
              if (durMatch != null) {
                try {
                  final h = int.parse(durMatch.group(1)!);
                  final m = int.parse(durMatch.group(2)!);
                  final s = double.parse(durMatch.group(3)!);
                  totalDuration = Duration(
                    hours: h,
                    minutes: m,
                    milliseconds: (s * 1000).toInt(),
                  );
                  debugPrint('FFmpeg parsed duration: $totalDuration');
                } catch (e) {
                  debugPrint('Error parsing duration: $e');
                }
              }
            }
          } else if (type == 'statistics') {
            // 'time' is usually in milliseconds from FFmpegKit
            final time = event['time'];
            if (time != null && totalDuration != null && onProgress != null) {
              final currentTimeMs = (time is int)
                  ? time
                  : (time as num).toInt();

              final progress = currentTimeMs / totalDuration!.inMilliseconds;
              final clampedProgress = progress > 1.0
                  ? 1.0
                  : (progress < 0.0 ? 0.0 : progress);

              onProgress(
                clampedProgress,
                'Converting... ${(clampedProgress * 100).toInt()}%',
              );
            }
          }
        }
      },
      onError: (error) {
        debugPrint('FFmpeg Event Error: $error');
      },
    );

    try {
      if (onProgress != null) {
        onProgress(0.0, 'Starting conversion...');
      }

      await platform.invokeMethod('execute', {'args': ffmpegArgs});

      if (onProgress != null) {
        onProgress(1.0, 'Completed');
      }

      return XFile(outputPath);
    } on PlatformException catch (e) {
      debugPrint("FFmpeg Native Error: ${e.message}");
      throw Exception('FFmpeg conversion failed: ${e.message}');
    } finally {
      subscription.cancel();
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
