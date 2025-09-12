import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/shared/models/document.dart';
import 'package:pavo_flutter/shared/services/base_api_service.dart';

class PaperlessService extends BaseApiService {
  PaperlessService()
      : super(
          baseUrl: EnvConfig.paperlessUrl,
        ) {
    dio.options.headers['Authorization'] = 'Token ${EnvConfig.paperlessApiToken}';
  }

  Future<List<Document>> getDocuments({int page = 1, int limit = 50}) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/api/documents/', queryParameters: {
        'page': page,
        'page_size': limit,
        'ordering': '-created',
      }),
    );
    
    final results = data['results'] as List;
    return results.map((json) => Document.fromJson(json)).toList();
  }

  Future<Document> getDocument(int documentId) async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/api/documents/$documentId/'),
    );
    
    return Document.fromJson(data);
  }

  String getDocumentPreviewUrl(int documentId) {
    return '${EnvConfig.paperlessUrl}/api/documents/$documentId/preview/';
  }

  String getDocumentDownloadUrl(int documentId) {
    return '${EnvConfig.paperlessUrl}/api/documents/$documentId/download/';
  }

  Future<List<Map<String, dynamic>>> getTags() async {
    final data = await handleRequest<Map<String, dynamic>>(
      () => dio.get('/api/tags/'),
    );
    
    return List<Map<String, dynamic>>.from(data['results']);
  }
}