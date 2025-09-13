import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';

class TVShowCard extends StatelessWidget {
  final MediaItem tvShow;
  final VoidCallback? onTap;

  const TVShowCard({
    super.key,
    required this.tvShow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final jellyfinService = JellyfinService();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: jellyfinService.getImageUrl(tvShow.id),
              cacheManager: JellyfinImageCacheManager(),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholderFadeInDuration: const Duration(milliseconds: 100),
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.tv,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Show episode count or progress indicator if available
            if (tvShow.userData?.playedPercentage != null && tvShow.userData!.playedPercentage! > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: tvShow.userData!.playedPercentage! / 100,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}