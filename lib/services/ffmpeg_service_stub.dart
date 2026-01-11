import 'package:cross_file/cross_file.dart';
import 'ffmpeg_service_interface.dart';

class FFmpegServiceImpl implements FFmpegService {
  @override
  Future<void> initialize() {
    throw UnimplementedError(
      'FFmpegService is not implemented for this platform',
    );
  }

  @override
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension, {
    String? outputDirectory,
    String? outputFilename,
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError(
      'FFmpegService is not implemented for this platform',
    );
  }

  @override
  Future<void> cancel() {
    throw UnimplementedError(
      'FFmpegService is not implemented for this platform',
    );
  }
}
