import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/services/paperless_service.dart';
import '../../domain/entities/document.dart';

part 'documents_provider.g.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: EnvConfig.paperlessUrl);
});

final paperlessServiceProvider = Provider<PaperlessService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaperlessService(apiClient);
});

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final paperlessService = ref.watch(paperlessServiceProvider);
  return DocumentsRepository(paperlessService);
});

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  static const _defaultLimit = 50;
  
  @override
  Future<List<Document>> build() async {
    return _fetchDocuments();
  }

  int _currentPage = 1;
  bool _hasMore = true;
  int _totalCount = 0;
  String _sortBy = 'date_desc';
  String? _filter;

  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  String get sortBy => _sortBy;
  String? get filter => _filter;

  Future<List<Document>> _fetchDocuments({bool append = false}) async {
    try {
      final repository = ref.read(documentsRepositoryProvider);
      
      final result = await repository.getDocuments(
        page: _currentPage,
        limit: _defaultLimit,
        sortBy: _sortBy,
        filter: _filter,
      );

      _hasMore = result.hasMore;
      _totalCount = result.totalCount;

      if (append) {
        final currentDocuments = state.valueOrNull ?? [];
        return [...currentDocuments, ...result.documents];
      }
      
      return result.documents;
    } catch (e) {
      throw Exception('Failed to load documents: $e');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    _currentPage++;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDocuments(append: true));
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDocuments());
  }

  Future<void> setSortBy(String sortBy) async {
    if (_sortBy == sortBy) return;
    _sortBy = sortBy;
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDocuments());
  }

  Future<void> setFilter(String? filter) async {
    if (_filter == filter) return;
    _filter = filter;
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDocuments());
  }

  String? getThumbnailUrl(int documentId) {
    final repository = ref.read(documentsRepositoryProvider);
    return repository.getDocumentThumbnailUrl(documentId);
  }

  String? getPreviewUrl(int documentId) {
    final repository = ref.read(documentsRepositoryProvider);
    return repository.getDocumentPreviewUrl(documentId);
  }

  String? getDownloadUrl(int documentId) {
    final repository = ref.read(documentsRepositoryProvider);
    return repository.getDocumentDownloadUrl(documentId);
  }

  Map<String, String> get authHeaders {
    final repository = ref.read(documentsRepositoryProvider);
    return repository.authHeaders;
  }
}