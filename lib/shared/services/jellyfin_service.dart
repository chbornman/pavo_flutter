import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/core/cache/cache_manager.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/base_api_service.dart';

class JellyfinService extends BaseApiService {
  final CacheManager _cacheManager = CacheManager();
  
  JellyfinService()
      : super(
          baseUrl: EnvConfig.jellyfinUrl,
          apiKey: null, // Don't use default X-API-Key header
        ) {
    // Override default headers for Jellyfin's MediaBrowser authentication
    if (EnvConfig.jellyfinApiKey != null) {
      dio.options.headers['Authorization'] = 'MediaBrowser Token=${EnvConfig.jellyfinApiKey}';
    }
  }

  Future<List<MediaItem>> getMovies() async {
    const cacheKey = 'jellyfin_movies';
    
    // Try cache first - 30 minute TTL for movies list
    final cachedMovies = _cacheManager.get<List<dynamic>>(cacheKey);
    if (cachedMovies != null) {
      log.info('Loading movies from cache');
      return cachedMovies.map((json) => MediaItem.fromJson(json)).toList();
    }
    
    try {
      // Fetch fresh data from API
      log.info('Fetching fresh movies from API');
      final data = await handleRequest<Map<String, dynamic>>(
        () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
          'includeItemTypes': 'Movie',
          'recursive': true,
          'sortBy': 'DateCreated',
          'sortOrder': 'Descending',
        }),
      );
      
      final items = data['Items'] as List;
      
      // Cache the raw JSON for 30 minutes
      await _cacheManager.set(
        key: cacheKey,
        data: items,
        ttl: const Duration(minutes: 30),
        persist: true,
      );
      
      // Also create a long-term backup cache for offline support
      await _cacheManager.set(
        key: '${cacheKey}_backup',
        data: items,
        ttl: const Duration(days: 7), // Keep backup for a week
        persist: true,
      );
      
      return items.map((json) => MediaItem.fromJson(json)).toList();
    } catch (e) {
      // If API fails, try to return stale cached data
      final staleCache = _cacheManager.get<List<dynamic>>('${cacheKey}_backup');
      if (staleCache != null) {
        log.info('API failed, returning stale cached movies');
        return staleCache.map((json) => MediaItem.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<List<MediaItem>> getTVShows() async {
    const cacheKey = 'jellyfin_tvshows';
    
    // Try cache first - 30 minute TTL for TV shows list
    final cachedShows = _cacheManager.get<List<dynamic>>(cacheKey);
    if (cachedShows != null) {
      log.info('Loading TV shows from cache');
      return cachedShows.map((json) => MediaItem.fromJson(json)).toList();
    }
    
    try {
      // Fetch fresh data from API
      log.info('Fetching fresh TV shows from API');
      final data = await handleRequest<Map<String, dynamic>>(
        () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
          'includeItemTypes': 'Series',
          'recursive': true,
          'sortBy': 'DateCreated',
          'sortOrder': 'Descending',
        }),
      );
      
      final items = data['Items'] as List;
      
      // Cache the raw JSON for 30 minutes
      await _cacheManager.set(
        key: cacheKey,
        data: items,
        ttl: const Duration(minutes: 30),
        persist: true,
      );
      
      // Also create a long-term backup cache for offline support
      await _cacheManager.set(
        key: '${cacheKey}_backup',
        data: items,
        ttl: const Duration(days: 7),
        persist: true,
      );
      
      return items.map((json) => MediaItem.fromJson(json)).toList();
    } catch (e) {
      // If API fails, try to return stale cached data
      final staleCache = _cacheManager.get<List<dynamic>>('${cacheKey}_backup');
      if (staleCache != null) {
        log.info('API failed, returning stale cached TV shows');
        return staleCache.map((json) => MediaItem.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<List<MediaItem>> getMusic() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'includeItemTypes': 'Audio',
        'recursive': true,
        'sortBy': 'DateCreated',
        'sortOrder': 'Descending',
      }),
    );
    
    final items = data['Items'] as List;
    return items.map((json) => MediaItem.fromJson(json)).toList();
  }

  Future<List<MediaItem>> getAudiobooks() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'includeItemTypes': 'AudioBook',
        'recursive': true,
        'sortBy': 'DateCreated',
        'sortOrder': 'Descending',
      }),
    );
    
    final items = data['Items'] as List;
    return items.map((json) => MediaItem.fromJson(json)).toList();
  }

  Future<MediaItem> getMovieById(String movieId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items/$movieId'),
    );
    
    return MediaItem.fromJson(data);
  }

  Future<MediaItem> getTVShowById(String showId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items/$showId'),
    );
    
    return MediaItem.fromJson(data);
  }

  Future<List<dynamic>> getTVShowSeasons(String showId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Shows/$showId/Seasons', queryParameters: {
        'userId': EnvConfig.jellyfinUserId,
      }),
    );
    
    return data['Items'] as List;
  }

  Future<List<dynamic>> getSeasonEpisodes(String showId, String seasonId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Shows/$showId/Episodes', queryParameters: {
        'userId': EnvConfig.jellyfinUserId,
        'seasonId': seasonId,
      }),
    );
    
    return data['Items'] as List;
  }

  String getImageUrl(String itemId) {
    return '${EnvConfig.jellyfinUrl}/Items/$itemId/Images/Primary';
  }

  String getStreamUrl(String itemId) {
    // Use Jellyfin's streaming endpoint instead of download for better playback
    return '${EnvConfig.jellyfinUrl}/Videos/$itemId/stream?api_key=${EnvConfig.jellyfinApiKey}&Static=true';
  }

  String getHLSStreamUrl(String itemId) {
    // HLS streaming for better compatibility and adaptive bitrate
    return '${EnvConfig.jellyfinUrl}/Videos/$itemId/master.m3u8?api_key=${EnvConfig.jellyfinApiKey}';
  }

  // Music-specific methods
  Future<List<dynamic>> getMusicArtists() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Artists/AlbumArtists', queryParameters: {
        'userId': EnvConfig.jellyfinUserId,
        'recursive': true,
        'sortBy': 'Name',
        'sortOrder': 'Ascending',
      }),
    );
    
    return data['Items'] as List;
  }

  Future<List<dynamic>> getArtistAlbums(String artistId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'includeItemTypes': 'MusicAlbum',
        'recursive': true,
        'albumArtistIds': artistId,
        'sortBy': 'ProductionYear,SortName',
        'sortOrder': 'Descending',
      }),
    );
    
    return data['Items'] as List;
  }

  Future<List<dynamic>> getAlbumTracks(String albumId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'parentId': albumId,
        'includeItemTypes': 'Audio',
        'sortBy': 'IndexNumber,SortName',
        'sortOrder': 'Ascending',
      }),
    );
    
    return data['Items'] as List;
  }

  Future<Map<String, dynamic>> getAlbumDetails(String albumId) async {
    return await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items/$albumId'),
    );
  }

  String getAudioStreamUrl(String itemId) {
    // Direct audio streaming URL with transcoding parameters
    return '${EnvConfig.jellyfinUrl}/Audio/$itemId/stream?api_key=${EnvConfig.jellyfinApiKey}'
        '&container=mp3&audioCodec=mp3&audioBitRate=320000&maxStreamingBitrate=140000000';
  }
}