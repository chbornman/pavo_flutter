import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/tv_shows/providers/tv_shows_provider.dart';
import 'package:pavo_flutter/features/media/tv_shows/widgets/tv_show_card.dart';
import 'package:pavo_flutter/features/media/tv_shows/screens/tv_show_detail_screen.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';

class TVShowGrid extends ConsumerWidget {
  const TVShowGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowsAsync = ref.watch(tvShowsProvider);
    
    return tvShowsAsync.when(
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
              'Failed to load TV shows',
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
              onPressed: () => ref.invalidate(tvShowsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (tvShows) {
        if (tvShows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tv_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No TV shows found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Jellyfin TV show library appears to be empty',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Preload first batch of TV show posters for better UX
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preloadTVShowPosters(tvShows);
        });

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tvShowsProvider);
            await ref.read(tvShowsProvider.future);
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
            itemCount: tvShows.length,
            itemBuilder: (context, index) {
              final tvShow = tvShows[index];
              return TVShowCard(
                tvShow: tvShow,
                onTap: () => _navigateToTVShowDetail(context, ref, tvShow),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToTVShowDetail(BuildContext context, WidgetRef ref, MediaItem tvShow) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TVShowDetailScreen(showId: tvShow.id),
      ),
    );
  }

  void _preloadTVShowPosters(List<MediaItem> tvShows) {
    final jellyfinService = JellyfinService();
    final imageUrls = tvShows
        .take(20) // Limit to first 20 TV shows
        .map((tvShow) => jellyfinService.getImageUrl(tvShow.id))
        .toList();
    
    JellyfinCacheUtils.preloadMoviePosters(imageUrls);
  }
}