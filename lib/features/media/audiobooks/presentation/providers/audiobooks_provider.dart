import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/logging/log_mixin.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../../domain/entities/playback_session_entity.dart';
import '../../data/services/audiobookshelf_service.dart';
import '../../data/repositories/audiobooks_repository.dart';

part 'audiobooks_provider.g.dart';

@riverpod
AudiobooksRepository audiobooksRepository(AudiobooksRepositoryRef ref) {
  return AudiobooksRepositoryImpl(AudiobookshelfService());
}

@Riverpod(keepAlive: true)
class AudiobooksList extends _$AudiobooksList with LogMixin {
  @override
  Future<List<AudiobookEntity>> build({
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  }) async {
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      return await repository.getAudiobooks(
        page: 1,
        limit: 50,
        filter: filter,
        sort: sort,
      );
    } catch (e) {
      log.error('Failed to load audiobooks', error: e);
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<List<AudiobookEntity>> loadMore({int page = 2}) async {
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      return await repository.getAudiobooks(
        page: page,
        limit: 50,
        filter: filter,
        sort: sort,
      );
    } catch (e) {
      log.error('Failed to load more audiobooks', error: e);
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
class InProgressAudiobooks extends _$InProgressAudiobooks with LogMixin {
  @override
  Future<List<AudiobookEntity>> build() async {
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      return await repository.getAudiobooks(
        page: 1,
        limit: 20,
        filter: AudiobookFilter.inProgress,
        sort: AudiobookSort.dateDesc,
      );
    } catch (e) {
      log.error('Failed to load in-progress audiobooks', error: e);
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class RecentSessions extends _$RecentSessions with LogMixin {
  @override
  Future<List<PlaybackSessionEntity>> build() async {
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      return await repository.getRecentSessions(limit: 10);
    } catch (e) {
      log.error('Failed to load recent sessions', error: e);
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class PlaybackSession extends _$PlaybackSession with LogMixin {
  @override
  Future<PlaybackSessionEntity?> build(String audiobookId) async {
    if (audiobookId.isEmpty) return null;
    
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      return await repository.createPlaybackSession(audiobookId);
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
    final repository = ref.read(audiobooksRepositoryProvider);
    
    try {
      await repository.updateProgress(
        sessionId: sessionId,
        currentTime: currentTime,
        progress: progress,
      );
    } catch (e) {
      log.error('Failed to update progress for session $sessionId', error: e);
      // Don't rethrow - progress updates should be non-blocking
    }
  }
}

@riverpod
String coverUrl(CoverUrlRef ref, String audiobookId, {int? width, int? height}) {
  final repository = ref.read(audiobooksRepositoryProvider);
  return repository.getCoverUrl(audiobookId, width: width, height: height);
}