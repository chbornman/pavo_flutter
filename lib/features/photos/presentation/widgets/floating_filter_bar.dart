import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/photo_entity.dart';
import '../providers/photos_provider.dart';
import 'search_filter_chip.dart';
import 'filter_bottom_sheet_scaffold.dart';
import 'location_picker.dart';
import 'camera_picker.dart';
import 'media_type_picker.dart';
import 'display_options_picker.dart';

enum ScreenType {
  photos,
  documents,
  movies,
  tvShows,
  music,
  audiobooks,
}

class FloatingFilterBar extends ConsumerStatefulWidget {
  final ScreenType screenType;

  const FloatingFilterBar({
    super.key,
    required this.screenType,
  });

  @override
  ConsumerState<FloatingFilterBar> createState() => _FloatingFilterBarState();
}

class _FloatingFilterBarState extends ConsumerState<FloatingFilterBar>
    with TickerProviderStateMixin {
  bool _isSearchExpanded = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  final TextEditingController _searchController = TextEditingController();

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

    // Initialize search controller with existing query if available
    if (widget.screenType == ScreenType.photos) {
      final photosState = ref.read(photosNotifierProvider);
      _searchController.text = photosState.filters.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        // Clear search when closing
        _searchController.clear();
        _onSearchChanged('');
      }
    });
  }

  void _onSearchChanged(String query) {
    // TODO: Implement universal search across screens
    // For now, search is only functional on photos screen
    if (widget.screenType == ScreenType.photos) {
      final photosState = ref.read(photosNotifierProvider);
      final newFilters = photosState.filters.copyWith(searchQuery: query.trim());
      ref.read(photosNotifierProvider.notifier).updateFilters(newFilters);
    }
  }

  List<Widget> _buildFilterChips(BuildContext context) {
    switch (widget.screenType) {
      case ScreenType.photos:
        return _buildPhotoFilterChips(context);
      case ScreenType.documents:
        return _buildDocumentFilterChips(context);
      case ScreenType.movies:
        return _buildMovieFilterChips(context);
      case ScreenType.tvShows:
        return _buildTVShowFilterChips(context);
      case ScreenType.music:
        return _buildMusicFilterChips(context);
      case ScreenType.audiobooks:
        return _buildAudiobookFilterChips(context);
    }
  }

  List<Widget> _buildPhotoFilterChips(BuildContext context) {
    final photosState = ref.watch(photosNotifierProvider);
    return [
      // Filter chips
      SearchFilterChip(
        icon: Icons.location_on_outlined,
        label: 'Location',
        currentFilter: photosState.filters.country != null ||
                      photosState.filters.state != null ||
                      photosState.filters.city != null
            ? Text([
                photosState.filters.country,
                photosState.filters.state,
                photosState.filters.city,
              ].where((s) => s != null).join(', '))
            : null,
        onTap: () => _showLocationPicker(context, photosState),
      ),

      SearchFilterChip(
        icon: Icons.camera_alt_outlined,
        label: 'Camera',
        currentFilter: photosState.filters.cameraMake != null ||
                      photosState.filters.cameraModel != null
            ? Text([
                photosState.filters.cameraMake,
                photosState.filters.cameraModel,
              ].where((s) => s != null).join(' '))
            : null,
        onTap: () => _showCameraPicker(context, photosState),
      ),

      SearchFilterChip(
        key: const Key('media_type_chip'),
        icon: Icons.video_collection_outlined,
        label: 'Media Type',
        currentFilter: photosState.filters.mediaType != null
            ? Text(photosState.filters.mediaType == PhotoType.image
                ? 'Photos'
                : photosState.filters.mediaType == PhotoType.video
                ? 'Videos'
                : 'All')
            : null,
        onTap: () => _showMediaTypePicker(context, photosState),
      ),

      SearchFilterChip(
        icon: Icons.display_settings_outlined,
        label: 'Display',
        currentFilter: (photosState.filters.isNotInAlbum == true ||
                       photosState.filters.isArchived == true ||
                       photosState.filters.isFavorite == true)
            ? Text([
                if (photosState.filters.isNotInAlbum == true) 'Not in album',
                if (photosState.filters.isArchived == true) 'Archived',
                if (photosState.filters.isFavorite == true) 'Favorites',
              ].join(', '))
            : null,
        onTap: () => _showDisplayOptionsPicker(context, photosState),
      ),

      SearchFilterChip(
        icon: Icons.date_range,
        label: 'Date',
        currentFilter: photosState.filters.dateFrom != null || photosState.filters.dateTo != null
            ? Text(_formatDateRange(photosState.filters.dateFrom, photosState.filters.dateTo))
            : null,
        onTap: () => _showDateRangePicker(context, photosState),
      ),

      // Sort options
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
                    color: photosState.sortBy == 'date_desc'
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
                    color: photosState.sortBy == 'date_asc'
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
      ),

      // Clear filters button (only show if filters are active)
      if (photosState.filters.hasActiveFilters)
        Container(
          margin: const EdgeInsets.only(left: 8),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              Icons.clear_all,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              ref.read(photosNotifierProvider.notifier).updateFilters(const PhotoFilters());
            },
            tooltip: 'Clear all filters',
            padding: EdgeInsets.zero,
          ),
        ),
    ];
  }



  List<Widget> _buildDocumentFilterChips(BuildContext context) {
    // For now, just return a simple sort option for documents
    return [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Sort by',
          onSelected: (value) {
            // TODO: Implement document sorting
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'name_asc',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 8),
                  Text('Name A-Z'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'name_desc',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 8),
                  Text('Name Z-A'),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMovieFilterChips(BuildContext context) {
    // For now, just return a simple sort option for movies
    return [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Sort by',
          onSelected: (value) {
            // TODO: Implement movie sorting
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
                  Text('Newest first'),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildTVShowFilterChips(BuildContext context) {
    // For now, just return a simple sort option for TV shows
    return [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Sort by',
          onSelected: (value) {
            // TODO: Implement TV show sorting
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'name_asc',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 8),
                  Text('Name A-Z'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'year_desc',
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18),
                  SizedBox(width: 8),
                  Text('Newest first'),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMusicFilterChips(BuildContext context) {
    return [
      // Sort options
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Sort by',
          onSelected: (value) {
            // TODO: Implement music sorting
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'artist_asc',
              child: Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text('Artist A-Z'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'album_asc',
              child: Row(
                children: [
                  Icon(Icons.album, size: 18),
                  SizedBox(width: 8),
                  Text('Album A-Z'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'title_asc',
              child: Row(
                children: [
                  Icon(Icons.music_note, size: 18),
                  SizedBox(width: 8),
                  Text('Title A-Z'),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildAudiobookFilterChips(BuildContext context) {
    // TODO: Implement proper audiobook filter/sort state management
    // For now, return placeholder chips that will be connected to providers later
    return [
      // Filter by status chip
      SearchFilterChip(
        icon: Icons.filter_list,
        label: 'Status',
        currentFilter: Text('All Books'), // TODO: Connect to actual filter state
        onTap: () {
          // TODO: Show filter options (All, In Progress, Finished, Not Started)
        },
      ),

      // Sort options
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Sort by',
          onSelected: (value) {
            // TODO: Implement audiobook sorting
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
              value: 'author_asc',
              child: Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text('Author A-Z'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'date_desc',
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18),
                  SizedBox(width: 8),
                  Text('Recently Added'),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }



  String _formatDateRange(DateTime? from, DateTime? to) {
    final dateFormat = DateFormat('MMM d, y');
    if (from == null && to == null) return '';
    if (from != null && to != null) {
      if (from.year == to.year && from.month == to.month && from.day == to.day) {
        return dateFormat.format(from);
      }
      return '${dateFormat.format(from)} - ${dateFormat.format(to)}';
    }
    if (from != null) return 'From ${dateFormat.format(from)}';
    return 'Until ${dateFormat.format(to!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main floating filter bar
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini player pill (shown when there's active playback)
              if (_shouldShowMiniPlayer())
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildMiniPlayerPill(context),
                ),

              // Filter and search row
              Row(
                children: [
                  // Filter chips pill on the left
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _buildFilterChips(context),
                        ),
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
                    child: IconButton(
                      icon: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      onPressed: _toggleSearch,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pill-shaped search window that appears above keyboard
        if (_isSearchExpanded)
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 80, // Position above keyboard
            left: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _searchAnimation.value) * 50), // Slide up animation
                  child: Opacity(
                    opacity: _searchAnimation.value,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: _getSearchHintText(),
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              onChanged: _onSearchChanged,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _getSearchHintText() {
    switch (widget.screenType) {
      case ScreenType.photos:
        return 'Search photos...';
      case ScreenType.documents:
        return 'Search documents...';
      case ScreenType.movies:
        return 'Search movies...';
      case ScreenType.tvShows:
        return 'Search TV shows...';
      case ScreenType.music:
        return 'Search music...';
      case ScreenType.audiobooks:
        return 'Search audiobooks...';
    }
  }

  bool _shouldShowMiniPlayer() {
    // TODO: Check if there's active playback for the current screen type
    // For now, return false - will be implemented when connecting to providers
    return false;
  }

  Widget _buildMiniPlayerPill(BuildContext context) {
    // TODO: Return appropriate mini player widget based on screen type
    // For now, return a placeholder
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(36),
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
          Icon(
            widget.screenType == ScreenType.audiobooks ? Icons.headphones : Icons.music_note,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mini Player - Coming Soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // TODO: Stop playback
            },
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, PhotosState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheetScaffold(
        title: 'Location',
        onSearch: () {
          ref.read(photosNotifierProvider.notifier).updateLocationFilters(
            country: state.filters.country,
            stateParam: state.filters.state,
            city: state.filters.city,
          );
          Navigator.of(context).pop();
        },
        onClear: () {
          ref.read(photosNotifierProvider.notifier).updateLocationFilters(
            country: null,
            stateParam: null,
            city: null,
          );
          Navigator.of(context).pop();
        },
        child: LocationPicker(
          onSelected: (value) {
            // Update local state for preview
            ref.read(photosNotifierProvider.notifier).updateLocationFilters(
              country: value['country'],
              stateParam: value['state'],
              city: value['city'],
            );
          },
          initialFilter: {
            'country': state.filters.country,
            'state': state.filters.state,
            'city': state.filters.city,
          },
        ),
      ),
    );
  }

  void _showCameraPicker(BuildContext context, PhotosState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheetScaffold(
        title: 'Camera',
        onSearch: () {
          ref.read(photosNotifierProvider.notifier).updateCameraFilters(
            make: state.filters.cameraMake,
            model: state.filters.cameraModel,
          );
          Navigator.of(context).pop();
        },
        onClear: () {
          ref.read(photosNotifierProvider.notifier).updateCameraFilters(
            make: null,
            model: null,
          );
          Navigator.of(context).pop();
        },
        child: CameraPicker(
          onSelect: (value) {
            // Update local state for preview
            ref.read(photosNotifierProvider.notifier).updateCameraFilters(
              make: value['make'],
              model: value['model'],
            );
          },
          initialFilter: {
            'make': state.filters.cameraMake,
            'model': state.filters.cameraModel,
          },
        ),
      ),
    );
  }

  void _showMediaTypePicker(BuildContext context, PhotosState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheetScaffold(
        title: 'Media Type',
        onSearch: () {
          ref.read(photosNotifierProvider.notifier).updateFilters(
            state.filters.copyWith(mediaType: state.filters.mediaType),
          );
          Navigator.of(context).pop();
        },
        onClear: () {
          ref.read(photosNotifierProvider.notifier).updateFilters(
            state.filters.copyWith(mediaType: null),
          );
          Navigator.of(context).pop();
        },
        child: MediaTypePicker(
          onSelect: (value) {
            // Update local state for preview
            ref.read(photosNotifierProvider.notifier).updateFilters(
              state.filters.copyWith(mediaType: value),
            );
          },
          initialFilter: state.filters.mediaType,
        ),
      ),
    );
  }

  void _showDisplayOptionsPicker(BuildContext context, PhotosState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheetScaffold(
        title: 'Display Options',
        onSearch: () {
          ref.read(photosNotifierProvider.notifier).updateDisplayFilters(
            isNotInAlbum: state.filters.isNotInAlbum,
            isArchived: state.filters.isArchived,
            isFavorite: state.filters.isFavorite,
          );
          Navigator.of(context).pop();
        },
        onClear: () {
          ref.read(photosNotifierProvider.notifier).updateDisplayFilters(
            isNotInAlbum: null,
            isArchived: null,
            isFavorite: null,
          );
          Navigator.of(context).pop();
        },
        child: DisplayOptionsPicker(
          onSelect: (value) {
            // Update local state for preview
            ref.read(photosNotifierProvider.notifier).updateDisplayFilters(
              isNotInAlbum: value['isNotInAlbum'],
              isArchived: value['isArchived'],
              isFavorite: value['isFavorite'],
            );
          },
          initialFilter: {
            'isNotInAlbum': state.filters.isNotInAlbum ?? false,
            'isArchived': state.filters.isArchived ?? false,
            'isFavorite': state.filters.isFavorite ?? false,
          },
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context, PhotosState state) async {
    final initialDateRange = state.filters.dateFrom != null && state.filters.dateTo != null
        ? DateTimeRange(start: state.filters.dateFrom!, end: state.filters.dateTo!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (picked != null) {
      final newFilters = state.filters.copyWith(
        dateFrom: picked.start,
        dateTo: picked.end,
      );
      ref.read(photosNotifierProvider.notifier).updateFilters(newFilters);
    }
  }
}