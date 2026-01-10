import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'ffmpeg_service_interface.dart';

class FFmpegServiceImpl implements FFmpegService {
  @override
  Future<void> initialize() async {
    // Check if ffmpeg is installed
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      if (result.exitCode != 0) {
        print('FFmpeg not found: ${result.stderr}');
      } else {
        print('FFmpeg found: ${result.stdout.toString().split('\n').first}');
      }
    } catch (e) {
      print('Error checking for FFmpeg: $e');
    }
  }

  @override
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final outputName =
        'output_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
    final outputPath = p.join(tempDir.path, outputName);

    // Build arguments: -i INPUT ARGS OUTPUT
    // Note: User args should be like ['-c:v', 'libx264']
    final ffmpegArgs = <String>[
      '-y', // align with web overwrite behavior
      '-i',
      input.path,
      ...args,
      outputPath,
    ];

    print('Running FFmpeg (Linux): ffmpeg ${ffmpegArgs.join(' ')}');

    final result = await Process.run('ffmpeg', ffmpegArgs);

    if (result.exitCode != 0) {
      throw Exception('FFmpeg failed: ${result.stderr}');
    }

    return XFile(outputPath);
  }
}
