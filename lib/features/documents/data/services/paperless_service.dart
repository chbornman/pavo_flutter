import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/models/pagination.dart';
import '../models/document_model.dart';

class PaperlessService {
  final ApiClient _apiClient;
  final String? _baseUrl = EnvConfig.paperlessUrl;
  final String? _apiToken = EnvConfig.paperlessApiToken;

  PaperlessService(this._apiClient);

  Future<({List<DocumentModel> documents, bool hasMore, int totalCount})> fetchDocuments({
    required PaginationParams params,
  }) async {
    if (_baseUrl == null || _apiToken == null) {
      debugPrint('Paperless not configured - missing URL or API token');
      return (documents: <DocumentModel>[], hasMore: false, totalCount: 0);
    }

    try {
      final queryParams = <String, dynamic>{
        'page': params.page,
        'page_size': params.limit,
      };

      // Handle sorting
      switch (params.sortBy) {
        case 'date_desc':
          queryParams['ordering'] = '-created';
          break;
        case 'date_asc':
          queryParams['ordering'] = 'created';
          break;
        case 'name_asc':
          queryParams['ordering'] = 'title';
          break;
      }

      // Handle filtering
      if (params.filter == 'year') {
        final currentYear = DateTime.now().year;
        queryParams['created__year'] = currentYear.toString();
      } else if (params.filter == 'month') {
        final now = DateTime.now();
        queryParams['created__year'] = now.year.toString();
        queryParams['created__month'] = now.month.toString();
      }

      final data = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/api/documents/',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Token $_apiToken',
            'Accept': 'application/json; version=9',
          },
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final results = (data['results'] as List<dynamic>?) ?? [];
      final documents = results
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalCount = data['count'] as int? ?? documents.length;
      final hasMore = data['next'] != null;

      debugPrint('Successfully fetched ${documents.length} documents');

      return (
        documents: documents,
        hasMore: hasMore,
        totalCount: totalCount,
      );
    } catch (e) {
      debugPrint('Failed to fetch documents: $e');
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 401:
            throw Exception('Invalid Paperless API token');
          case 403:
            throw Exception('Access denied to Paperless API');
          case 502:
            throw Exception('Paperless server is temporarily unavailable');
          default:
            throw Exception('Failed to fetch documents: ${e.message}');
        }
      }
      throw Exception('Failed to fetch documents: $e');
    }
  }

  String? getDocumentThumbnailUrl(int documentId) {
    if (_baseUrl == null || _apiToken == null) return null;
    return '$_baseUrl/api/documents/$documentId/thumb/';
  }

  String? getDocumentPreviewUrl(int documentId) {
    if (_baseUrl == null || _apiToken == null) return null;
    return '$_baseUrl/api/documents/$documentId/preview/';
  }

  String? getDocumentDownloadUrl(int documentId) {
    if (_baseUrl == null || _apiToken == null) return null;
    return '$_baseUrl/api/documents/$documentId/download/';
  }

  Map<String, String> get authHeaders => {
    if (_apiToken != null) 'Authorization': 'Token $_apiToken',
  };
}