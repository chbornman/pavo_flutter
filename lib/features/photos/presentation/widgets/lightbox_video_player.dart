import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LightboxVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Map<String, String>? headers;

  const LightboxVideoPlayer({
    super.key,
    required this.videoUrl,
    this.headers,
  });

  @override
  State<LightboxVideoPlayer> createState() => _LightboxVideoPlayerState();
}

class _LightboxVideoPlayerState extends State<LightboxVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: widget.headers ?? {},
      );
      
      await _videoController.initialize();
      
      if (!mounted) return;
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          bufferedColor: Colors.white.withValues(alpha: 0.3),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_file_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load video',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _retryVideo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _retryVideo() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _disposeControllers();
    _initializeVideo();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_file_outlined,
                color: Colors.white54,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _retryVideo,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(
                color: Colors.white,
              ),
      ),
    );
  }
}