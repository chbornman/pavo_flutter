import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../domain/entities/photo_entity.dart';
import 'lightbox_video_player.dart';

class PhotoLightbox extends StatefulWidget {
  final List<PhotoEntity> photos;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const PhotoLightbox({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.onPageChanged,
  });

  @override
  State<PhotoLightbox> createState() => _PhotoLightboxState();
}

class _PhotoLightboxState extends State<PhotoLightbox> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
    
    if (_showOverlay) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo viewer
          GestureDetector(
            onTap: _toggleOverlay,
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                final photo = widget.photos[index];
                
                // Handle videos differently from images
                if (photo.isVideo) {
                  final videoUrl = photo.originalUrl ?? '';
                  return PhotoViewGalleryPageOptions.customChild(
                    child: LightboxVideoPlayer(
                      videoUrl: videoUrl,
                      headers: {
                        'x-api-key': EnvConfig.immichApiKey ?? '',
                      },
                    ),
                    heroAttributes: PhotoViewHeroAttributes(tag: 'photo_${photo.id}'),
                  );
                }
                
                // Handle images as before
                final imageUrl = photo.thumbnailUrl ?? photo.originalUrl ?? '';
                
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    imageUrl,
                    headers: {
                      'x-api-key': EnvConfig.immichApiKey ?? '',
                    },
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  heroAttributes: PhotoViewHeroAttributes(tag: 'photo_${photo.id}'),
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              itemCount: widget.photos.length,
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? null
                      : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                  color: Colors.white,
                ),
              ),
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                widget.onPageChanged?.call(index);
              },
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          
          // Top overlay with info and actions
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showOverlay ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      
                      // Photo info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPhoto.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentIndex + 1} / ${widget.photos.length}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      IconButton(
                        icon: Icon(
                          currentPhoto.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: currentPhoto.isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement favorite toggle
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_outlined, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement download
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          _showMoreOptions(context, currentPhoto);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom overlay with metadata
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showOverlay ? 0 : -150,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentPhoto.createdAt != null) ...[
                        Text(
                          _formatDate(currentPhoto.createdAt!),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (currentPhoto.formattedFileSize != null) ...[
                        Text(
                          '${currentPhoto.formattedFileSize} • ${currentPhoto.width ?? 0} × ${currentPhoto.height ?? 0}${currentPhoto.isVideo && currentPhoto.duration != null ? ' • ${currentPhoto.formattedDuration}' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$month $day, $year at $hour:$minute';
  }

  void _showMoreOptions(BuildContext context, PhotoEntity photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Details'),
              onTap: () {
                Navigator.of(context).pop();
                _showPhotoDetails(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement delete
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
            if (photo.formattedFileSize != null)
              _buildDetailRow('Size', photo.formattedFileSize!),
            if (photo.width != null && photo.height != null)
              _buildDetailRow('Dimensions', '${photo.width} × ${photo.height}'),
            if (photo.createdAt != null)
              _buildDetailRow('Created', _formatDate(photo.createdAt!)),
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