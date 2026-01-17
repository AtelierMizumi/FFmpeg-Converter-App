import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_test_application/l10n/app_localizations.dart';

import '../../services/ffmpeg_service.dart';
import '../../services/video_validator.dart';

class EditorTab extends StatefulWidget {
  const EditorTab({super.key});

  @override
  State<EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends State<EditorTab>
    with AutomaticKeepAliveClientMixin {
  final FFmpegService _ffmpegService = FFmpegServiceFactory.getService();

  // State
  String _mode = 'trim'; // 'trim' or 'merge'
  XFile? _selectedFile; // For Trim
  List<XFile> _mergeFiles = []; // For Merge

  // Trim State
  RangeValues _trimRange = const RangeValues(0, 100);
  double _totalDurationSeconds = 100.0; // Mock default

  // Processing State
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = 'Ready';
  XFile? _outputFile;
  String? _outputDirectory;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ffmpegService.initialize();
  }

  // --- File Picking ---

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      XFile? xFile;

      if (kIsWeb) {
        if (file.bytes != null) {
          xFile = XFile.fromData(file.bytes!, name: file.name);
        }
      } else {
        if (file.path != null) {
          xFile = XFile(file.path!);
        }
      }

      if (xFile != null) {
        // Validate
        final validation = await VideoValidator.validateInputFile(xFile);
        if (!validation.isValid) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(validation.error!)));
          }
          return;
        }

        setState(() {
          if (_mode == 'trim') {
            _selectedFile = xFile;
            // Reset trim range (mock duration for now, ideally read from file)
            _totalDurationSeconds = 100.0; // TODO: Get real duration
            _trimRange = RangeValues(0, _totalDurationSeconds);
          } else {
            _mergeFiles.add(xFile!);
          }
          _outputFile = null;
        });
      }
    }
  }

  Future<void> _pickOutputDirectory() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _outputDirectory = result;
      });
    }
  }

  // --- Processing ---

  Future<void> _processTrim() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = l10n.processing;
    });

    try {
      // Logic for Trim: ffmpeg -ss START -to END -i INPUT -c copy OUTPUT

      String targetDir;
      if (_outputDirectory != null) {
        targetDir = _outputDirectory!;
      } else {
        final tempDir = await getTemporaryDirectory();
        targetDir = tempDir.path;
      }

      final ext = _selectedFile!.name.split('.').last;
      final outputName = 'trim_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final outputPath = p.join(targetDir, outputName);

      final start = _trimRange.start;
      final end = _trimRange.end;

      // Format seconds to HH:MM:SS.mmm
      String formatTime(double seconds) {
        final duration = Duration(milliseconds: (seconds * 1000).toInt());
        return duration.toString().split('.').first.padLeft(8, '0');
      }

      final args = [
        '-ss', formatTime(start),
        '-to', formatTime(end),
        '-i',
        _selectedFile!
            .path, // Input MUST be after seeking options for faster seeking
        '-c', 'copy', // Fast stream copy
        '-y',
        outputPath,
      ];

      // Note: Our current interface is file-centric.
      // We might need to adjust executeFFmpeg usage.
      // But for simple trim, we can use a direct call if we expose it,
      // or use the generic execute if available.
      // Let's use the generic execute we just added.

      final result = await _ffmpegService.executeFFmpeg(
        args,
        onProgress: (p, m) {
          if (mounted)
            setState(() {
              _progress = p;
              _statusMessage = m;
            });
        },
      );

      if (mounted) {
        setState(() {
          _outputFile = result;
          _statusMessage = l10n.statusSuccess;
          _progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = l10n.statusError(e));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveOutput() async {
    if (_outputFile == null) return;
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Video',
      fileName: 'edited_${_outputFile!.name}',
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

  // --- UI Components ---

  Widget _buildTrimControls() {
    final l10n = AppLocalizations.of(context)!;

    // Format duration helper
    String formatDuration(double s) {
      final d = Duration(milliseconds: (s * 1000).toInt());
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return "${d.inHours}:$m:$sec";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.trimVideo, style: Theme.of(context).textTheme.titleLarge),
        const Gap(16),
        if (_selectedFile != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.movie),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _selectedFile!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  RangeSlider(
                    values: _trimRange,
                    min: 0.0,
                    max: _totalDurationSeconds,
                    divisions: 100,
                    labels: RangeLabels(
                      formatDuration(_trimRange.start),
                      formatDuration(_trimRange.end),
                    ),
                    onChanged: (values) {
                      setState(() => _trimRange = values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${l10n.startTime}: ${formatDuration(_trimRange.start)}",
                      ),
                      Text(
                        "${l10n.endTime}: ${formatDuration(_trimRange.end)}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
        ] else
          _buildDropZone(context),
      ],
    );
  }

  Widget _buildMergeControls() {
    final l10n = AppLocalizations.of(context)!;
    // Placeholder for Merge Mode
    return Center(child: Text(l10n.modeMerge + " (Coming Soon)"));
  }

  Widget _buildDropZone(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DropTarget(
        onDragDone: (detail) async {
          // Reuse existing logic
          if (detail.files.isNotEmpty) {
            // ...
          }
        },
        child: InkWell(
          onTap: _pickFile,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Text(l10n.dragDropText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Mode Switcher
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'trim',
                    label: Text(l10n.modeTrim),
                    icon: const Icon(Icons.cut),
                  ),
                  ButtonSegment(
                    value: 'merge',
                    label: Text(l10n.modeMerge),
                    icon: const Icon(Icons.merge),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _mode = newSelection.first);
                },
              ),
              const Gap(24),

              // Main Content Area
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _mode == 'trim'
                          ? _buildTrimControls()
                          : _buildMergeControls(),
                    ),
                    const Gap(32),
                    // Actions Panel
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.sectionSettings,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Gap(16),
                              if (isDesktop) ...[
                                InkWell(
                                  onTap: _pickOutputDirectory,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: l10n.pickOutputFolder,
                                      border: const OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _outputDirectory ?? l10n.notSelected,
                                    ),
                                  ),
                                ),
                                const Gap(16),
                              ],

                              if (_isProcessing) ...[
                                LinearProgressIndicator(value: _progress),
                                const Gap(8),
                                Text(
                                  _statusMessage,
                                  textAlign: TextAlign.center,
                                ),
                              ] else ...[
                                FilledButton.icon(
                                  onPressed: _mode == 'trim'
                                      ? (_selectedFile != null
                                            ? _processTrim
                                            : null)
                                      : null, // Merge not impl yet
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(
                                    _mode == 'trim'
                                        ? l10n.processTrim
                                        : l10n.processMerge,
                                  ),
                                ),
                              ],

                              if (_outputFile != null) ...[
                                const Gap(24),
                                const Divider(),
                                const Gap(16),
                                Text(
                                  l10n.statusSuccess,
                                  style: const TextStyle(color: Colors.green),
                                ),
                                const Gap(8),
                                FilledButton.icon(
                                  onPressed: _saveOutput,
                                  icon: const Icon(Icons.save),
                                  label: Text(l10n.saveOutput),
                                ),
                                if (isDesktop) ...[
                                  const Gap(8),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        OpenFile.open(_outputFile!.path),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open Video'),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
