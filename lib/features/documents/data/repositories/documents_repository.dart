import 'package:flutter/foundation.dart';
import '../../../../core/models/pagination.dart';
import '../../domain/entities/document.dart';
import '../services/paperless_service.dart';

class DocumentsRepository {
  final PaperlessService _paperlessService;
  
  DocumentsRepository(this._paperlessService);

  Future<({List<Document> documents, bool hasMore, int totalCount})> getDocuments({
    int page = 1,
    int limit = 50,
    String? sortBy,
    String? filter,
  }) async {
    try {
      final params = PaginationParams(
        page: page,
        limit: limit,
        sortBy: sortBy ?? 'date_desc',
        filter: filter,
      );

      final result = await _paperlessService.fetchDocuments(params: params);
      
      return (
        documents: result.documents,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
      );
    } catch (e) {
      debugPrint('Error fetching documents: $e');
      rethrow;
    }
  }

  String? getDocumentThumbnailUrl(int documentId) {
    return _paperlessService.getDocumentThumbnailUrl(documentId);
  }

  String? getDocumentPreviewUrl(int documentId) {
    return _paperlessService.getDocumentPreviewUrl(documentId);
  }

  String? getDocumentDownloadUrl(int documentId) {
    return _paperlessService.getDocumentDownloadUrl(documentId);
  }

  Map<String, String> get authHeaders => _paperlessService.authHeaders;
}