import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/logging/log_mixin.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../../domain/entities/playback_session_entity.dart';
import '../../domain/entities/chapter_entity.dart';
import 'audiobooks_provider.dart';

part 'audiobook_player_provider.g.dart';

enum AudiobookPlayerState {
  idle,
  loading,
  ready,
  playing,
  paused,
  error,
}

class AudiobookPlaybackState {
  final AudiobookPlayerState playerState;
  final AudiobookEntity? currentAudiobook;
  final PlaybackSessionEntity? currentSession;
  final ChapterEntity? currentChapter;
  final Duration currentPosition;
  final Duration totalDuration;
  final double playbackSpeed;
  final bool isLoading;
  final String? errorMessage;

  const AudiobookPlaybackState({
    this.playerState = AudiobookPlayerState.idle,
    this.currentAudiobook,
    this.currentSession,
    this.currentChapter,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.isLoading = false,
    this.errorMessage,
  });

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  bool get isPlaying => playerState == AudiobookPlayerState.playing;
  bool get canPlay => playerState == AudiobookPlayerState.ready || 
                     playerState == AudiobookPlayerState.paused;

  AudiobookPlaybackState copyWith({
    AudiobookPlayerState? playerState,
    AudiobookEntity? currentAudiobook,
    PlaybackSessionEntity? currentSession,
    ChapterEntity? currentChapter,
    Duration? currentPosition,
    Duration? totalDuration,
    double? playbackSpeed,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AudiobookPlaybackState(
      playerState: playerState ?? this.playerState,
      currentAudiobook: currentAudiobook ?? this.currentAudiobook,
      currentSession: currentSession ?? this.currentSession,
      currentChapter: currentChapter ?? this.currentChapter,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class AudiobookPlayer extends _$AudiobookPlayer with LogMixin {
  late final AudioPlayer _audioPlayer;
  Timer? _progressTimer;
  PlaybackSessionEntity? _currentSession;

  @override
  AudiobookPlaybackState build() {
    _initializeAudioPlayer();
    ref.onDispose(() {
      _progressTimer?.cancel();
      _audioPlayer.dispose();
    });
    
    return const AudiobookPlaybackState();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final newState = switch (playerState.processingState) {
        ProcessingState.idle => AudiobookPlayerState.idle,
        ProcessingState.loading => AudiobookPlayerState.loading,
        ProcessingState.buffering => AudiobookPlayerState.loading,
        ProcessingState.ready => playerState.playing 
            ? AudiobookPlayerState.playing 
            : AudiobookPlayerState.ready,
        ProcessingState.completed => AudiobookPlayerState.paused,
      };

      state = state.copyWith(
        playerState: newState,
        isLoading: playerState.processingState == ProcessingState.loading ||
                  playerState.processingState == ProcessingState.buffering,
      );

      // Start/stop progress tracking
      if (newState == AudiobookPlayerState.playing) {
        _startProgressTracking();
      } else {
        _stopProgressTracking();
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      final currentChapter = _getCurrentChapter(position);
      state = state.copyWith(
        currentPosition: position,
        currentChapter: currentChapter,
      );
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(totalDuration: duration);
      }
    });

    // Configure audio session
    _configureAudioSession();
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      log.error('Failed to configure audio session', error: e);
    }
  }

  Future<void> playAudiobook(AudiobookEntity audiobook) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Create playback session
      final session = await ref.read(playbackSessionProvider(audiobook.id).future);
      
      if (session == null) {
        throw Exception('Failed to create playback session');
      }

      _currentSession = session;

      // Set up background playback metadata
      final mediaItem = MediaItem(
        id: audiobook.id,
        title: audiobook.title,
        artist: audiobook.author,
        artUri: audiobook.coverUrl != null ? Uri.parse(audiobook.coverUrl!) : null,
        duration: Duration(milliseconds: audiobook.duration),
      );

      // Load audio source
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(session.audioUrl),
          tag: mediaItem,
        ),
      );

      // Restore progress
      if (session.currentTime > 0) {
        await _audioPlayer.seek(Duration(milliseconds: session.currentTime));
      }

      state = state.copyWith(
        currentAudiobook: audiobook,
        currentSession: session,
        playerState: AudiobookPlayerState.ready,
        isLoading: false,
      );

      log.info('Audiobook loaded: ${audiobook.title}');
    } catch (e) {
      log.error('Failed to play audiobook: ${audiobook.title}', error: e);
      state = state.copyWith(
        playerState: AudiobookPlayerState.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      log.error('Failed to play audio', error: e);
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      log.error('Failed to pause audio', error: e);
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _stopProgressTracking();
      _currentSession = null;
      state = const AudiobookPlaybackState();
    } catch (e) {
      log.error('Failed to stop audio', error: e);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      log.error('Failed to seek to position', error: e);
    }
  }

  Future<void> skipForward([int seconds = 30]) async {
    final newPosition = state.currentPosition + Duration(seconds: seconds);
    final maxPosition = state.totalDuration;
    
    await seek(newPosition > maxPosition ? maxPosition : newPosition);
  }

  Future<void> skipBackward([int seconds = 30]) async {
    final newPosition = state.currentPosition - Duration(seconds: seconds);
    
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      state = state.copyWith(playbackSpeed: speed);
    } catch (e) {
      log.error('Failed to set playback speed', error: e);
    }
  }

  Future<void> playChapter(ChapterEntity chapter) async {
    await seek(Duration(milliseconds: chapter.start));
    await play();
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateProgress();
    });
  }

  void _stopProgressTracking() {
    _progressTimer?.cancel();
  }

  void _updateProgress() {
    final session = _currentSession;
    if (session == null) return;

    final currentTimeMs = state.currentPosition.inMilliseconds;
    final totalTimeMs = state.totalDuration.inMilliseconds;
    
    if (totalTimeMs > 0) {
      final progress = (currentTimeMs / totalTimeMs).clamp(0.0, 1.0);
      
      // Update progress on server (non-blocking)
      final sessionProvider = ref.read(playbackSessionProvider(session.audiobookId).notifier);
      sessionProvider.updateProgress(
        sessionId: session.id,
        currentTime: currentTimeMs,
        progress: progress,
      );
    }
  }

  ChapterEntity? _getCurrentChapter(Duration position) {
    final audiobook = state.currentAudiobook;
    if (audiobook == null || audiobook.chapters.isEmpty) return null;

    final positionMs = position.inMilliseconds;
    for (final chapter in audiobook.chapters) {
      if (positionMs >= chapter.start && positionMs <= chapter.end) {
        return chapter;
      }
    }
    return null;
  }
}