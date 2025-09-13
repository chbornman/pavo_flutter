import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/movies/widgets/movie_grid.dart';
import 'package:pavo_flutter/features/media/tv_shows/widgets/tv_show_grid.dart';

final mediaTypeProvider = StateProvider<MediaType>((ref) => MediaType.movies);

enum MediaType { movies, shows }

class MediaScreen extends ConsumerWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = ref.watch(mediaTypeProvider);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: mediaType == MediaType.movies ? 0 : 1,
            children: const [
              MovieGrid(),
              TVShowGrid(),
            ],
          ),
          // Use a custom floating filter bar that includes the media type toggle
          MediaFloatingFilterBar(
            currentMediaType: mediaType,
            onMediaTypeChanged: (newType) {
              ref.read(mediaTypeProvider.notifier).state = newType;
            },
          ),
        ],
      ),
    );
  }
}

class MediaFloatingFilterBar extends StatefulWidget {
  final MediaType currentMediaType;
  final Function(MediaType) onMediaTypeChanged;

  const MediaFloatingFilterBar({
    super.key,
    required this.currentMediaType,
    required this.onMediaTypeChanged,
  });

  @override
  State<MediaFloatingFilterBar> createState() => _MediaFloatingFilterBarState();
}

class _MediaFloatingFilterBarState extends State<MediaFloatingFilterBar>
    with TickerProviderStateMixin {
  bool _isSearchExpanded = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Filter chips pill on the left (includes media type toggle)
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Media type toggle
                  Expanded(
                    child: SegmentedButton<MediaType>(
                      segments: const [
                        ButtonSegment<MediaType>(
                          value: MediaType.movies,
                          label: Text('Movies'),
                          icon: Icon(Icons.movie, size: 16),
                        ),
                        ButtonSegment<MediaType>(
                          value: MediaType.shows,
                          label: Text('Shows'),
                          icon: Icon(Icons.tv, size: 16),
                        ),
                      ],
                      selected: {widget.currentMediaType},
                      onSelectionChanged: (Set<MediaType> newSelection) {
                        widget.onMediaTypeChanged(newSelection.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStateProperty.all(
                          Theme.of(context).textTheme.labelSmall,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  ),

                  // Sort options
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.sort,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Sort by',
                      onSelected: (value) {
                        // TODO: Implement media sorting
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'title_asc',
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha, size: 18),
                              SizedBox(width: 8),
                              Text('Title A-Z'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'year_desc',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18),
                              SizedBox(width: 8),
                              Text('Newest First'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search circle on the right
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Search icon button
                    IconButton(
                      icon: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      onPressed: _toggleSearch,
                    ),

                    // Expandable overlay when expanded
                    if (_isSearchExpanded)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Opacity(
                            opacity: _searchAnimation.value,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search movies and shows...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              onChanged: (query) {
                                // TODO: Implement universal search across movies and TV shows
                              },
                              autofocus: true,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}