import 'package:cross_file/cross_file.dart';

typedef ProgressCallback = void Function(double progress, String message);

abstract class FFmpegService {
  Future<void> initialize();
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension, {
    String? outputDirectory,
    String? outputFilename,
    ProgressCallback? onProgress,
  });

  Future<XFile?> executeFFmpeg(
    List<String> command, {
    ProgressCallback? onProgress,
  });

  Future<void> cancel();
}
