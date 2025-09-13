import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/shared/services/jellyfin_image_cache_manager.dart';

class MovieCard extends StatelessWidget {
  final MediaItem movie;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final jellyfinService = JellyfinService();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: CachedNetworkImage(
          imageUrl: jellyfinService.getImageUrl(movie.id),
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
              Icons.movie,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}