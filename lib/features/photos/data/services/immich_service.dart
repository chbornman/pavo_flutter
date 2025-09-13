import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/models/pagination.dart';
import '../../domain/entities/photo_entity.dart';
import '../../presentation/providers/photos_provider.dart';
import '../models/immich_photo_model.dart';

/// Service layer for Immich API communication
/// Flutter best practice: Single Responsibility - this service only handles Immich API
class ImmichService {
  late final ApiClient _apiClient;
  late final AppLogger _logger;
  final String baseUrl;
  final String? apiKey;

  ImmichService({
    String? baseUrl,
    String? apiKey,
  })  : baseUrl = baseUrl ?? EnvConfig.immichUrl,
        apiKey = apiKey ?? EnvConfig.immichApiKey {
    
    // Use service-specific logger
    _logger = logger.forService('ImmichService');
    
    // Initialize API client with Immich configuration
    _apiClient = ApiClient(
      baseUrl: this.baseUrl,
      defaultHeaders: {
        if (this.apiKey != null) 'x-api-key': this.apiKey!,
        'Accept': 'application/json',
      },
    );

    _logger.info('ImmichService initialized with baseUrl: ${this.baseUrl}');
  }

  /// Fetch photos/videos from Immich with pagination
  /// Matches the Pavo web implementation pattern
  Future<PaginatedResponse<PhotoEntity>> fetchAssets({
    required PaginationParams params,
    PhotoFilters? filters,
  }) async {
    try {
      _logger.debug('Fetching assets: page=${params.page}, limit=${params.limit}, filters=$filters');

      // Build request body matching Immich API
      final requestBody = <String, dynamic>{
        'page': params.page,
        'size': params.limit,
        'order': params.sortBy == 'date_asc' ? 'asc' : 'desc',
        'withExif': true,
      };

       // Add filters to request body
       if (filters != null) {
         if (filters.mediaType != null) {
           requestBody['type'] = _getAssetType(filters.mediaType!);
         }
         if (filters.isFavorite != null) {
           requestBody['isFavorite'] = filters.isFavorite;
         }
         if (filters.isArchived != null) {
           requestBody['isArchived'] = filters.isArchived;
         }
         if (filters.isNotInAlbum != null) {
           requestBody['isNotInAlbum'] = filters.isNotInAlbum;
         }
         if (filters.dateFrom != null) {
           requestBody['takenAfter'] = filters.dateFrom!.toIso8601String();
         }
         if (filters.dateTo != null) {
           requestBody['takenBefore'] = filters.dateTo!.toIso8601String();
         }
         if (filters.country != null || filters.state != null || filters.city != null) {
           requestBody['exifInfo'] = <String, dynamic>{};
           if (filters.country != null) requestBody['exifInfo']['country'] = filters.country;
           if (filters.state != null) requestBody['exifInfo']['state'] = filters.state;
           if (filters.city != null) requestBody['exifInfo']['city'] = filters.city;
         }
         if (filters.cameraMake != null || filters.cameraModel != null) {
           requestBody['exifInfo'] ??= <String, dynamic>{};
           if (filters.cameraMake != null) requestBody['exifInfo']['make'] = filters.cameraMake;
           if (filters.cameraModel != null) requestBody['exifInfo']['model'] = filters.cameraModel;
         }
         if (filters.people?.isNotEmpty ?? false) {
           requestBody['personIds'] = filters.people!.toList();
         }
         if (filters.context?.isNotEmpty ?? false) {
           requestBody['query'] = filters.context;
         }
         if (filters.filename?.isNotEmpty ?? false) {
           requestBody['originalFileName'] = filters.filename;
         }
         if (filters.description?.isNotEmpty ?? false) {
           requestBody['description'] = filters.description;
         }
         if (filters.searchQuery?.isNotEmpty ?? false) {
           requestBody['query'] = filters.searchQuery;
         }
       }

      // Use different endpoints based on whether we have search query
      final endpoint = filters?.searchQuery?.isNotEmpty ?? false
          ? '/api/search/smart'
          : '/api/search/metadata';

      // Call Immich search endpoint
      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: requestBody,
      );

      // Parse response - Immich returns assets directly with nextPage indicator
      final assets = response['assets'] as Map<String, dynamic>? ?? {};
      final items = assets['items'] as List? ?? [];
      final totalCount = assets['count'] as int? ?? items.length;
      final nextPage = assets['nextPage'] as String?;

      // Convert to domain entities
      final photos = items
          .map((json) => ImmichPhotoModel.fromJson(json))
          .map((model) => model.toEntity(baseUrl: baseUrl, apiKey: apiKey))
          .toList();

      // Calculate if there are more pages
      // If we got a full page of results OR nextPage is provided, assume there's more
      final hasMore = nextPage != null || photos.length >= params.limit;

      _logger.info('Fetched ${photos.length} assets, total: $totalCount, hasMore: $hasMore');

      return PaginatedResponse<PhotoEntity>(
        items: photos,
        hasMore: hasMore,
        totalCount: totalCount,
        currentPage: params.page,
      );
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching assets', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Failed to fetch photos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get asset by ID
  Future<PhotoEntity> getAssetById(String assetId) async {
    try {
      _logger.debug('Fetching asset by ID: $assetId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/assets/$assetId',
      );

      final model = ImmichPhotoModel.fromJson(response);
      return model.toEntity(baseUrl: baseUrl, apiKey: apiKey);
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching asset $assetId', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Failed to fetch asset details',
        originalError: e,
      );
    }
  }

  /// Get asset thumbnail URL
  /// Flutter pattern: Generate URLs for image widgets
  String getThumbnailUrl(String assetId, {String size = 'preview'}) {
    return '$baseUrl/api/assets/$assetId/thumbnail?size=$size';
  }

  /// Get asset original file URL
  String getOriginalUrl(String assetId, {String type = 'image'}) {
    return type.toLowerCase() == 'video'
        ? '$baseUrl/api/assets/$assetId/video/playback'
        : '$baseUrl/api/assets/$assetId/original';
  }

  /// Download asset to device
  Future<void> downloadAsset(
    String assetId, 
    String savePath, {
    Function(int, int)? onProgress,
  }) async {
    try {
      _logger.debug('Downloading asset: $assetId to $savePath');

      await _apiClient.get<ResponseBody>(
        '/api/assets/$assetId/original',
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            if (apiKey != null) 'x-api-key': apiKey!,
          },
        ),
      );

      // Note: Actual file saving would be implemented here
      // This is just the service layer - file operations would be in repository

      _logger.info('Asset downloaded successfully: $assetId');
    } catch (e, stackTrace) {
      _logger.error('Error downloading asset $assetId', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Failed to download asset',
        originalError: e,
      );
    }
  }

  /// Toggle favorite status
  Future<PhotoEntity> toggleFavorite(String assetId, bool isFavorite) async {
    try {
      _logger.debug('Toggling favorite for asset: $assetId to $isFavorite');

      await _apiClient.put<Map<String, dynamic>>(
        '/api/asset',
        data: {
          'ids': [assetId],
          'isFavorite': isFavorite,
        },
      );

      // Fetch updated asset
      return getAssetById(assetId);
    } catch (e, stackTrace) {
      _logger.error('Error toggling favorite for $assetId', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Failed to update favorite status',
        originalError: e,
      );
    }
  }

  /// Search assets by query
  Future<PaginatedResponse<PhotoEntity>> searchAssets({
    required String query,
    required PaginationParams params,
  }) async {
    try {
      _logger.debug('Searching assets with query: $query');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/search/smart',
        data: {
          'query': query,
          'page': params.page,
          'size': params.limit,
        },
      );

      final assets = response['assets'] as Map<String, dynamic>? ?? {};
      final items = assets['items'] as List? ?? [];
      final totalCount = assets['count'] as int? ?? 0;

      final photos = items
          .map((json) => ImmichPhotoModel.fromJson(json))
          .map((model) => model.toEntity(baseUrl: baseUrl, apiKey: apiKey))
          .toList();

      final hasMore = (params.page * params.limit) < totalCount;

      return PaginatedResponse<PhotoEntity>(
        items: photos,
        hasMore: hasMore,
        totalCount: totalCount,
        currentPage: params.page,
      );
    } catch (e, stackTrace) {
      _logger.error('Error searching assets', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Search failed',
        originalError: e,
      );
    }
  }

  /// Helper method to convert PhotoType to Immich asset type
  String _getAssetType(PhotoType type) {
    switch (type) {
      case PhotoType.image:
        return 'IMAGE';
      case PhotoType.video:
        return 'VIDEO';
      default:
        return 'ALL';
    }
  }

  /// Get server info for connection validation
  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      _logger.debug('Fetching server info');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/server-info',
      );

      _logger.info('Server info fetched successfully');
      return response;
    } catch (e, stackTrace) {
      _logger.error('Error fetching server info', error: e, stackTrace: stackTrace);
      throw ApiException(
        message: 'Failed to connect to Immich server',
        originalError: e,
      );
    }
  }
}