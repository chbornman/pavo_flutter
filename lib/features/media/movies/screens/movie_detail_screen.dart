import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:pavo_flutter/features/media/movies/providers/movies_provider.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';

class MovieDetailScreen extends ConsumerWidget {
  final String movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: jellyfinService.getImageUrl(selectedMovie.id),
                    cacheManager: JellyfinImageCacheManager(),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedMovie.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMovieInfo(context, selectedMovie),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _playMovie(context, selectedMovie.id),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play Movie'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (selectedMovie.overview?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedMovie.overview!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (selectedMovie.genres.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Genres',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedMovie.genres
                          .map((genre) => Chip(
                                label: Text(genre),
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context, MediaItem movie) {
    final infoParts = <String>[];
    
    if (movie.premiereDate != null) {
      infoParts.add(movie.premiereDate!.year.toString());
    }
    
    if (movie.runtime != null && movie.runtime! > 0) {
      final hours = movie.runtime! ~/ 3600;
      final minutes = (movie.runtime! % 3600) ~/ 60;
      if (hours > 0) {
        infoParts.add('${hours}h ${minutes}m');
      } else {
        infoParts.add('${minutes}m');
      }
    }

    if (movie.rating != null) {
      infoParts.add('★ ${movie.rating!.toStringAsFixed(1)}');
    }

    return Text(
      infoParts.join(' • '),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _playMovie(BuildContext context, String movieId) {
    context.push('/movies/player/$movieId');
  }
}