import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../providers/audiobooks_provider.dart';

class AudiobookCard extends ConsumerWidget {
  final AudiobookEntity audiobook;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const AudiobookCard({
    super.key,
    required this.audiobook,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coverUrl = ref.watch(coverUrlProvider(audiobook.id, width: 300));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image with full aspect ratio
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.headphones_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.headphones_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Progress indicator overlay
                if (audiobook.hasProgress)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LinearProgressIndicator(
                        value: audiobook.progress,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingSmall),
          
          // Audiobook Info beneath the cover - matching web app style
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center-aligned like web app
            children: [
              // Title - single line with ellipsis like web app
              Text(
                audiobook.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500, // Medium weight like web app
                ),
                maxLines: 1, // Single line only like web app
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 2), // Minimal spacing like web app
              
              // Author - single line with ellipsis like web app
              Text(
                audiobook.author,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11, // Slightly smaller than title
                ),
                maxLines: 1, // Single line only like web app
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              // Progress indicator (optional, minimal like web app)
              if (audiobook.hasProgress) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(audiobook.progress * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ] else if (audiobook.isFinished) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}