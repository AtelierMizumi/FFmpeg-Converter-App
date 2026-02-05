import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gap/gap.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ffmpeg_converter_app/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/ffmpeg_service.dart';
import '../../services/video_validator.dart';
import '../widgets/video_comparison.dart';

class ConverterTab extends StatefulWidget {
  const ConverterTab({super.key});

  @override
  State<ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends State<ConverterTab>
    with AutomaticKeepAliveClientMixin {
  final FFmpegService _ffmpegService = FFmpegServiceFactory.getService();
  final TextEditingController _filenameController = TextEditingController();
  XFile? _selectedFile;
  XFile? _outputFile;
  String? _outputDirectory; // Directory to save output
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = 'Ready';
  bool _isDragging = false;
  bool _initialized = false;
  bool _isCancelling = false;

  // Throttle progress updates to avoid excessive rebuilds
  DateTime? _lastProgressUpdate;
  static const _progressThrottleDuration = Duration(milliseconds: 100);

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
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Error initializing FFmpeg: $e');
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Changed from FileType.video to FileType.any
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      XFile? selectedXFile;

      // On Web, path is often null, so we must rely on bytes or the web-specific logic
      if (kIsWeb) {
        if (file.bytes != null) {
          selectedXFile = XFile.fromData(file.bytes!, name: file.name);
        } else {
          // Fallback if bytes are missing (rare on web unless configured oddly)
          // XFile.fromData is the standard way to handle web file picking in cross_file
          // We'll try to use the readStream if available, but file_picker primarily gives bytes on web
        }
      } else {
        // Desktop/Mobile
        if (file.path != null) {
          selectedXFile = XFile(file.path!);
        }
      }

      // Safety fallback
      if (selectedXFile == null && file.bytes != null) {
        selectedXFile = XFile.fromData(file.bytes!, name: file.name);
      }

      if (selectedXFile != null) {
        final validation = await VideoValidator.validateInputFile(
          selectedXFile,
        );
        if (!validation.isValid) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(validation.error!)));
          }
          return;
        }

        // Show warning if exists (large file warning)
        if (validation.warning != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validation.warning!),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
        }

        setState(() {
          _selectedFile = selectedXFile;
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

  Future<void> _processVideo() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedFile == null) return;

    // Check Permissions on Android
    // Android 13+ (API 33+) uses granular media permissions (READ_MEDIA_VIDEO)
    // which are already declared in AndroidManifest.xml
    // File picker handles permission requests automatically
    // No need for MANAGE_EXTERNAL_STORAGE permission (removed for Google Play compliance)
    if (Platform.isAndroid) {
      // For Android 13+, file_picker handles READ_MEDIA_VIDEO permission automatically
      // For older Android versions, storage permission is handled by file_picker
      // Only check if permission is permanently denied to guide user to settings
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Storage permission is required. Please enable it in settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // Request permission if not granted (for Android 12 and below)
      if (!storageStatus.isGranted && !storageStatus.isLimited) {
        final result = await Permission.storage.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required.')),
            );
          }
          return;
        }
      }
    }

    if (!_initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FFmpeg initializing... wait a moment')),
        );
      }
      return;
    }

    // Require output directory on Desktop for safety (as requested: prevent memory overflow)
    // On Web, we can't really enforce this in the same way, but we can warn.
    // On Mobile, we use temp directory and user saves manually later.
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    // Allow picking output directory on Android too if desired, but default to temp/cache for safety
    // if not explicitly chosen.

    if (isDesktop && _outputDirectory == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.folderExportRequired)));
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = l10n.processing;
      _outputFile = null;
      _isCancelling = false;
    });

    try {
      final args = <String>[];

      // Video Codec
      args.addAll(['-c:v', _videoCodec]);

      // Codec-specific flags (Preset & CRF/Quality)
      if (_videoCodec == 'libx264' || _videoCodec == 'libx265') {
        args.addAll(['-preset', _preset]);
        args.addAll(['-crf', _crf.toInt().toString()]);
      } else if (_videoCodec == 'libvpx-vp9') {
        // VP9: Map preset to deadline/cpu-used
        if (_preset.contains('fast')) {
          args.addAll(['-deadline', 'realtime', '-cpu-used', '4']);
        } else if (_preset.contains('slow')) {
          args.addAll(['-deadline', 'best', '-cpu-used', '0']);
        } else {
          args.addAll(['-deadline', 'good', '-cpu-used', '2']);
        }
        args.addAll(['-crf', _crf.toInt().toString()]);
      } else if (_videoCodec == 'libaom-av1') {
        // AV1: Map preset to cpu-used (0-8, 8=fastest)
        int cpuUsed = 4;
        if (_preset == 'ultrafast') {
          cpuUsed = 8;
        } else if (_preset == 'fast') {
          cpuUsed = 6;
        } else if (_preset == 'medium') {
          cpuUsed = 4;
        } else if (_preset == 'slow') {
          cpuUsed = 2;
        } else if (_preset == 'veryslow') {
          cpuUsed = 0;
        }
        args.addAll(['-cpu-used', cpuUsed.toString()]);
        args.addAll(['-crf', _crf.toInt().toString()]);
      } else if (_videoCodec == 'libxvid') {
        // MPEG-4: Map CRF (0-51) to qscale (1-31)
        int qscale = 1 + ((_crf / 51) * 30).round();
        args.addAll(['-q:v', qscale.toString()]);
      } else if (_videoCodec != 'copy') {
        // Fallback for unknown codecs if added later
        args.addAll(['-preset', _preset]);
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

      String? customFilename;
      if (_filenameController.text.isNotEmpty) {
        customFilename = _filenameController.text;
        if (!customFilename.endsWith('.$_container')) {
          customFilename += '.$_container';
        }
      }

      final result = await _ffmpegService.convertVideo(
        _selectedFile!,
        args,
        _container,
        outputDirectory: _outputDirectory,
        outputFilename: customFilename,
        onProgress: (progress, message) {
          // Throttle progress updates to avoid excessive UI rebuilds
          final now = DateTime.now();
          if (_lastProgressUpdate != null &&
              now.difference(_lastProgressUpdate!) <
                  _progressThrottleDuration) {
            return; // Skip update if less than throttle duration
          }
          _lastProgressUpdate = now;

          if (mounted) {
            setState(() {
              _progress = progress;
              _statusMessage = message;
            });
          }
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
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _cancelConversion() async {
    setState(() {
      _isCancelling = true;
      _statusMessage = 'Cancelling...';
    });
    await _ffmpegService.cancel();
    setState(() {
      _isProcessing = false;
      _statusMessage = 'Conversion cancelled';
      _progress = 0.0;
    });
  }

  void _showComparison() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedFile == null || _outputFile == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.compareVideo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: VideoComparison(
                    original: _selectedFile!,
                    processed: _outputFile!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveOutput() async {
    // final l10n = AppLocalizations.of(context)!; // l10n is not used
    if (_outputFile == null) return;
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Video',
      fileName: 'converted_${_outputFile!.name}',
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
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    // Show loading state while FFmpeg is initializing
    if (!_initialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const Gap(16),
            Text(
              l10n.initializingFFmpeg,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _statusMessage.startsWith('Error')
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // Determine platform once preferably
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(24.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildLeftPanel(context, isDesktop),
                      ),
                      const Gap(32),
                      Expanded(flex: 5, child: _buildRightPanel(context)),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLeftPanel(context, isDesktop),
                        const Gap(32),
                        _buildRightPanel(context),
                      ],
                    ),
                  ),
          ),
        );
      },
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
      initialValue: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropZone(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DropTarget(
        onDragDone: (detail) async {
          if (detail.files.isNotEmpty) {
            final file = detail.files.first;
            // Capture scaffold messenger before async gap
            final messenger = ScaffoldMessenger.of(context);
            final validation = await VideoValidator.validateInputFile(file);
            if (!validation.isValid) {
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text(validation.error!)),
              );
              return;
            }

            if (!mounted) return;
            setState(() {
              _selectedFile = file;
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
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
                style: BorderStyle.solid,
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
                      ? l10n.dragDropText
                      : l10n.fileSelected(_selectedFile!.name),
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

  Widget _buildLeftPanel(BuildContext context, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildDropZone(context),
        const Gap(16),
        if (isDesktop) ...[
          InkWell(
            onTap: _pickOutputDirectory,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.pickOutputFolder,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Theme.of(context).primaryColor),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      _outputDirectory ?? l10n.notSelected,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const Gap(16),
          TextField(
            controller: _filenameController,
            decoration: const InputDecoration(
              labelText: 'Output Filename (Optional)',
              border: OutlineInputBorder(),
              helperText: 'Leave empty for auto-generated name',
            ),
          ),
          const Gap(24),
        ],

        if (_isProcessing)
          Column(
            children: [
              LinearProgressIndicator(value: _progress),
              const Gap(8),
              Text('${(_progress * 100).toInt()}%'),
              const Gap(16),
              Text(l10n.processing),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isCancelling) ...[
                OutlinedButton.icon(
                  onPressed: _cancelConversion,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelling...'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: _selectedFile != null ? _processVideo : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.startConversion),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (_isProcessing)
                  OutlinedButton.icon(
                    onPressed: _cancelConversion,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
              ],
              const Gap(16),
              if (_outputFile != null) ...[
                if (!isDesktop) // Web & Mobile
                  FilledButton.icon(
                    onPressed: _saveOutput,
                    icon: const Icon(Icons.download),
                    label: Text(l10n.saveOutput),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => OpenFile.open(_outputFile!.path),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Video'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final path = _outputFile!.path;
                            final dir = File(path).parent.path;
                            launchUrl(Uri.directory(dir));
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open Folder'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(8),
                OutlinedButton.icon(
                  onPressed: _showComparison,
                  icon: const Icon(Icons.compare_arrows),
                  label: Text(l10n.compareVideo),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        const Gap(16),
        Text(
          _statusMessage,
          style: TextStyle(
            color: _statusMessage.startsWith('Error')
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(20),

            _buildDropdown(
              l10n.containerFormat,
              _container,
              _containers,
              (v) => setState(() => _container = v!),
            ),
            const Gap(16),
            _buildDropdown(
              l10n.videoCodec,
              _videoCodec,
              [
                'libx264',
                'libx265',
                'libvpx-vp9',
                'libaom-av1',
                'libxvid',
                'copy',
              ],
              (v) {
                setState(() {
                  _videoCodec = v!;
                  // Adjust CRF if out of range for new codec
                  final maxCrf = _getMaxCrfForCodec(v);
                  if (_crf > maxCrf) {
                    _crf = maxCrf.toDouble();
                  }
                });
              },
            ),
            const Gap(16),
            _buildDropdown(
              l10n.resolution,
              _resolution,
              _resolutions,
              (v) => setState(() => _resolution = v!),
            ),
            const Gap(16),
            _buildDropdown(
              l10n.audioSettings,
              _audioSetting,
              _audioOptions,
              (v) => setState(() => _audioSetting = v!),
            ),

            const Gap(24),
            const Divider(),
            const Gap(16),

            Text(
              l10n.qualityCrf(_crf.toInt()),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _crf,
              min: 0,
              max: _getMaxCrfForCodec(_videoCodec).toDouble(),
              divisions: _getMaxCrfForCodec(_videoCodec),
              label: _crf.round().toString(),
              onChanged: (v) => setState(() => _crf = v),
            ),
            Text(
              _getCrfHintText(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const Gap(16),
            _buildDropdown(l10n.presetSpeed, _preset, [
              'ultrafast',
              'fast',
              'medium',
              'slow',
              'veryslow',
            ], (v) => setState(() => _preset = v!)),

            const Gap(32),
            const Divider(),
            const Gap(8),
            Center(
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases',
                  ),
                ),
                icon: const Icon(Icons.system_update),
                label: const Text('Download Desktop Version'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get maximum CRF value for the selected codec
  int _getMaxCrfForCodec(String codec) {
    if (codec == 'copy') {
      return 51; // Not applicable, but provide default
    } else if (codec.contains('vp9') || codec.contains('av1')) {
      // VP9 and AV1 support CRF 0-63
      return 63;
    } else {
      // H.264, H.265, Xvid and others use 0-51
      return 51;
    }
  }

  /// Get hint text for CRF slider based on codec
  String _getCrfHintText() {
    final l10n = AppLocalizations.of(context)!;
    if (_videoCodec == 'copy') {
      return 'Not applicable (copy mode)';
    } else if (_videoCodec.contains('vp9') || _videoCodec.contains('av1')) {
      return '${l10n.lowerBetter} (0-63 for VP9/AV1)';
    } else {
      return '${l10n.lowerBetter} (0-51 for H.264/H.265)';
    }
  }
}
