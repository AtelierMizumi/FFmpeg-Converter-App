import 'package:cross_file/cross_file.dart';

abstract class FFmpegService {
  Future<void> initialize();
  Future<XFile?> convertVideo(
    XFile input,
    List<String> args,
    String outputExtension, {
    String? outputDirectory,
  });
}
