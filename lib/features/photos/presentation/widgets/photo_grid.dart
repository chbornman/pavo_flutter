import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/photo_entity.dart';
import 'photo_grid_item.dart';

/// Responsive photo grid following Material Design
/// Flutter best practice: Use SliverGrid for performance with large lists
class PhotoGrid extends ConsumerWidget {
  final List<PhotoEntity> photos;
  final ScrollController? scrollController;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final Function(PhotoEntity)? onPhotoTap;
  final Function(PhotoEntity)? onPhotoLongPress;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.scrollController,
    this.isLoading = false,
    this.onLoadMore,
    this.onPhotoTap,
    this.onPhotoLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate grid columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Photo grid
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Check if we need to load more
                if (index == photos.length - 10 && onLoadMore != null) {
                  onLoadMore!();
                }

                final photo = photos[index];
                return PhotoGridItem(
                  photo: photo,
                  onTap: () => onPhotoTap?.call(photo),
                  onLongPress: () => onPhotoLongPress?.call(photo),
                );
              },
              childCount: photos.length,
            ),
          ),
        ),
        
        // Loading indicator at bottom
        if (isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  /// Calculate grid columns based on screen width
  /// Follows responsive design principles
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 400) {
      return 2; // Phone portrait
    } else if (screenWidth < 600) {
      return 3; // Phone landscape / small tablet
    } else if (screenWidth < 900) {
      return 4; // Tablet
    } else if (screenWidth < 1200) {
      return 5; // Large tablet / small desktop
    } else {
      return 6; // Desktop
    }
  }
}

/// Empty state widget when no photos
class PhotoGridEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const PhotoGridEmptyState({
    super.key,
    this.message = 'No photos found',
    this.icon = Icons.photo_library_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget
class PhotoGridErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const PhotoGridErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}