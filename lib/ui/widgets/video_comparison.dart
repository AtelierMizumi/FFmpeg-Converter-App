import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
  // MediaKit Players
  late final Player _player1;
  late final Player _player2;
  // MediaKit VideoControllers
  late final VideoController _videoController1;
  late final VideoController _videoController2;

  bool _initialized = false;
  String? _errorMessage;
  double _splitPos = 0.5; // 0.0 to 1.0
  bool _isPlaying = false;
  double _aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    try {
      _player1 = Player();
      _player2 = Player();

      _videoController1 = VideoController(_player1);
      _videoController2 = VideoController(_player2);

      await Future.wait([
        _player1.open(Media(widget.original.path), play: false),
        _player2.open(Media(widget.processed.path), play: false),
      ]);

      // Setup loop
      _player1.setPlaylistMode(PlaylistMode.loop);
      _player2.setPlaylistMode(PlaylistMode.loop);

      // Wait for tracks/video params to update aspect ratio
      // We can listen to one of them.
      _player1.stream.videoParams.listen((params) {
        if (params.aspect != null && params.aspect! > 0) {
          if (mounted) setState(() => _aspectRatio = params.aspect!);
        }
      });

      // Subscribe to playing state to update UI
      _player1.stream.playing.listen((playing) {
        if (mounted && playing != _isPlaying) {
          setState(() => _isPlaying = playing);
        }
      });

      if (mounted) {
        setState(() {
          _initialized = true;
        });
        // Auto play
        _togglePlay();
      }
    } catch (e) {
      debugPrint('Error initializing videos: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Could not load videos. Format might be unsupported.\nError: $e';
        });
      }
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _player1.pause();
      _player2.pause();
    } else {
      _player1.play();
      _player2.play();
    }
  }

  void _replay() {
    _player1.seek(Duration.zero);
    _player2.seek(Duration.zero);
    if (!_isPlaying) _togglePlay();
  }

  @override
  void dispose() {
    _player1.dispose();
    _player2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
            final double height = width / _aspectRatio;

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
                    child: Video(controller: _videoController2),
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
                        child: Video(controller: _videoController1),
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
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlay,
            ),
            IconButton(icon: const Icon(Icons.replay), onPressed: _replay),
          ],
        ),
      ],
    );
  }
}
