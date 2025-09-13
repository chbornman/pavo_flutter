import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pavo_flutter/features/media/tv_shows/providers/tv_shows_provider.dart';
import 'package:pavo_flutter/features/media/movies/screens/movie_player_screen.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';

class TVShowDetailScreen extends ConsumerStatefulWidget {
  final String showId;

  const TVShowDetailScreen({
    super.key,
    required this.showId,
  });

  @override
  ConsumerState<TVShowDetailScreen> createState() => _TVShowDetailScreenState();
}

class _TVShowDetailScreenState extends ConsumerState<TVShowDetailScreen> {
  Season? selectedSeason;
  
  @override
  Widget build(BuildContext context) {
    final showAsync = ref.watch(tvShowByIdProvider(widget.showId));
    final seasonsAsync = ref.watch(tvShowSeasonsProvider(widget.showId));
    final jellyfinService = JellyfinService();

    return showAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
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
                'Failed to load TV show',
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
                onPressed: () => ref.invalidate(tvShowByIdProvider(widget.showId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (show) => Scaffold(
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
                      imageUrl: jellyfinService.getImageUrl(show.id),
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
                            Icons.tv,
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
                    Text(
                      show.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildShowInfo(context, show),
                    const SizedBox(height: 24),
                    
                    // Season selector
                    seasonsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Failed to load seasons: $error'),
                      data: (seasons) {
                        if (seasons.isEmpty) {
                          return const Text('No seasons available');
                        }
                        
                        // Set initial selected season
                        if (selectedSeason == null && seasons.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              selectedSeason = seasons.first;
                            });
                          });
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Season',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Season>(
                              value: selectedSeason,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              items: seasons.map((season) {
                                return DropdownMenuItem(
                                  value: season,
                                  child: Text(season.name),
                                );
                              }).toList(),
                              onChanged: (Season? newSeason) {
                                setState(() {
                                  selectedSeason = newSeason;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Episodes list
                    if (selectedSeason != null)
                      _buildEpisodesList(context, ref, widget.showId, selectedSeason!),
                    
                    if (show.overview?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        show.overview!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    
                    if (show.genres.isNotEmpty) ...[
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
                        children: show.genres
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
      ),
    );
  }

  Widget _buildShowInfo(BuildContext context, MediaItem show) {
    final infoParts = <String>[];
    
    if (show.premiereDate != null) {
      infoParts.add(show.premiereDate!.year.toString());
    }
    
    if (show.endDate != null) {
      infoParts.add('- ${show.endDate!.year}');
    }

    if (show.rating != null) {
      infoParts.add('★ ${show.rating!.toStringAsFixed(1)}');
    }

    return Text(
      infoParts.join(' '),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEpisodesList(BuildContext context, WidgetRef ref, String showId, Season season) {
    final episodesAsync = ref.watch(seasonEpisodesProvider(showId, season.id));
    final jellyfinService = JellyfinService();
    
    return episodesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Failed to load episodes: $error'),
      data: (episodes) {
        if (episodes.isEmpty) {
          return const Text('No episodes available');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Episodes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: episode.imageTag != null
                            ? CachedNetworkImage(
                                imageUrl: jellyfinService.getImageUrl(episode.id),
                                cacheManager: JellyfinImageCacheManager(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.tv, size: 24),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.tv, size: 24),
                              ),
                      ),
                    ),
                    title: Text(
                      'Episode ${episode.indexNumber ?? index + 1}: ${episode.name}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (episode.overview != null)
                          Text(
                            episode.overview!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (episode.runtime != null)
                          Text(
                            '${episode.runtime} min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (episode.playedPercentage != null && episode.playedPercentage! > 0)
                          LinearProgressIndicator(
                            value: episode.playedPercentage! / 100,
                            minHeight: 2,
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _playEpisode(context, episode.id),
                    ),
                    onTap: () => _playEpisode(context, episode.id),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _playEpisode(BuildContext context, String episodeId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoviePlayerScreen(movieId: episodeId), // Reusing movie player for episodes
      ),
    );
  }
}