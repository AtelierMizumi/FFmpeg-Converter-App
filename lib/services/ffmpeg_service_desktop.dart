import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'ffmpeg_service_interface.dart';
import 'ffmpeg_service_mobile.dart';

class FFmpegServiceImpl implements FFmpegService {
  String? _ffmpegPath;
  final _mobileService = FFmpegServiceMobile();
  Process? _process;

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  Future<void> initialize() async {
    if (_isMobile) {
      return _mobileService.initialize();
    }

    // Determine target platform asset path
    String assetPath;
    String binaryName;

    if (Platform.isWindows) {
      assetPath = 'assets/bin/windows/ffmpeg.exe';
      binaryName = 'ffmpeg.exe';
    } else if (Platform.isLinux) {
      assetPath = 'assets/bin/linux/ffmpeg';
      binaryName = 'ffmpeg';
    } else {
      // Fallback or throw for unsupported desktop os
      throw UnsupportedError('Platform not supported for bundled FFmpeg');
    }

    // Get the directory where we can start executables
    final appDocDir = await getApplicationSupportDirectory();
    final targetPath = p.join(appDocDir.path, 'bin', binaryName);
    final targetFile = File(targetPath);

    _ffmpegPath = targetPath;

    // Check if file exists.
    // In a real app, you might want closer version control (e.g. check hash) to overwrite if updated.
    // For now, we assume if it's there, it's good.
    if (!await targetFile.exists()) {
      debugPrint('Extracting FFmpeg to $targetPath...');
      try {
        await targetFile.parent.create(recursive: true);

        // Load asset
        final byteData = await rootBundle.load(assetPath);
        final buffer = byteData.buffer;

        // Write to file
        await targetFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          flush: true,
        );

        debugPrint('Extraction complete.');
      } catch (e) {
        debugPrint('Error extracting FFmpeg: $e');
        // Fallback: try using system command if extraction fails?
        // _ffmpegPath = 'ffmpeg';
        rethrow;
      }
    }

    // Ensure executable permission on Linux/Mac
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', targetPath]);
    }

    // Verify
    try {
      final result = await Process.run(_ffmpegPath!, ['-version']);
      if (result.exitCode != 0) {
        debugPrint('Bundled FFmpeg check failed: ${result.stderr}');
        // If validation fails, maybe the binary is corrupted or wrong arch.
        // Delete it so it gets re-extracted next time with hopefully a better asset.
        await targetFile.delete();
        debugPrint(
          'Corrupted binary deleted. Please restart app to re-extract.',
        );
        throw Exception(
          'Bundled FFmpeg binary is invalid. Deleted for re-extraction.',
        );
      } else {
        debugPrint(
          'Bundled FFmpeg initialized: ${result.stdout.toString().split('\n').first}',
        );
      }
    } catch (e) {
      debugPrint('Failed to run bundled FFmpeg: $e');
      // If we can't even run it (e.g. format error), delete it too.
      if (await targetFile.exists()) {
        await targetFile.delete();
        debugPrint('Unexecutable binary deleted.');
      }
      rethrow;
    }
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
    if (_isMobile) {
      return _mobileService.convertVideo(
        input,
        args,
        outputExtension,
        outputDirectory: outputDirectory,
        outputFilename: outputFilename,
        onProgress: onProgress,
      );
    }

    if (_ffmpegPath == null) await initialize();

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
    final ffmpegArgs = <String>['-y', '-i', input.path, ...args, outputPath];

    debugPrint('Running bundled FFmpeg: $_ffmpegPath ${ffmpegArgs.join(' ')}');

    _process = await Process.start(_ffmpegPath!, ffmpegArgs);

    // Duration parsing state variables
    Duration? totalDuration;

    // Listen to stderr for progress (FFmpeg logs to stderr)
    if (_process != null) {
      _process!.stderr.transform(SystemEncoding().decoder).listen((data) {
        if (onProgress != null) {
          // Parse Duration: 00:00:05.12
          if (totalDuration == null) {
            final durMatch = RegExp(
              r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})',
            ).firstMatch(data);
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
              } catch (e) {
                // ignore parse error
              }
            }
          }

          // Parse time=00:00:02.50
          if (totalDuration != null) {
            final timeMatch = RegExp(
              r'time=(\d{2}):(\d{2}):(\d{2}\.\d{2})',
            ).firstMatch(data);
            if (timeMatch != null) {
              try {
                final h = int.parse(timeMatch.group(1)!);
                final m = int.parse(timeMatch.group(2)!);
                final s = double.parse(timeMatch.group(3)!);
                final currentDuration = Duration(
                  hours: h,
                  minutes: m,
                  milliseconds: (s * 1000).toInt(),
                );

                final progress =
                    currentDuration.inMilliseconds /
                    totalDuration!.inMilliseconds;
                final clampedProgress = progress > 1.0 ? 1.0 : progress;
                onProgress(
                  clampedProgress,
                  'Converting... ${(clampedProgress * 100).toInt()}%',
                );
              } catch (e) {
                // ignore
              }
            }
          }
        }
      });
    }

    final exitCode = await _process!.exitCode;

    if (exitCode != 0) {
      throw Exception('FFmpeg failed with exit code $exitCode');
    }

    _process = null;

    if (onProgress != null) onProgress(1.0, 'Completed');
    return XFile(outputPath);
  }

  @override
  Future<void> cancel() async {
    if (_isMobile) {
      return _mobileService.cancel();
    }

    if (_process != null) return;

    debugPrint('Cancelling FFmpeg process...');
    _process!.kill(ProcessSignal.sigterm);
    _process = null;
  }
}
