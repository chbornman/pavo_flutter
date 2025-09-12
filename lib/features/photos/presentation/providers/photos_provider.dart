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

/// State class for photos pagination
/// Follows Flutter immutability patterns
class PhotosState {
  final List<PhotoEntity> photos;
  final PaginationStatus status;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final PhotoType? activeFilter;
  final String? sortBy;

  const PhotosState({
    this.photos = const [],
    this.status = PaginationStatus.initial,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.activeFilter,
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
    PhotoType? activeFilter,
    String? sortBy,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      activeFilter: activeFilter ?? this.activeFilter,
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
        type: state.activeFilter,
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
        type: state.activeFilter,
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

  /// Filter photos by type
  Future<void> setFilter(PhotoType? filter) async {
    if (state.activeFilter == filter) return;

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
      activeFilter: filter,
      photos: [],
      currentPage: 1,
      hasMore: true,
      status: PaginationStatus.loading,
    );

    await loadPhotos();
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