import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'ffmpeg_service_interface.dart';

class FFmpegServiceImpl implements FFmpegService {
  String? _ffmpegPath;

  @override
  Future<void> initialize() async {
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
      print('Extracting FFmpeg to $targetPath...');
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

        print('Extraction complete.');
      } catch (e) {
        print('Error extracting FFmpeg: $e');
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
        print('Bundled FFmpeg check failed: ${result.stderr}');
        // If validation fails, maybe the binary is corrupted or wrong arch.
        // Delete it so it gets re-extracted next time with hopefully a better asset.
        await targetFile.delete();
        print('Corrupted binary deleted. Please restart app to re-extract.');
        throw Exception(
          'Bundled FFmpeg binary is invalid. Deleted for re-extraction.',
        );
      } else {
        print(
          'Bundled FFmpeg initialized: ${result.stdout.toString().split('\n').first}',
        );
      }
    } catch (e) {
      print('Failed to run bundled FFmpeg: $e');
      // If we can't even run it (e.g. format error), delete it too.
      if (await targetFile.exists()) {
        await targetFile.delete();
        print('Unexecutable binary deleted.');
      }
      rethrow;
    }
  }

  @override
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension,
  ) async {
    if (_ffmpegPath == null) await initialize();

    final tempDir = await getTemporaryDirectory();
    final outputName =
        'output_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
    final outputPath = p.join(tempDir.path, outputName);

    // Build arguments: -i INPUT ARGS OUTPUT
    final ffmpegArgs = <String>['-y', '-i', input.path, ...args, outputPath];

    print('Running bundled FFmpeg: $_ffmpegPath ${ffmpegArgs.join(' ')}');

    final result = await Process.run(_ffmpegPath!, ffmpegArgs);

    if (result.exitCode != 0) {
      throw Exception('FFmpeg failed: ${result.stderr}');
    }

    return XFile(outputPath);
  }
}
