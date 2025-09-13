import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/logging/log_mixin.dart';
import '../providers/music_player_provider.dart';

class MusicMiniPlayer extends ConsumerWidget with LogMixin {
  MusicMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(musicPlayerProvider);
    final theme = Theme.of(context);

    log.debug('MusicMiniPlayer - currentTrack: ${playbackState.currentTrack?.name}, playerState: ${playbackState.playerState}');

    if (playbackState.currentTrack == null ||
        playbackState.playerState == MusicPlayerState.idle) {
      log.debug('MusicMiniPlayer - Hiding (no track or idle state)');
      return const SizedBox.shrink();
    }

    final track = playbackState.currentTrack!;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: playbackState.progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 2,
          ),
          
          // Player content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.padding,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  // Album art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: track.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: track.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 48,
                              height: 48,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.music_note_outlined,
                                size: 24,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 48,
                              height: 48,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.music_note_outlined,
                                size: 24,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.music_note_outlined,
                              size: 24,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingSmall),
                  
                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          track.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.displayArtist,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous
                      IconButton(
                        onPressed: playbackState.hasPrevious
                            ? () => ref.read(musicPlayerProvider.notifier).previous()
                            : null,
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 24,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      
                      // Play/Pause
                      IconButton(
                        onPressed: playbackState.isLoading
                            ? null
                            : () {
                                final player = ref.read(musicPlayerProvider.notifier);
                                if (playbackState.isPlaying) {
                                  player.pause();
                                } else {
                                  player.play();
                                }
                              },
                        icon: playbackState.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onSurface,
                                ),
                              )
                            : Icon(
                                playbackState.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                        iconSize: 28,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      
                      // Next
                      IconButton(
                        onPressed: playbackState.hasNext
                            ? () => ref.read(musicPlayerProvider.notifier).next()
                            : null,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 24,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      
                      const SizedBox(width: 4),
                      
                      // Queue indicator
                      if (playbackState.queue.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${playbackState.currentIndex + 1}/${playbackState.queue.length}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // Close
                      IconButton(
                        onPressed: () => ref.read(musicPlayerProvider.notifier).stop(),
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}