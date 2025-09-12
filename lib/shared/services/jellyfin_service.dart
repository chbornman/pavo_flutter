import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/base_api_service.dart';

class JellyfinService extends BaseApiService {
  JellyfinService()
      : super(
          baseUrl: EnvConfig.jellyfinUrl,
          apiKey: EnvConfig.jellyfinApiKey,
        );

  Future<List<MediaItem>> getMovies() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'includeItemTypes': 'Movie',
        'recursive': true,
        'sortBy': 'DateCreated',
        'sortOrder': 'Descending',
      }),
    );
    
    final items = data['Items'] as List;
    return items.map((json) => MediaItem.fromJson(json)).toList();
  }

  Future<List<MediaItem>> getTVShows() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
        'includeItemTypes': 'Series',
        'recursive': true,
        'sortBy': 'DateCreated',
        'sortOrder': 'Descending',
      }),
    );
    
    final items = data['Items'] as List;
    return items.map((json) => MediaItem.fromJson(json)).toList();
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

  String getImageUrl(String itemId) {
    return '${EnvConfig.jellyfinUrl}/Items/$itemId/Images/Primary';
  }

  String getStreamUrl(String itemId) {
    return '${EnvConfig.jellyfinUrl}/Items/$itemId/Download?api_key=${EnvConfig.jellyfinApiKey}';
  }
}