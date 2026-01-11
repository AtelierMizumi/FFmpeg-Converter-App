import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'ffmpeg_service_interface.dart';

class FFmpegServiceImpl implements FFmpegService {
  late FFmpeg _ffmpeg;
  bool _isLoaded = false;

  @override
  Future<void> initialize() async {
    if (_isLoaded) return;
    // Initialize FFmpeg.
    // We assume the default corePath works or is handled by the package.
    // If not, we might need:
    // corePath: 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js'
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
    // Note: outputDirectory is ignored on Web as we cannot write directly to FS.
    // The user will save the returned blob.

    // Register progress callback
    if (onProgress != null) {
      _ffmpeg.setProgress((p) {
        // ratio is 0.0 to 1.0 (sometimes > 1 in logs but mainly 0-1)
        onProgress(
          p.ratio,
          'Processing... ${(p.ratio * 100).toStringAsFixed(1)}%',
        );
      });
    }

    final inputData = await input.readAsBytes();
    // Decide extension based on input or just generic?
    // FFmpeg sometimes needs correct extension for input probing.
    final inputName =
        'input_${DateTime.now().millisecondsSinceEpoch}.${input.name.split('.').last}';
    final outputName = outputFilename ?? 'output.$outputExtension';

    debugPrint('Writing to MEMFS: $inputName');
    _ffmpeg.writeFile(inputName, inputData);

    final runArgs = ['-i', inputName, ...args, outputName];
    debugPrint('Running FFmpeg (Web): ${runArgs.join(' ')}');

    await _ffmpeg.run(runArgs);

    debugPrint('Reading from MEMFS: $outputName');
    // readFile returns generic data, cast to Uint8List
    final outputData = _ffmpeg.readFile(outputName);

    // Cleanup input to free memory
    _ffmpeg.unlink(inputName);
    // _ffmpeg.FS.unlink(outputName); // Don't unlink output yet? actually we copy it to XFile

    return XFile.fromData(Uint8List.fromList(outputData!), name: outputName);
  }

  @override
  Future<void> cancel() async {
    _ffmpeg.exit();
    _isLoaded = false;
  }
}
