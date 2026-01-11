import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'ffmpeg_service_interface.dart';

class FFmpegServiceImpl implements FFmpegService {
  late FFmpeg _ffmpeg;
  bool _isLoaded = false;

  @override
  Future<void> initialize() async {
    if (_isLoaded) return;
    _ffmpeg = createFFmpeg(CreateFFmpegParam(log: true));
    await _ffmpeg.load();
    _isLoaded = true;
    debugPrint('FFmpeg Web Initialized');
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
    if (!_isLoaded) await initialize();
    final inputData = await input.readAsBytes();
    final inputName =
        'input_${DateTime.now().millisecondsSinceEpoch}.${input.name.split('.').last}';
    final outputName = outputFilename ?? 'output.$outputExtension';

    debugPrint('Writing to MEMFS: $inputName');
    _ffmpeg.writeFile(inputName, inputData);

    final runArgs = ['-i', inputName, ...args, outputName];
    debugPrint('Running FFmpeg (Web): ${runArgs.join(' ')}');

    await _ffmpeg.run(runArgs);

    debugPrint('Reading from MEMFS: $outputName');
    final outputData = _ffmpeg.readFile(outputName);

    _ffmpeg.unlink(inputName);

    return XFile.fromData(Uint8List.fromList(outputData!), name: outputName);
  }

  @override
  Future<void> cancel() async {
    _ffmpeg.exit();
    _isLoaded = false;
  }
}
