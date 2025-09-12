import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../providers/music_library_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/artist_card.dart';
import '../widgets/music_search_bar.dart';
import '../widgets/now_playing_card.dart';
import 'artist_detail_screen.dart';

class MusicTabScreen extends ConsumerStatefulWidget {
  const MusicTabScreen({super.key});

  @override
  ConsumerState<MusicTabScreen> createState() => _MusicTabScreenState();
}

class _MusicTabScreenState extends ConsumerState<MusicTabScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artistsAsync = ref.watch(musicArtistsProvider);
    final playbackState = ref.watch(musicPlayerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Music',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.padding),
                  
                  // Search bar
                  MusicSearchBar(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: artistsAsync.when(
                data: (artists) {
                  // Filter artists based on search
                  final filteredArtists = _searchQuery.isEmpty
                      ? artists
                      : artists.where((artist) =>
                          artist.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                  if (filteredArtists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_music_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppConstants.padding),
                          Text(
                            _searchQuery.isEmpty 
                                ? 'No artists found'
                                : 'No artists match "$_searchQuery"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      // Now Playing Card (if music is playing)
                      if (playbackState.currentTrack != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.padding,
                              vertical: AppConstants.paddingSmall,
                            ),
                            child: NowPlayingCard(
                              track: playbackState.currentTrack!,
                              isPlaying: playbackState.isPlaying,
                              onTap: () {
                                // TODO: Navigate to full screen player
                              },
                            ),
                          ),
                        ),
                      
                      // Artists Grid
                      SliverPadding(
                        padding: const EdgeInsets.all(AppConstants.padding),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: AppConstants.padding,
                            mainAxisSpacing: AppConstants.padding,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final artist = filteredArtists[index];
                              return ArtistCard(
                                artist: artist,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistDetailScreen(
                                        artistId: artist.id,
                                        artistName: artist.name,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: filteredArtists.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: AppConstants.padding),
                      Text(
                        'Failed to load music library',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      FilledButton.tonal(
                        onPressed: () => ref.invalidate(musicArtistsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}