import '../../domain/entities/audiobook_entity.dart';
import '../../domain/entities/playback_session_entity.dart';
import '../services/audiobookshelf_service.dart';

abstract class AudiobooksRepository {
  Future<List<AudiobookEntity>> getAudiobooks({
    int page = 1,
    int limit = 20,
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  });

  Future<PlaybackSessionEntity> createPlaybackSession(String audiobookId);
  
  Future<void> updateProgress({
    required String sessionId,
    required int currentTime,
    required double progress,
  });

  Future<List<PlaybackSessionEntity>> getRecentSessions({int limit = 10});
  
  String getCoverUrl(String audiobookId, {int? width, int? height});
}

class AudiobooksRepositoryImpl implements AudiobooksRepository {
  final AudiobookshelfService _service;

  AudiobooksRepositoryImpl(this._service);

  @override
  Future<List<AudiobookEntity>> getAudiobooks({
    int page = 1,
    int limit = 20,
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  }) async {
    final audiobooks = await _service.getAudiobooks(
      page: page,
      limit: limit,
      filter: filter,
      sort: sort,
    );
    return audiobooks.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PlaybackSessionEntity> createPlaybackSession(String audiobookId) async {
    final session = await _service.createPlaybackSession(audiobookId);
    return session.toEntity();
  }

  @override
  Future<void> updateProgress({
    required String sessionId,
    required int currentTime,
    required double progress,
  }) async {
    return _service.updateProgress(
      sessionId: sessionId,
      currentTime: currentTime,
      progress: progress,
    );
  }

  @override
  Future<List<PlaybackSessionEntity>> getRecentSessions({int limit = 10}) async {
    final sessions = await _service.getRecentSessions(limit: limit);
    return sessions.map((model) => model.toEntity()).toList();
  }

  @override
  String getCoverUrl(String audiobookId, {int? width, int? height}) {
    return _service.getCoverUrl(audiobookId, width: width, height: height);
  }
}