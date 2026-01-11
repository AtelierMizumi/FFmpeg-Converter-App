import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'ffmpeg_service_interface.dart';

class FFmpegServiceMobile implements FFmpegService {
  String? _sessionId;

  String? _getSessionId() => _sessionId;

  @override
  Future<void> initialize() async {
    // FFmpeg Kit is not available - mobile conversion disabled
    debugPrint("FFmpegKit Mobile - Not available (package discontinued)");
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
    throw UnimplementedError(
      'FFmpeg conversion is not available on Android. '
      'The ffmpeg_kit_flutter_full_gpl package has been discontinued. '
      'Please use the web or desktop version of this app for video conversion.',
    );
  }

  @override
  Future<void> cancel() async {
    // Nothing to cancel
  }
}
