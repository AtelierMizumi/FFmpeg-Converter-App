import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'services/ffmpeg_service.dart';
import 'services/ffmpeg_service_interface.dart'; // From export

void main() {
  runApp(const FFmpegConverterApp());
}

class FFmpegConverterApp extends StatelessWidget {
  const FFmpegConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FFmpeg Desktop/Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConverterHomePage(),
    );
  }
}

class ConverterHomePage extends StatefulWidget {
  const ConverterHomePage({super.key});

  @override
  State<ConverterHomePage> createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  final FFmpegService _ffmpegService = FFmpegServiceFactory.getService();
  XFile? _selectedFile;
  XFile? _outputFile;
  bool _isProcessing = false;
  String _statusMessage = 'Ready';
  bool _isDragging = false;
  bool _initialized = false;

  // Settings
  String _videoCodec = 'libx264';
  String _preset = 'medium';
  double _crf = 23;

  @override
  void initState() {
    super.initState();
    _initFFmpeg();
  }

  Future<void> _initFFmpeg() async {
    try {
      await _ffmpegService.initialize();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error initializing FFmpeg: $e';
        });
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        setState(() {
          _selectedFile = XFile(file.path!);
          _outputFile = null;
        });
      } else if (file.bytes != null) {
        setState(() {
          _selectedFile = XFile.fromData(file.bytes!, name: file.name);
          _outputFile = null;
        });
      }
    }
  }

  Future<void> _processVideo() async {
    if (_selectedFile == null) return;
    if (!_initialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('FFmpeg not initialized')));
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing... This may take a while.';
      _outputFile = null;
    });

    try {
      // Construct Arguments
      final args = <String>[
        '-c:v', _videoCodec,
        '-preset', _preset,
        '-crf', _crf.toInt().toString(),
        // Add basic audio generic setting
        '-c:a', 'aac',
      ];

      // Use mp4 as default container
      final result = await _ffmpegService.convertVideo(
        _selectedFile!,
        args,
        'mp4',
      );

      setState(() {
        _outputFile = result;
        _statusMessage = 'Success! Output file ready.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
      print(e);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveOutput() async {
    if (_outputFile == null) return;

    // Simple Save logic
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Video',
      fileName: _outputFile!.name,
    );

    if (outputFile != null) {
      await _outputFile!.saveTo(outputFile);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved to $outputFile')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local FFmpeg Converter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drop Zone / File Picker
              Expanded(
                flex: 2,
                child: DropTarget(
                  onDragDone: (detail) {
                    if (detail.files.isNotEmpty) {
                      setState(() {
                        _selectedFile = detail.files.first;
                        _outputFile = null;
                      });
                    }
                  },
                  onDragEntered: (detail) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onDragExited: (detail) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: InkWell(
                    onTap: _pickFile,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.5)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_file,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Gap(16),
                          Text(
                            _selectedFile == null
                                ? 'Drag & Drop Video Here\nor Click to Upload'
                                : 'Selected: ${_selectedFile!.name}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(24),

              // Settings
              Text(
                'Encoder Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Video Codec',
                      ),
                      value: _videoCodec,
                      items: const [
                        DropdownMenuItem(
                          value: 'libx264',
                          child: Text('H.264'),
                        ),
                        DropdownMenuItem(
                          value: 'libvpx-vp9',
                          child: Text('VP9 (Web/Linux)'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _videoCodec = v!),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Preset'),
                      value: _preset,
                      items: const [
                        DropdownMenuItem(
                          value: 'ultrafast',
                          child: Text('Ultrafast'),
                        ),
                        DropdownMenuItem(value: 'fast', child: Text('Fast')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'slow', child: Text('Slow')),
                      ],
                      onChanged: (v) => setState(() => _preset = v!),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quality (CRF): ${_crf.toInt()} (Lower is better)'),
                  Slider(
                    value: _crf,
                    min: 0,
                    max: 51,
                    divisions: 51,
                    onChanged: (v) => setState(() => _crf = v),
                  ),
                ],
              ),
              const Gap(24),

              // Actions
              if (_isProcessing)
                const Column(
                  children: [
                    LinearProgressIndicator(),
                    Gap(8),
                    Text('Encoding...'),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _selectedFile != null ? _processVideo : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Encoding'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),

              const Gap(16),

              if (_outputFile != null && !_isProcessing)
                FilledButton.icon(
                  onPressed: _saveOutput,
                  icon: const Icon(Icons.download),
                  label: const Text('Save Output'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),

              const Gap(16),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusMessage.startsWith('Error')
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
