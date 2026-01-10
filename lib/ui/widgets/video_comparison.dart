import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gap/gap.dart';

class VideoComparison extends StatefulWidget {
  final XFile original;
  final XFile processed;

  const VideoComparison({
    super.key,
    required this.original,
    required this.processed,
  });

  @override
  State<VideoComparison> createState() => _VideoComparisonState();
}

class _VideoComparisonState extends State<VideoComparison> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _initialized = false;
  double _splitPos = 0.5; // 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    if (kIsWeb) {
      _controller1 = VideoPlayerController.networkUrl(
        Uri.parse(widget.original.path),
      );
      // For processed blob on web, path is a blob url? or we might need different handling if it's blob data.
      // XFile.path on web refers to blob URL created by XFile.
      _controller2 = VideoPlayerController.networkUrl(
        Uri.parse(widget.processed.path),
      );
    } else {
      _controller1 = VideoPlayerController.file(File(widget.original.path));
      _controller2 = VideoPlayerController.file(File(widget.processed.path));
    }

    await Future.wait([_controller1.initialize(), _controller2.initialize()]);

    // Loop
    _controller1.setLooping(true);
    _controller2.setLooping(true);

    // Sync play/pause is hard without issues, but we can try simple sync
    _controller1.addListener(_syncController);

    setState(() {
      _initialized = true;
    });

    _controller1.play();
    _controller2.play();
  }

  void _syncController() {
    // Basic sync: if drift is too large, snap 2 to 1
    // This is naive and might shudder, but enough for demo.
    // Actually, maybe just rely on them playing at same rate.
    // If not playing, ensure position matches?
    /*
    if (_controller1.value.isPlaying != _controller2.value.isPlaying) {
      if (_controller1.value.isPlaying) _controller2.play();
      else _controller2.pause();
    }
    */
  }

  @override
  void dispose() {
    _controller1.removeListener(_syncController);
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = width / _controller1.value.aspectRatio;

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _splitPos += details.delta.dx / width;
                  _splitPos = _splitPos.clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  // Bottom layer: Processed (Right side)
                  SizedBox(
                    width: width,
                    height: height,
                    child: VideoPlayer(_controller2),
                  ),

                  // Label Right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.black54,
                      child: const Text(
                        'New',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Top layer: Original (Left side), clipped
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _splitPos,
                      child: SizedBox(
                        width: width,
                        height: height, // Ensure same height
                        child: VideoPlayer(_controller1),
                      ),
                    ),
                  ),

                  // Label Left
                  if (_splitPos > 0.1)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black54,
                        child: const Text(
                          'Original',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                  // Divider Line
                  Positioned(
                    left: width * _splitPos,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),

                  // Handle
                  Positioned(
                    left: width * _splitPos - 12,
                    top: height / 2 - 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(blurRadius: 4, color: Colors.black26),
                        ],
                      ),
                      child: const Icon(
                        Icons.code,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller1.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  if (_controller1.value.isPlaying) {
                    _controller1.pause();
                    _controller2.pause();
                  } else {
                    _controller1.play();
                    _controller2.play();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                _controller1.seekTo(Duration.zero);
                _controller2.seekTo(Duration.zero);
                _controller1.play();
                _controller2.play();
              },
            ),
          ],
        ),
      ],
    );
  }
}
