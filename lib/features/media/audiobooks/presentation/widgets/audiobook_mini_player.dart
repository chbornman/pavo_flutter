import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../providers/audiobook_player_provider.dart';
import '../providers/audiobooks_provider.dart';

class AudiobookMiniPlayer extends ConsumerWidget {
  const AudiobookMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(audiobookPlayerProvider);
    final theme = Theme.of(context);

    if (playbackState.currentAudiobook == null ||
        playbackState.playerState == AudiobookPlayerState.idle) {
      return const SizedBox.shrink();
    }

    final audiobook = playbackState.currentAudiobook!;
    final coverUrl = ref.watch(coverUrlProvider(audiobook.id, width: 100));

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
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: coverUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.headphones_outlined,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.headphones_outlined,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingSmall),
                  
                  // Title and author
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          audiobook.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          audiobook.author,
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
                      // Skip backward
                      IconButton(
                        onPressed: playbackState.canPlay
                            ? () => ref.read(audiobookPlayerProvider.notifier)
                                .skipBackward(15) // Shorter skip for mini player
                            : null,
                        icon: const Icon(Icons.replay_30),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      
                      // Play/Pause
                      IconButton(
                        onPressed: playbackState.isLoading
                            ? null
                            : () {
                                final player = ref.read(audiobookPlayerProvider.notifier);
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
                        iconSize: 24,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      
                      // Skip forward
                      IconButton(
                        onPressed: playbackState.canPlay
                            ? () => ref.read(audiobookPlayerProvider.notifier)
                                .skipForward(15) // Shorter skip for mini player
                            : null,
                        icon: const Icon(Icons.forward_30),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      
                      // Close
                      IconButton(
                        onPressed: () => ref.read(audiobookPlayerProvider.notifier).stop(),
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