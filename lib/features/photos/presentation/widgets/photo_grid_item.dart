import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/photo_entity.dart';

/// Individual photo item in the grid
/// Flutter best practice: Stateless widget for performance
class PhotoGridItem extends StatelessWidget {
  final PhotoEntity photo;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const PhotoGridItem({
    super.key,
    required this.photo,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo thumbnail
          Hero(
            tag: 'photo_${photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: photo.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                httpHeaders: {
                  'x-api-key': EnvConfig.immichApiKey ?? '',
                  'Accept': 'image/webp,image/png,image/jpeg,*/*',
                  'Cache-Control': 'max-age=3600',
                },
                placeholder: (context, url) {
                  // Debug: Loading thumbnail (removed print for production)
                  return _buildPlaceholder();
                },
                errorWidget: (context, url, error) {
                  // Error: Failed to load thumbnail (removed print for production)
                  return _buildErrorWidget(error);
                },
                fadeInDuration: const Duration(milliseconds: 200),
              ),
            ),
          ),
          
          // Video indicator overlay
          if (photo.isVideo) _buildVideoOverlay(),
          
          // Favorite indicator
          if (photo.isFavorite) _buildFavoriteIndicator(),
          
          // Selection overlay
          if (isSelected) _buildSelectionOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget([dynamic error]) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 40,
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                'Error loading',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
            if (photo.formattedDuration.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  photo.formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIndicator() {
    return const Positioned(
      top: 8,
      left: 8,
      child: Icon(
        Icons.favorite,
        color: Colors.red,
        size: 20,
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue,
          width: 3,
        ),
        color: Colors.blue.withValues(alpha: 0.2),
      ),
      child: const Center(
        child: Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

}