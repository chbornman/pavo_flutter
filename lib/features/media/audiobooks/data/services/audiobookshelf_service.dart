import 'package:dio/dio.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/config/env_config.dart';
import '../../../../../core/logging/log_mixin.dart';
import '../models/audiobook_model.dart';
import '../models/playback_session_model.dart';

enum AudiobookFilter { all, inProgress, finished, notStarted }

enum AudiobookSort { nameAsc, dateDesc, dateAsc }

class AudiobookshelfService with LogMixin {
  late final ApiClient _apiClient;
  String? _libraryId;

  AudiobookshelfService() {
    _apiClient = ApiClient(
      baseUrl: EnvConfig.audiobookshelfUrl,
      defaultHeaders: {
        'Authorization': 'Bearer ${EnvConfig.audiobookshelfApiKey}',
        'Content-Type': 'application/json',
      },
      appLogger: log,
    );
  }

  Future<List<AudiobookModel>> getAudiobooks({
    int page = 1,
    int limit = 20,
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  }) async {
    try {
      // Get library ID if not cached
      if (_libraryId == null) {
        await _discoverAudiobookLibrary();
      }

      if (_libraryId == null) {
        log.warning('No audiobook library found');
        return [];
      }

      final queryParams = <String, dynamic>{
        'page': page - 1, // Audiobookshelf uses 0-based pagination
        'limit': limit,
        'sort': _getSortParam(sort),
        'library': _libraryId,
      };

      // Add filter if not 'all'
      if (filter != AudiobookFilter.all) {
        queryParams['filter'] = _getFilterParam(filter);
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/libraries/$_libraryId/items',
        queryParameters: queryParams,
      );

      final results = response['results'] as List? ?? [];
      return results
          .map((json) => AudiobookModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log.error('Failed to fetch audiobooks', error: e);
      rethrow;
    }
  }

  Future<PlaybackSessionModel> createPlaybackSession(String audiobookId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/session/$audiobookId',
        data: {
          'supportedMimeTypes': [
            'audio/mpeg',
            'audio/mp4',
            'audio/flac',
            'audio/ogg',
            'audio/wav',
          ],
        },
      );

      return PlaybackSessionModel.fromJson(response);
    } catch (e) {
      log.error('Failed to create playback session for $audiobookId', error: e);
      rethrow;
    }
  }

  Future<void> updateProgress({
    required String sessionId,
    required int currentTime,
    required double progress,
  }) async {
    try {
      await _apiClient.post(
        '/api/session/$sessionId/sync',
        data: {
          'currentTime': currentTime,
          'timeListened': currentTime,
          'progress': progress,
        },
      );

      // Auto-mark as finished if progress >= 95%
      if (progress >= 0.95) {
        await _apiClient.post('/api/session/$sessionId/close', data: {
          'currentTime': currentTime,
          'timeListened': currentTime,
        });
      }
    } catch (e) {
      log.error('Failed to update progress for session $sessionId', error: e);
      // Don't rethrow - progress updates should be non-blocking
    }
  }

  Future<List<PlaybackSessionModel>> getRecentSessions({int limit = 10}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/me/listening-sessions',
        queryParameters: {'limit': limit},
      );

      final sessions = response['sessions'] as List? ?? [];
      return sessions
          .map((json) => PlaybackSessionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log.error('Failed to fetch recent sessions', error: e);
      rethrow;
    }
  }

  String getCoverUrl(String audiobookId, {int? width, int? height}) {
    final params = <String, String>{};
    if (width != null) params['width'] = width.toString();
    if (height != null) params['height'] = height.toString();
    
    final query = params.isNotEmpty ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
    return '${EnvConfig.audiobookshelfUrl}/api/items/$audiobookId/cover$query';
  }

  Future<void> _discoverAudiobookLibrary() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/api/libraries');
      final libraries = response['libraries'] as List? ?? [];
      
      for (final library in libraries) {
        final mediaType = library['mediaType']?.toString();
        if (mediaType == 'book') {
          _libraryId = library['id']?.toString();
          log.debug('Found audiobook library: $_libraryId');
          break;
        }
      }

      if (_libraryId == null) {
        log.warning('No audiobook library found in available libraries');
      }
    } catch (e) {
      log.error('Failed to discover audiobook library', error: e);
      rethrow;
    }
  }

  String _getSortParam(AudiobookSort sort) {
    switch (sort) {
      case AudiobookSort.nameAsc:
        return 'media.metadata.title';
      case AudiobookSort.dateDesc:
        return 'createdAt';
      case AudiobookSort.dateAsc:
        return 'createdAt';
    }
  }

  String _getFilterParam(AudiobookFilter filter) {
    switch (filter) {
      case AudiobookFilter.inProgress:
        return 'progress';
      case AudiobookFilter.finished:
        return 'finished';
      case AudiobookFilter.notStarted:
        return 'not-started';
      case AudiobookFilter.all:
        return '';
    }
  }
}