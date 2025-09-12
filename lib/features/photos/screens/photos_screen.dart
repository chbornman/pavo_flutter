import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/photo_entity.dart';
import '../presentation/providers/photos_provider.dart';
import '../presentation/widgets/photo_grid.dart';
import '../presentation/widgets/photo_lightbox.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(photosNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final photosState = ref.watch(photosNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          // Filter bar
          _buildFilterBar(context, photosState),
          
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(photosNotifierProvider.notifier).refresh();
              },
              child: _buildContent(context, photosState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, PhotosState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter chips
          FilterChip(
            label: const Text('All'),
            selected: state.activeFilter == null,
            onSelected: (_) {
              ref.read(photosNotifierProvider.notifier).setFilter(null);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Photos'),
            selected: state.activeFilter == PhotoType.image,
            onSelected: (_) {
              ref.read(photosNotifierProvider.notifier)
                  .setFilter(PhotoType.image);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Videos'),
            selected: state.activeFilter == PhotoType.video,
            onSelected: (_) {
              ref.read(photosNotifierProvider.notifier)
                  .setFilter(PhotoType.video);
            },
          ),
          const Spacer(),
          // Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              ref.read(photosNotifierProvider.notifier).setSortBy(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date_desc',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 18,
                      color: state.sortBy == 'date_desc' 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Newest first'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date_asc',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: state.sortBy == 'date_asc' 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Oldest first'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PhotosState state) {
    // Initial loading
    if (state.isLoading && state.photos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (state.hasError && state.photos.isEmpty) {
      return PhotoGridErrorState(
        error: state.error ?? 'Failed to load photos',
        onRetry: () {
          ref.read(photosNotifierProvider.notifier).refresh();
        },
      );
    }

    // Empty state
    if (state.isEmpty) {
      return PhotoGridEmptyState(
        message: state.activeFilter == PhotoType.video
            ? 'No videos found'
            : state.activeFilter == PhotoType.image
                ? 'No photos found'
                : 'No media found',
        icon: state.activeFilter == PhotoType.video
            ? Icons.videocam_off_outlined
            : Icons.photo_library_outlined,
        onRetry: () {
          ref.read(photosNotifierProvider.notifier).refresh();
        },
      );
    }

    // Photo grid
    return PhotoGrid(
      photos: state.photos,
      scrollController: _scrollController,
      isLoading: state.isLoadingMore,
      onLoadMore: () {
        ref.read(photosNotifierProvider.notifier).loadMore();
      },
      onPhotoTap: (photo) {
        _showPhotoViewer(context, photo);
      },
      onPhotoLongPress: (photo) {
        _showPhotoOptions(context, photo);
      },
    );
  }

  void _showPhotoViewer(BuildContext context, PhotoEntity photo) {
    final photos = ref.read(photosNotifierProvider).photos;
    final index = photos.indexWhere((p) => p.id == photo.id);
    
    if (index != -1) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black,
          pageBuilder: (context, animation, secondaryAnimation) => PhotoLightbox(
            photos: photos,
            initialIndex: index,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  void _showPhotoOptions(BuildContext context, PhotoEntity photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                photo.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              title: Text(
                photo.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(photosNotifierProvider.notifier)
                    .toggleFavorite(photo.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Details'),
              onTap: () {
                Navigator.of(context).pop();
                _showPhotoDetails(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download not yet implemented')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetails(BuildContext context, PhotoEntity photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', photo.displayName),
            _buildDetailRow('Type', photo.type.toDisplayString()),
            _buildDetailRow('Size', photo.formattedFileSize),
            if (photo.width != null && photo.height != null)
              _buildDetailRow('Dimensions', '${photo.width} × ${photo.height}'),
            if (photo.createdAt != null)
              _buildDetailRow('Created', photo.createdAt.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}