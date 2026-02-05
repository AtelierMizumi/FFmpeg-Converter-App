import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gap/gap.dart';

/// A reusable drop zone widget for file selection via drag-and-drop or click.
///
/// This widget provides a consistent UI for file input across the app,
/// reducing code duplication between ConverterTab and EditorTab.
class FileDropZone extends StatefulWidget {
  /// Callback when a file is successfully dropped or picked
  final Future<void> Function(XFile file) onFileSelected;

  /// Optional callback when the tap gesture is detected (for file picker)
  final VoidCallback? onTap;

  /// Text to display when no file is selected
  final String emptyText;

  /// Text to display when a file is selected
  final String? selectedFileName;

  /// Icon to display in the drop zone
  final IconData icon;

  /// Aspect ratio of the drop zone (default 16:9)
  final double aspectRatio;

  /// Optional validator for dropped files
  final Future<bool> Function(XFile file)? validator;

  const FileDropZone({
    super.key,
    required this.onFileSelected,
    this.onTap,
    required this.emptyText,
    this.selectedFileName,
    this.icon = Icons.cloud_upload_outlined,
    this.aspectRatio = 16 / 9,
    this.validator,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: DropTarget(
        onDragDone: (detail) async {
          if (detail.files.isNotEmpty) {
            final file = detail.files.first;

            // Validate if validator is provided
            if (widget.validator != null) {
              final isValid = await widget.validator!(file);
              if (!isValid) return;
            }

            await widget.onFileSelected(file);
          }
        },
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isDragging
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(
                color: _isDragging ? colorScheme.primary : colorScheme.outline,
                width: _isDragging ? 2.5 : 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 64,
                  color: _isDragging
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.8),
                ),
                const Gap(16),
                Text(
                  widget.selectedFileName != null
                      ? widget.selectedFileName!
                      : widget.emptyText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.selectedFileName != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_isDragging) ...[
                  const Gap(8),
                  Text(
                    'Drop to select',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
