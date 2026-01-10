import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gap/gap.dart';
import '../../services/ffmpeg_service.dart';

class ConverterTab extends StatefulWidget {
  const ConverterTab({super.key});

  @override
  State<ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends State<ConverterTab>
    with AutomaticKeepAliveClientMixin {
  final FFmpegService _ffmpegService = FFmpegServiceFactory.getService();
  XFile? _selectedFile;
  XFile? _outputFile;
  bool _isProcessing = false;
  String _statusMessage = 'Ready';
  bool _isDragging = false;
  bool _initialized = false;

  // Expanded Settings
  String _videoCodec = 'libx264';
  String _preset = 'medium';
  double _crf = 23;
  String _resolution = 'Original';
  String _container = 'mp4';
  String _audioSetting = 'Default (AAC)';

  // Static options
  final List<String> _resolutions = ['Original', '1080p', '720p', '480p'];
  final List<String> _containers = ['mp4', 'webm', 'mkv', 'mov'];
  final List<String> _audioOptions = [
    'Default (AAC)',
    'Copy (No Re-encode)',
    'No Audio (Mute)',
  ];

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    _initFFmpeg();
  }

  Future<void> _initFFmpeg() async {
    try {
      await _ffmpegService.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted)
        setState(() => _statusMessage = 'Error initializing FFmpeg: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        if (file.path != null) {
          _selectedFile = XFile(file.path!);
        } else if (file.bytes != null) {
          _selectedFile = XFile.fromData(file.bytes!, name: file.name);
        }
        _outputFile = null;
      });
    }
  }

  Future<void> _processVideo() async {
    if (_selectedFile == null) return;
    if (!_initialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FFmpeg initializing... wait a moment')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing...';
      _outputFile = null;
    });

    try {
      final args = <String>[];

      // Video Codec
      args.addAll(['-c:v', _videoCodec]);

      // Preset & CRF (Only specific to libx264/libvpx, generally safe to pass)
      if (_videoCodec != 'copy') {
        args.addAll(['-preset', _preset]);
        // Note: VP9 uses -crf too but values differ slightly. simple logic for now.
        args.addAll(['-crf', _crf.toInt().toString()]);
      }

      // Resolution (Scale filter)
      if (_resolution != 'Original') {
        String scaleVal;
        switch (_resolution) {
          case '1080p':
            scaleVal = '-2:1080';
            break;
          case '720p':
            scaleVal = '-2:720';
            break;
          case '480p':
            scaleVal = '-2:480';
            break;
          default:
            scaleVal = '-2:720';
        }
        args.addAll(['-vf', 'scale=$scaleVal']);
      }

      // Audio
      if (_audioSetting == 'No Audio (Mute)') {
        args.add('-an');
      } else if (_audioSetting == 'Copy (No Re-encode)') {
        args.addAll(['-c:a', 'copy']);
      } else {
        // Default AAC
        args.addAll(['-c:a', 'aac', '-b:a', '128k']);
      }

      final result = await _ffmpegService.convertVideo(
        _selectedFile!,
        args,
        _container,
      );

      if (mounted) {
        setState(() {
          _outputFile = result;
          _statusMessage = 'Success! Output ready.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'Error: $e');
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveOutput() async {
    if (_outputFile == null) return;
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Video',
      fileName: 'converted_${_outputFile!.name}',
    );
    if (outputFile != null) {
      await _outputFile!.saveTo(outputFile);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved to $outputFile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel: Input/Output
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildDropZone(context),
                  const Gap(24),
                  if (_isProcessing)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        Gap(16),
                        Text('Đang xử lý...'),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: _selectedFile != null
                              ? _processVideo
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Bắt đầu chuyển đổi'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const Gap(16),
                        if (_outputFile != null)
                          FilledButton.icon(
                            onPressed: _saveOutput,
                            icon: const Icon(Icons.download),
                            label: const Text('Lưu file kết quả'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                      ],
                    ),
                  const Gap(16),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.startsWith('Error')
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            // Right Panel: Settings
            Expanded(
              flex: 5,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      Text(
                        'Cấu hình Encode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(20),

                      _buildDropdown(
                        'Container Format (Đuôi file)',
                        _container,
                        _containers,
                        (v) => setState(() => _container = v!),
                      ),
                      const Gap(16),
                      _buildDropdown(
                        'Video Codec',
                        _videoCodec,
                        ['libx264', 'libvpx-vp9', 'copy'],
                        (v) => setState(() => _videoCodec = v!),
                      ),
                      const Gap(16),
                      _buildDropdown(
                        'Resolution (Độ phân giải)',
                        _resolution,
                        _resolutions,
                        (v) => setState(() => _resolution = v!),
                      ),
                      const Gap(16),
                      _buildDropdown(
                        'Audio Settings',
                        _audioSetting,
                        _audioOptions,
                        (v) => setState(() => _audioSetting = v!),
                      ),

                      const Gap(24),
                      const Divider(),
                      const Gap(16),

                      Text(
                        'Video Quality (CRF): ${_crf.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _crf,
                        min: 0,
                        max: 51,
                        divisions: 51,
                        label: _crf.round().toString(),
                        onChanged: (v) => setState(() => _crf = v),
                      ),
                      const Text(
                        'Lower = Better Quality (Larger Size)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                      const Gap(16),
                      _buildDropdown('Preset (Speed)', _preset, [
                        'ultrafast',
                        'fast',
                        'medium',
                        'slow',
                        'veryslow',
                      ], (v) => setState(() => _preset = v!)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DropTarget(
        onDragDone: (detail) {
          if (detail.files.isNotEmpty) {
            setState(() {
              _selectedFile = detail.files.first;
              _outputFile = null;
            });
          }
        },
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        child: InkWell(
          onTap: _pickFile,
          child: Container(
            decoration: BoxDecoration(
              color: _isDragging
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
                style: BorderStyle.dashed,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(16),
                Text(
                  _selectedFile == null
                      ? 'Kéo thả video vào đây\nhoặc click để chọn file'
                      : 'Đã chọn:\n${_selectedFile!.name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
