import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../providers/music_library_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/track_tile.dart';
import '../../domain/entities/album.dart';

class ArtistDetailScreen extends ConsumerStatefulWidget {
  final String artistId;
  final String artistName;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  ConsumerState<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends ConsumerState<ArtistDetailScreen> {
  String? _expandedAlbumId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artistAsync = ref.watch(artistWithAlbumsProvider(widget.artistId));
    final playbackState = ref.watch(musicPlayerProvider);

    return Scaffold(
      body: artistAsync.when(
        data: (artist) {
          return CustomScrollView(
            slivers: [
              // App Bar with artist image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(artist.name),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (artist.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: artist.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.person_outline,
                            size: 80,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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

              // Artist info and play button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (artist.albumCount != null || artist.songCount != null)
                                  Text(
                                    _getArtistStats(artist),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _playAllSongs(artist),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play All'),
                          ),
                        ],
                      ),
                      if (artist.overview != null) ...[
                        const SizedBox(height: AppConstants.padding),
                        Text(
                          artist.overview!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Albums
              if (artist.albums.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.padding,
                      AppConstants.padding,
                      AppConstants.padding,
                      AppConstants.paddingSmall,
                    ),
                    child: Text(
                      'Albums',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = artist.albums[index];
                      final isExpanded = album.id == _expandedAlbumId;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.padding,
                          vertical: AppConstants.paddingSmall,
                        ),
                        child: AlbumCard(
                          album: album,
                          isExpanded: isExpanded,
                          onTap: () {
                            setState(() {
                              _expandedAlbumId = isExpanded ? null : album.id;
                            });
                          },
                          onPlayAlbum: () => _playAlbum(album),
                          onPlayTrack: (trackIndex) => _playAlbumFromTrack(album, trackIndex),
                          currentTrack: playbackState.currentTrack,
                          isPlaying: playbackState.isPlaying,
                        ),
                      );
                    },
                    childCount: artist.albums.length,
                  ),
                ),
              ],
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
                'Failed to load artist details',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(artistWithAlbumsProvider(widget.artistId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getArtistStats(artist) {
    final parts = <String>[];
    if (artist.albumCount != null) {
      parts.add('${artist.albumCount} ${artist.albumCount == 1 ? 'album' : 'albums'}');
    }
    if (artist.songCount != null) {
      parts.add('${artist.songCount} ${artist.songCount == 1 ? 'song' : 'songs'}');
    }
    return parts.join(' • ');
  }

  void _playAllSongs(artist) {
    final allTracks = artist.albums.expand((album) => album.tracks).toList();
    if (allTracks.isNotEmpty) {
      ref.read(musicPlayerProvider.notifier).setQueue(allTracks);
    }
  }

  void _playAlbum(Album album) {
    if (album.tracks.isNotEmpty) {
      ref.read(musicPlayerProvider.notifier).playAlbum(album);
    }
  }

  void _playAlbumFromTrack(Album album, int trackIndex) {
    if (album.tracks.isNotEmpty && trackIndex < album.tracks.length) {
      ref.read(musicPlayerProvider.notifier).playAlbum(album, startIndex: trackIndex);
    }
  }
}