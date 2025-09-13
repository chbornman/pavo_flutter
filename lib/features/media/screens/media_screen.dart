import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/movies/widgets/movie_grid.dart';
import 'package:pavo_flutter/features/media/tv_shows/widgets/tv_show_grid.dart';

final mediaTypeProvider = StateProvider<MediaType>((ref) => MediaType.movies);

enum MediaType { movies, shows }

class MediaScreen extends ConsumerWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = ref.watch(mediaTypeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: SegmentedButton<MediaType>(
          segments: const [
            ButtonSegment<MediaType>(
              value: MediaType.movies,
              label: Text('Movies'),
              icon: Icon(Icons.movie),
            ),
            ButtonSegment<MediaType>(
              value: MediaType.shows,
              label: Text('Shows'),
              icon: Icon(Icons.tv),
            ),
          ],
          selected: {mediaType},
          onSelectionChanged: (Set<MediaType> newSelection) {
            ref.read(mediaTypeProvider.notifier).state = newSelection.first;
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStateProperty.all(
              Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: mediaType == MediaType.movies ? 0 : 1,
        children: const [
          MovieGrid(),
          TVShowGrid(),
        ],
      ),
    );
  }
}