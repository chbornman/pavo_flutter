import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Artist image (circular)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.padding),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: artist.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: artist.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person_outline,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person_outline,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_outline,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            
            // Artist info
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    artist.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (artist.albumCount != null || artist.songCount != null)
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    final parts = <String>[];
    if (artist.albumCount != null) {
      parts.add('${artist.albumCount} ${artist.albumCount == 1 ? 'album' : 'albums'}');
    }
    if (artist.songCount != null) {
      parts.add('${artist.songCount} ${artist.songCount == 1 ? 'song' : 'songs'}');
    }
    return parts.join(' • ');
  }
}