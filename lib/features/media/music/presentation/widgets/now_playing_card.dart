import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/track.dart';

class NowPlayingCard extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final VoidCallback onTap;

  const NowPlayingCard({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium - 4),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: track.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: track.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.music_note_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.music_note_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.music_note_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: AppConstants.paddingSmall),
              
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (isPlaying) ...[
                          Icon(
                            Icons.graphic_eq,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          'Now Playing',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${track.displayArtist} • ${track.album ?? 'Unknown Album'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}