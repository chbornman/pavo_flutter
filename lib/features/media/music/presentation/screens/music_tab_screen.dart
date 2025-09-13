import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../features/photos/presentation/widgets/floating_filter_bar.dart';
import '../providers/music_library_provider.dart';
import '../widgets/artist_card.dart';
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

    return Scaffold(
      body: Stack(
        children: [
           SafeArea(
             top: false,
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
                      // Add top spacing for app bar
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.top,
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
          const FloatingFilterBar(screenType: ScreenType.music),
        ],
      ),
    );
  }
}