import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/track.dart';
import 'track_tile.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onPlayAlbum;
  final Function(int) onPlayTrack;
  final Track? currentTrack;
  final bool isPlaying;

  const AlbumCard({
    super.key,
    required this.album,
    required this.isExpanded,
    required this.onTap,
    required this.onPlayAlbum,
    required this.onPlayTrack,
    this.currentTrack,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlbumPlaying = currentTrack != null && 
                          album.tracks.any((t) => t.id == currentTrack!.id) && 
                          isPlaying;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Album header
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Row(
                children: [
                  // Album art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    child: SizedBox(
                      width: isExpanded ? 80 : 64,
                      height: isExpanded ? 80 : 64,
                      child: album.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: album.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.album_outlined,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.album_outlined,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.album_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.padding),
                  
                  // Album info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: isExpanded ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getAlbumSubtitle(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isAlbumPlaying) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.graphic_eq,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Playing',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Play button and expand icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onPlayAlbum,
                        icon: const Icon(Icons.play_circle_filled),
                        iconSize: 36,
                        color: theme.colorScheme.primary,
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded track list
          if (isExpanded && album.tracks.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                children: album.tracks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final track = entry.value;
                  final isCurrentTrack = currentTrack?.id == track.id;
                  
                  return TrackTile(
                    track: track,
                    trackNumber: track.indexNumber ?? (index + 1),
                    isCurrentTrack: isCurrentTrack,
                    isPlaying: isCurrentTrack && isPlaying,
                    onTap: () => onPlayTrack(index),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _getAlbumSubtitle() {
    final parts = <String>[];
    
    if (album.year != null) {
      parts.add(album.year.toString());
    }
    
    if (album.tracks.isNotEmpty) {
      parts.add('${album.tracks.length} tracks');
    }
    
    if (album.totalDuration != null) {
      final minutes = album.totalDuration!.inMinutes;
      if (minutes < 60) {
        parts.add('$minutes min');
      } else {
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        parts.add('${hours}h ${mins}m');
      }
    }
    
    return parts.join(' • ');
  }
}