import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/shared/models/photo.dart';
import 'package:pavo_flutter/shared/models/video.dart';
import 'package:pavo_flutter/shared/services/base_api_service.dart';

class ImmichService extends BaseApiService {
  ImmichService()
      : super(
          baseUrl: EnvConfig.immichUrl,
          apiKey: EnvConfig.immichApiKey,
        );

  Future<List<Photo>> getPhotos({int page = 1, int limit = 50}) async {
    final data = await handleRequest<List<dynamic>>(
      () => dio.get('/api/assets', queryParameters: {
        'page': page,
        'size': limit,
        'type': 'IMAGE',
      }),
    );
    
    return data.map((json) => Photo.fromJson(json)).toList();
  }

  Future<List<Video>> getVideos({int page = 1, int limit = 50}) async {
    final data = await handleRequest<List<dynamic>>(
      () => dio.get('/api/assets', queryParameters: {
        'page': page,
        'size': limit,
        'type': 'VIDEO',
      }),
    );
    
    return data.map((json) => Video.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getAlbums() async {
    return await handleRequest<List<Map<String, dynamic>>>(
      () => dio.get('/api/albums'),
    );
  }

  String getThumbnailUrl(String assetId) {
    return '${EnvConfig.immichUrl}/api/assets/$assetId/thumbnail';
  }

  String getPhotoUrl(String assetId) {
    return '${EnvConfig.immichUrl}/api/assets/$assetId/original';
  }
}