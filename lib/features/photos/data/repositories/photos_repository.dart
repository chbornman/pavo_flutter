import '../../../../core/api/api_exceptions.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/pagination.dart';
import '../../domain/entities/photo_entity.dart';
import '../services/immich_service.dart';

/// Repository pattern implementation for photos
/// Flutter best practice: Repository acts as single source of truth
/// Handles caching, error recovery, and data aggregation
class PhotosRepository {
  final ImmichService _immichService;
  final CacheManager _cacheManager;
  late final AppLogger _logger;

  // Cache keys
  static const String _cacheKeyPrefix = 'photos_';
  static const Duration _cacheTTL = Duration(minutes: 5);

  PhotosRepository({
    ImmichService? immichService,
    CacheManager? cacheManager,
  })  : _immichService = immichService ?? ImmichService(),
        _cacheManager = cacheManager ?? CacheManager() {
    _logger = logger.forService('PhotosRepository');
  }

  /// Get photos with caching and pagination
  /// Implements the same caching strategy as Pavo web
  Future<PaginatedResponse<PhotoEntity>> getPhotos({
    required PaginationParams params,
    PhotoType? type,
    bool forceRefresh = false,
  }) async {
    // Generate cache key based on parameters
    final cacheKey = _generateCacheKey(params, type);
    
    // Check cache first unless force refresh
    if (!forceRefresh) {
      final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.debug('Returning cached photos for key: $cacheKey');
        return _parseCachedResponse(cachedData);
      }
    }

    try {
      // Fetch from service
      _logger.debug('Fetching photos from service');
      final response = await _immichService.fetchAssets(
        params: params,
        type: type,
      );

      // Cache the successful response
      await _cacheResponse(cacheKey, response);
      
      // Prefetch next page in background (like Pavo web)
      if (response.hasMore) {
        _prefetchNextPage(params, type);
      }

      return response;
    } on ApiException catch (e) {
      _logger.error('API error fetching photos', error: e);
      
      // Try to return cached data on error
      final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.warning('Returning stale cache due to API error');
        return _parseCachedResponse(cachedData);
      }
      
      // If no cache, propagate the error
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected error fetching photos', 
        error: e, 
        stackTrace: stackTrace
      );
      throw ApiException(
        message: 'Failed to load photos',
        originalError: e,
      );
    }
  }

  /// Search photos with smart query
  Future<PaginatedResponse<PhotoEntity>> searchPhotos({
    required String query,
    required PaginationParams params,
  }) async {
    if (query.trim().isEmpty) {
      return PaginatedResponse.empty();
    }

    final cacheKey = '${_cacheKeyPrefix}search_${query}_${params.page}';
    
    // Check cache
    final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      return _parseCachedResponse(cachedData);
    }

    try {
      final response = await _immichService.searchAssets(
        query: query,
        params: params,
      );

      // Cache search results with shorter TTL
      await _cacheManager.set(
        key: cacheKey,
        data: _responseToCache(response),
        ttl: const Duration(minutes: 2),
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error('Error searching photos', 
        error: e, 
        stackTrace: stackTrace
      );
      throw ApiException(
        message: 'Search failed',
        originalError: e,
      );
    }
  }

  /// Get single photo by ID
  Future<PhotoEntity> getPhotoById(String id) async {
    final cacheKey = '${_cacheKeyPrefix}single_$id';
    
    // Check cache
    final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      return PhotoEntity(
        id: cachedData['id'],
        thumbnailUrl: cachedData['thumbnailUrl'],
        originalUrl: cachedData['originalUrl'],
        fileName: cachedData['fileName'],
        createdAt: cachedData['createdAt'] != null 
          ? DateTime.parse(cachedData['createdAt']) 
          : null,
        type: PhotoTypeExtension.fromString(cachedData['type']),
        isFavorite: cachedData['isFavorite'] ?? false,
      );
    }

    try {
      final photo = await _immichService.getAssetById(id);
      
      // Cache single photo
      await _cacheManager.set(
        key: cacheKey,
        data: {
          'id': photo.id,
          'thumbnailUrl': photo.thumbnailUrl,
          'originalUrl': photo.originalUrl,
          'fileName': photo.fileName,
          'createdAt': photo.createdAt?.toIso8601String(),
          'type': photo.type.toString(),
          'isFavorite': photo.isFavorite,
        },
        ttl: _cacheTTL,
      );

      return photo;
    } catch (e, stackTrace) {
      _logger.error('Error fetching photo by ID', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  /// Toggle favorite status
  Future<PhotoEntity> toggleFavorite(String photoId, bool isFavorite) async {
    try {
      final updatedPhoto = await _immichService.toggleFavorite(
        photoId, 
        isFavorite
      );
      
      // Invalidate caches
      await _invalidatePhotoCache(photoId);
      
      return updatedPhoto;
    } catch (e, stackTrace) {
      _logger.error('Error toggling favorite', 
        error: e, 
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  /// Clear all photo caches
  Future<void> clearCache() async {
    _logger.debug('Clearing all photo caches');
    // In a real app, we'd clear only photo-related caches
    await _cacheManager.clear();
  }

  /// Prefetch next page in background (like Pavo web)
  void _prefetchNextPage(PaginationParams params, PhotoType? type) {
    final nextParams = params.copyWith(page: params.page + 1);
    final cacheKey = _generateCacheKey(nextParams, type);
    
    // Check if already cached
    if (_cacheManager.contains(cacheKey)) {
      return;
    }

    // Prefetch in background without awaiting
    _immichService.fetchAssets(
      params: nextParams,
      type: type,
    ).then((response) {
      _cacheResponse(cacheKey, response);
      _logger.debug('Prefetched page ${nextParams.page}');
    }).catchError((e) {
      _logger.warning('Failed to prefetch page ${nextParams.page}');
    });
  }

  /// Generate cache key from parameters
  String _generateCacheKey(PaginationParams params, PhotoType? type) {
    final typeStr = type?.toString() ?? 'all';
    return '${_cacheKeyPrefix}${typeStr}_p${params.page}_l${params.limit}_${params.sortBy ?? 'default'}_${params.filter ?? ''}';
  }

  /// Cache a response
  Future<void> _cacheResponse(
    String key, 
    PaginatedResponse<PhotoEntity> response,
  ) async {
    await _cacheManager.set(
      key: key,
      data: _responseToCache(response),
      ttl: _cacheTTL,
    );
  }

  /// Convert response to cacheable format
  Map<String, dynamic> _responseToCache(PaginatedResponse<PhotoEntity> response) {
    return {
      'items': response.items.map((photo) => {
        'id': photo.id,
        'thumbnailUrl': photo.thumbnailUrl,
        'originalUrl': photo.originalUrl,
        'fileName': photo.fileName,
        'createdAt': photo.createdAt?.toIso8601String(),
        'modifiedAt': photo.modifiedAt?.toIso8601String(),
        'width': photo.width,
        'height': photo.height,
        'fileSize': photo.fileSize,
        'mimeType': photo.mimeType,
        'type': photo.type.toString(),
        'isFavorite': photo.isFavorite,
        'checksum': photo.checksum,
        'duration': photo.duration?.inSeconds,
      }).toList(),
      'hasMore': response.hasMore,
      'totalCount': response.totalCount,
      'currentPage': response.currentPage,
    };
  }

  /// Parse cached response
  PaginatedResponse<PhotoEntity> _parseCachedResponse(Map<String, dynamic> data) {
    final items = (data['items'] as List).map((item) {
      return PhotoEntity(
        id: item['id'],
        thumbnailUrl: item['thumbnailUrl'],
        originalUrl: item['originalUrl'],
        fileName: item['fileName'],
        createdAt: item['createdAt'] != null 
          ? DateTime.parse(item['createdAt']) 
          : null,
        modifiedAt: item['modifiedAt'] != null 
          ? DateTime.parse(item['modifiedAt']) 
          : null,
        width: item['width'],
        height: item['height'],
        fileSize: item['fileSize'],
        mimeType: item['mimeType'],
        type: PhotoTypeExtension.fromString(item['type']),
        isFavorite: item['isFavorite'] ?? false,
        checksum: item['checksum'],
        duration: item['duration'] != null 
          ? Duration(seconds: item['duration']) 
          : null,
      );
    }).toList();

    return PaginatedResponse(
      items: items,
      hasMore: data['hasMore'] ?? false,
      totalCount: data['totalCount'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
    );
  }

  /// Invalidate cache for a specific photo
  Future<void> _invalidatePhotoCache(String photoId) async {
    final cacheKey = '${_cacheKeyPrefix}single_$photoId';
    await _cacheManager.remove(cacheKey);
    // Also clear list caches since the photo might be in them
    // In production, we'd be more selective about this
  }
}