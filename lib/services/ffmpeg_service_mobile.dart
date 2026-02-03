import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'ffmpeg_service_interface.dart';

/// FFmpeg service implementation for mobile platforms (Android, iOS)
/// Uses ffmpeg_kit_flutter_new package
class FFmpegServiceMobile implements FFmpegService {
  @override
  Future<void> initialize() async {
    debugPrint("✅ FFmpegKit Mobile - Initialized with ffmpeg_kit_flutter_new v4.1.0");
    debugPrint("📱 Mobile video conversion is now FULLY SUPPORTED!");
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
    // Determine output path
    String targetDir;
    if (outputDirectory != null) {
      targetDir = outputDirectory;
    } else {
      // Use app's document directory on mobile
      final Directory appDir = await getApplicationDocumentsDirectory();
      targetDir = appDir.path;
    }

    final outputName =
        outputFilename ??
        'converted_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
    final outputPath = p.join(targetDir, outputName);

    // Build FFmpeg command: -i INPUT ARGS OUTPUT
    final command = '-y -i "${input.path}" ${args.join(' ')} "$outputPath"';
    
    debugPrint('🎬 FFmpegKit Mobile: Executing command: $command');

    // Track progress
    if (onProgress != null) {
      onProgress(0.0, 'Starting conversion...');
    }

    // Duration parsing state
    Duration? totalDuration;
    int lastStatisticsTime = 0;
    
    // Flags to track callback state
    bool callbacksEnabled = false;

    try {
      // Enable statistics callback for this session
      FFmpegKitConfig.enableStatisticsCallback((Statistics statistics) {
        final time = statistics.getTime();
        
        // Update progress every 100ms to avoid too many updates
        if (time - lastStatisticsTime > 100) {
          lastStatisticsTime = time;
          
          if (totalDuration != null && onProgress != null) {
            final currentTimeMs = time;
            final totalTimeMs = totalDuration!.inMilliseconds;
            
            if (totalTimeMs > 0) {
              final progress = (currentTimeMs / totalTimeMs).clamp(0.0, 1.0);
              onProgress(
                progress,
                'Converting... ${(progress * 100).toInt()}%',
              );
            }
          }
        }
      });

      // Enable log callback to parse duration
      FFmpegKitConfig.enableLogCallback((Log log) {
        final message = log.getMessage();
        
        // Parse duration from logs if not yet found
        if (totalDuration == null && message.contains('Duration:')) {
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
              
              debugPrint('📊 Parsed video duration: $totalDuration');
            } catch (e) {
              debugPrint('⚠️ Error parsing duration: $e');
            }
          }
        }
      });
      
      callbacksEnabled = true;

      // Execute FFmpeg command
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      // Check result
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('✅ FFmpeg conversion successful!');
        if (onProgress != null) {
          onProgress(1.0, 'Completed!');
        }
        
        // Verify output file exists
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          return XFile(outputPath);
        } else {
          throw Exception('Output file was not created: $outputPath');
        }
      } else if (ReturnCode.isCancel(returnCode)) {
        debugPrint('⚠️ FFmpeg conversion was cancelled');
        throw Exception('Conversion was cancelled by user');
      } else {
        final output = await session.getOutput();
        debugPrint('❌ FFmpeg conversion failed with return code: $returnCode');
        debugPrint('Error output: $output');
        throw Exception('FFmpeg conversion failed: $output');
      }
    } catch (e) {
      debugPrint('❌ Error during conversion: $e');
      rethrow;
    } finally {
      // IMPORTANT: Disable callbacks to prevent memory leaks
      if (callbacksEnabled) {
        try {
          FFmpegKitConfig.enableStatisticsCallback(null);
          FFmpegKitConfig.enableLogCallback(null);
          debugPrint('🧹 Callbacks disabled to prevent memory leaks');
        } catch (e) {
          debugPrint('⚠️ Error disabling callbacks: $e');
        }
      }
    }
  }

  @override
  Future<XFile?> executeFFmpeg(
    List<String> command, {
    ProgressCallback? onProgress,
  }) async {
    // Join command arguments
    final commandString = command.join(' ');
    
    debugPrint('🎬 FFmpegKit Mobile: Executing custom command');
    
    if (onProgress != null) {
      onProgress(0.0, 'Starting...');
    }

    // Execute command
    final session = await FFmpegKit.execute(commandString);
    final returnCode = await session.getReturnCode();

    // Check result
    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('✅ FFmpeg command executed successfully!');
      if (onProgress != null) {
        onProgress(1.0, 'Completed!');
      }
      
      // Try to extract output path from command (last argument usually)
      if (command.isNotEmpty) {
        final outputPath = command.last;
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          return XFile(outputPath);
        }
      }
      
      return null;
    } else {
      final output = await session.getOutput();
      debugPrint('❌ FFmpeg command failed: $output');
      throw Exception('FFmpeg command failed: $output');
    }
  }

  @override
  Future<void> cancel() async {
    debugPrint('🛑 Cancelling all FFmpeg sessions...');
    await FFmpegKit.cancel();
    debugPrint('✅ All FFmpeg sessions cancelled');
  }

  @override
  Future<double?> getVideoDuration(XFile videoFile) async {
    try {
      debugPrint('📊 Getting video duration for: ${videoFile.path}');
      
      // Use FFprobe to get duration
      // Command: ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
      final command = '-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${videoFile.path}"';
      
      final session = await FFmpegKit.execute(command);
      final output = await session.getOutput();
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode) && output != null) {
        // Parse duration from output
        final durationStr = output.trim();
        final duration = double.tryParse(durationStr);
        
        if (duration != null && duration > 0) {
          debugPrint('✅ Video duration: ${duration.toStringAsFixed(2)}s');
          return duration;
        }
      }
      
      debugPrint('⚠️ Could not determine video duration from FFprobe output');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting video duration: $e');
      return null;
    }
  }
}
