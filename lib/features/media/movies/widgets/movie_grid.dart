import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/movies/providers/movies_provider.dart';
import 'package:pavo_flutter/features/media/movies/widgets/movie_card.dart';
import 'package:pavo_flutter/features/media/movies/screens/movie_detail_screen.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';

class MovieGrid extends ConsumerWidget {
  const MovieGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesProvider);
    
    return moviesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load movies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(moviesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (movies) {
        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No movies found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Jellyfin movie library appears to be empty',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Preload first batch of movie posters for better UX
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preloadMoviePosters(movies);
        });

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(moviesProvider);
            await ref.read(moviesProvider.future);
          },
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(
              16, 
              MediaQuery.of(context).padding.top + kToolbarHeight + 16, // Top padding for app bar
              16, 
              100, // Bottom padding for floating filter bar
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () => _navigateToMovieDetail(context, ref, movie),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToMovieDetail(BuildContext context, WidgetRef ref, MediaItem movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movie.id),
      ),
    );
  }

  void _preloadMoviePosters(List<MediaItem> movies) {
    final jellyfinService = JellyfinService();
    final imageUrls = movies
        .take(20) // Limit to first 20 movies
        .map((movie) => jellyfinService.getImageUrl(movie.id))
        .toList();
    
    JellyfinCacheUtils.preloadMoviePosters(imageUrls);
  }
}