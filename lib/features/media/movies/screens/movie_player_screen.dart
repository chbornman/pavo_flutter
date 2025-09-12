import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/movies/providers/movies_provider.dart';
import 'package:pavo_flutter/features/media/movies/widgets/video_player_widget.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';

class MoviePlayerScreen extends ConsumerStatefulWidget {
  final String movieId;

  const MoviePlayerScreen({
    super.key,
    required this.movieId,
  });

  @override
  ConsumerState<MoviePlayerScreen> createState() => _MoviePlayerScreenState();
}

class _MoviePlayerScreenState extends ConsumerState<MoviePlayerScreen> {
  @override
  void initState() {
    super.initState();
    _setFullScreen();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMovie = ref.watch(selectedMovieProvider);
    final jellyfinService = JellyfinService();

    if (selectedMovie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Movie not found'),
        ),
      );
    }

    final streamUrl = jellyfinService.getStreamUrl(widget.movieId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: VideoPlayerWidget(
        videoUrl: streamUrl,
        title: selectedMovie.name,
      ),
    );
  }
}