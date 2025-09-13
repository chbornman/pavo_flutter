import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/pagination.dart';
import '../../data/repositories/photos_repository.dart';
import '../../data/services/immich_service.dart';
import '../../domain/entities/photo_entity.dart';

part 'photos_provider.g.dart';

/// Provider for ImmichService
/// Flutter best practice: Use providers for dependency injection
final immichServiceProvider = Provider<ImmichService>((ref) {
  return ImmichService();
});

/// Provider for PhotosRepository
final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  final immichService = ref.watch(immichServiceProvider);
  return PhotosRepository(immichService: immichService);
});

/// Advanced filter options for photos
class PhotoFilters {
  final PhotoType? mediaType;
  final bool? isFavorite;
  final bool? isArchived;
  final bool? isNotInAlbum;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? country;
  final String? state;
  final String? city;
  final String? cameraMake;
  final String? cameraModel;
  final String? searchQuery;
  final String? context;
  final String? filename;
  final String? description;
  final Set<String>? people;

  const PhotoFilters({
    this.mediaType,
    this.isFavorite,
    this.isArchived,
    this.isNotInAlbum,
    this.dateFrom,
    this.dateTo,
    this.country,
    this.state,
    this.city,
    this.cameraMake,
    this.cameraModel,
    this.searchQuery,
    this.context,
    this.filename,
    this.description,
    this.people,
  });

  bool get hasActiveFilters =>
      mediaType != null ||
      isFavorite != null ||
      isArchived != null ||
      isNotInAlbum != null ||
      dateFrom != null ||
      dateTo != null ||
      country != null ||
      state != null ||
      city != null ||
      cameraMake != null ||
      cameraModel != null ||
      (searchQuery?.isNotEmpty ?? false) ||
      (context?.isNotEmpty ?? false) ||
      (filename?.isNotEmpty ?? false) ||
      (description?.isNotEmpty ?? false) ||
      (people?.isNotEmpty ?? false);

  PhotoFilters copyWith({
    PhotoType? mediaType,
    bool? isFavorite,
    bool? isArchived,
    bool? isNotInAlbum,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? country,
    String? state,
    String? city,
    String? cameraMake,
    String? cameraModel,
    String? searchQuery,
    String? context,
    String? filename,
    String? description,
    Set<String>? people,
  }) {
    return PhotoFilters(
      mediaType: mediaType ?? this.mediaType,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isNotInAlbum: isNotInAlbum ?? this.isNotInAlbum,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      cameraMake: cameraMake ?? this.cameraMake,
      cameraModel: cameraModel ?? this.cameraModel,
      searchQuery: searchQuery ?? this.searchQuery,
      context: context ?? this.context,
      filename: filename ?? this.filename,
      description: description ?? this.description,
      people: people ?? this.people,
    );
  }

  PhotoFilters clear() {
    return const PhotoFilters();
  }
}

/// State class for photos pagination
/// Follows Flutter immutability patterns
class PhotosState {
  final List<PhotoEntity> photos;
  final PaginationStatus status;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final PhotoFilters filters;
  final String? sortBy;

  const PhotosState({
    this.photos = const [],
    this.status = PaginationStatus.initial,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.filters = const PhotoFilters(),
    this.sortBy = 'date_desc',
  });

  bool get isLoading => status == PaginationStatus.loading;
  bool get isLoadingMore => status == PaginationStatus.loadingMore;
  bool get hasError => status == PaginationStatus.error;
  bool get isEmpty => status == PaginationStatus.empty && photos.isEmpty;

  PhotosState copyWith({
    List<PhotoEntity>? photos,
    PaginationStatus? status,
    bool? hasMore,
    int? currentPage,
    String? error,
    PhotoFilters? filters,
    String? sortBy,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Main photos notifier using Riverpod code generation
/// This follows Flutter's reactive state management patterns
@riverpod
class PhotosNotifier extends _$PhotosNotifier {
  late final PhotosRepository _repository;
  bool _hasInitialized = false;
  DateTime? _lastFilterChange;

  @override
  PhotosState build() {
    _repository = ref.watch(photosRepositoryProvider);
    
    // Initialize data load only once
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Use ref.onDispose to reset the flag if provider is recreated
      ref.onDispose(() => _hasInitialized = false);
      // Schedule initial load after build cycle completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if the notifier is still available before loading
        try {
          // Accessing state will throw if disposed
          state;
          loadPhotos();
        } catch (_) {
          // Notifier was disposed, skip loading
        }
      });
    }
    
    return const PhotosState();
  }

  /// Load photos (initial or refresh)
  Future<void> loadPhotos({bool forceRefresh = false}) async {
    try {
      // Safe to access state here as it will throw if disposed
      if (state.isLoading) return;
    } catch (_) {
      // Notifier was disposed
      return;
    }

    state = state.copyWith(
      status: PaginationStatus.loading,
      error: null,
    );

    try {
      final response = await _repository.getPhotos(
        params: PaginationParams(
          page: 1,
          limit: 30, // Reduced from 50 for better performance
          sortBy: state.sortBy,
        ),
        filters: state.filters,
        forceRefresh: forceRefresh,
      );

      // Check if notifier is still mounted
      try {
        // Accessing state will throw if disposed
        state;
      } catch (_) {
        return;
      }

      if (response.items.isEmpty) {
        state = state.copyWith(
          photos: [],
          status: PaginationStatus.empty,
          hasMore: false,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          photos: response.items,
          status: PaginationStatus.success,
          hasMore: response.hasMore,
          currentPage: 1,
        );
      }
    } catch (e) {
      // Check if notifier is still mounted
      try {
        state = state.copyWith(
          status: PaginationStatus.error,
          error: e.toString(),
        );
      } catch (_) {
        // Notifier was disposed
      }
    }
  }

  /// Load more photos (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    // Debounce to prevent multiple simultaneous requests
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Check again after delay
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(status: PaginationStatus.loadingMore);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getPhotos(
        params: PaginationParams(
          page: nextPage,
          limit: 30, // Reduced from 50 for better performance
          sortBy: state.sortBy,
        ),
        filters: state.filters,
      );

      // Check if notifier is still mounted
      try {
        state;
      } catch (_) {
        return;
      }

      // Prevent duplicates by using a Set
      final existingIds = state.photos.map((p) => p.id).toSet();
      final newPhotos = response.items
          .where((photo) => !existingIds.contains(photo.id))
          .toList();

      state = state.copyWith(
        photos: [...state.photos, ...newPhotos],
        status: PaginationStatus.success,
        hasMore: response.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      // Check if notifier is still mounted
      try {
        state = state.copyWith(
          status: PaginationStatus.error,
          error: e.toString(),
        );
      } catch (_) {
        // Notifier was disposed
      }
    }
  }

  /// Update filters
  Future<void> updateFilters(PhotoFilters newFilters) async {
    if (state.filters == newFilters) return;

    // Debounce filter changes to prevent rapid successive calls
    final now = DateTime.now();
    _lastFilterChange = now;

    // Wait a short time to see if another filter change comes in
    await Future.delayed(const Duration(milliseconds: 100));

    // If another filter change happened during the delay, abort this one
    if (_lastFilterChange != now) return;

    // Prevent simultaneous filter operations
    if (state.isLoading) return;

    state = state.copyWith(
      filters: newFilters,
      photos: [],
      currentPage: 1,
      hasMore: true,
      status: PaginationStatus.loading,
    );

    await loadPhotos();
  }

  /// Update location filters
  Future<void> updateLocationFilters({
    String? country,
    String? stateParam,
    String? city,
  }) async {
    final newFilters = state.filters.copyWith(
      country: country,
      state: stateParam,
      city: city,
    );
    await updateFilters(newFilters);
  }

  /// Update camera filters
  Future<void> updateCameraFilters({
    String? make,
    String? model,
  }) async {
    final newFilters = state.filters.copyWith(
      cameraMake: make,
      cameraModel: model,
    );
    await updateFilters(newFilters);
  }

  /// Update display option filters
  Future<void> updateDisplayFilters({
    bool? isNotInAlbum,
    bool? isArchived,
    bool? isFavorite,
  }) async {
    final newFilters = state.filters.copyWith(
      isNotInAlbum: isNotInAlbum,
      isArchived: isArchived,
      isFavorite: isFavorite,
    );
    await updateFilters(newFilters);
  }

  /// Update people filters
  Future<void> updatePeopleFilters(Set<String>? people) async {
    final newFilters = state.filters.copyWith(people: people);
    await updateFilters(newFilters);
  }

  /// Update search context filters
  Future<void> updateSearchFilters({
    String? context,
    String? filename,
    String? description,
  }) async {
    final newFilters = state.filters.copyWith(
      context: context,
      filename: filename,
      description: description,
    );
    await updateFilters(newFilters);
  }

  /// Set media type filter (legacy method for backward compatibility)
  Future<void> setFilter(PhotoType? filter) async {
    final newFilters = state.filters.copyWith(mediaType: filter);
    await updateFilters(newFilters);
  }

  /// Change sort order
  Future<void> setSortBy(String sortBy) async {
    if (state.sortBy == sortBy) return;

    state = state.copyWith(
      sortBy: sortBy,
      photos: [],
      currentPage: 1,
      hasMore: true,
    );

    await loadPhotos();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String photoId) async {
    final photo = state.photos.firstWhere(
      (p) => p.id == photoId,
      orElse: () => throw Exception('Photo not found'),
    );

    try {
      final updatedPhoto = await _repository.toggleFavorite(
        photoId,
        !photo.isFavorite,
      );

      // Update the photo in the list
      final updatedPhotos = state.photos.map((p) {
        if (p.id == photoId) {
          return updatedPhoto;
        }
        return p;
      }).toList();

      state = state.copyWith(photos: updatedPhotos);
    } catch (e) {
      // Handle error - maybe show a snackbar
      state = state.copyWith(
        error: 'Failed to update favorite status',
      );
    }
  }

  /// Refresh photos
  Future<void> refresh() async {
    await loadPhotos(forceRefresh: true);
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _repository.clearCache();
    await refresh();
  }
}

/// Search provider for photo search functionality
@riverpod
class PhotoSearchNotifier extends _$PhotoSearchNotifier {
  late final PhotosRepository _repository;

  @override
  PhotosState build() {
    _repository = ref.watch(photosRepositoryProvider);
    return const PhotosState();
  }

  /// Search photos
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const PhotosState();
      return;
    }

    state = state.copyWith(
      status: PaginationStatus.loading,
      error: null,
    );

    try {
      final response = await _repository.searchPhotos(
        query: query,
        params: const PaginationParams(page: 1, limit: 50),
      );

      if (response.items.isEmpty) {
        state = state.copyWith(
          photos: [],
          status: PaginationStatus.empty,
          hasMore: false,
        );
      } else {
        state = state.copyWith(
          photos: response.items,
          status: PaginationStatus.success,
          hasMore: response.hasMore,
          currentPage: 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Load more search results
  Future<void> loadMore(String query) async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(status: PaginationStatus.loadingMore);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.searchPhotos(
        query: query,
        params: PaginationParams(page: nextPage, limit: 50),
      );

      state = state.copyWith(
        photos: [...state.photos, ...response.items],
        status: PaginationStatus.success,
        hasMore: response.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Clear search
  void clearSearch() {
    state = const PhotosState();
  }
}

/// Provider for selected photo (for viewer)
final selectedPhotoProvider = StateProvider<PhotoEntity?>((ref) => null);

/// Provider for photo viewer visibility
final photoViewerVisibleProvider = StateProvider<bool>((ref) => false);