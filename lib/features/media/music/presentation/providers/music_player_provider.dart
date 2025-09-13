import 'dart:async';
import 'dart:math' as math hide log;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/logging/log_mixin.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/album.dart';

part 'music_player_provider.g.dart';

enum MusicPlayerState {
  idle,
  loading,
  ready,
  playing,
  paused,
  error,
}

enum RepeatMode {
  none,
  all,
  one,
}

class MusicPlaybackState {
  final MusicPlayerState playerState;
  final List<Track> queue;
  final int currentIndex;
  final Track? currentTrack;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool shuffle;
  final RepeatMode repeatMode;
  final double volume;
  final bool isLoading;
  final String? errorMessage;
  final List<Track> originalQueue; // For shuffle mode

  const MusicPlaybackState({
    this.playerState = MusicPlayerState.idle,
    this.queue = const [],
    this.currentIndex = -1,
    this.currentTrack,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.shuffle = false,
    this.repeatMode = RepeatMode.none,
    this.volume = 0.7,
    this.isLoading = false,
    this.errorMessage,
    this.originalQueue = const [],
  });

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  bool get isPlaying => playerState == MusicPlayerState.playing;
  bool get canPlay => playerState == MusicPlayerState.ready || 
                     playerState == MusicPlayerState.paused;
  bool get hasNext => currentIndex < queue.length - 1 || repeatMode == RepeatMode.all;
  bool get hasPrevious => currentIndex > 0 || repeatMode == RepeatMode.all;

  MusicPlaybackState copyWith({
    MusicPlayerState? playerState,
    List<Track>? queue,
    int? currentIndex,
    Track? currentTrack,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? shuffle,
    RepeatMode? repeatMode,
    double? volume,
    bool? isLoading,
    String? errorMessage,
    List<Track>? originalQueue,
  }) {
    return MusicPlaybackState(
      playerState: playerState ?? this.playerState,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTrack: currentTrack ?? this.currentTrack,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      originalQueue: originalQueue ?? this.originalQueue,
    );
  }
}

@riverpod
class MusicPlayer extends _$MusicPlayer with LogMixin {
  late final AudioPlayer _audioPlayer;
  final _random = math.Random();
  
  @override
  MusicPlaybackState build() {
    _initializeAudioPlayer();
    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    return const MusicPlaybackState();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final newState = switch (playerState.processingState) {
        ProcessingState.idle => MusicPlayerState.idle,
        ProcessingState.loading => MusicPlayerState.loading,
        ProcessingState.buffering => MusicPlayerState.loading,
        ProcessingState.ready => playerState.playing 
            ? MusicPlayerState.playing 
            : MusicPlayerState.paused,
        ProcessingState.completed => _handleTrackCompleted(),
      };

      if (newState != null) {
        log.debug('Music player state change: $newState, playing: ${playerState.playing}');
        state = state.copyWith(
          playerState: newState,
          isLoading: playerState.processingState == ProcessingState.loading ||
                    playerState.processingState == ProcessingState.buffering,
        );
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(totalDuration: duration);
      }
    });

    // Configure audio session for music
    _configureAudioSession();
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      log.error('Failed to configure audio session', error: e);
    }
  }

  // Queue management
  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      List<Track> queue = [...tracks];
      List<Track> originalQueue = [...tracks];
      
      // If shuffle is on, randomize the queue (except current track)
      if (state.shuffle && tracks.length > 1) {
        final currentTrack = tracks[startIndex];
        final otherTracks = tracks.where((t) => t.id != currentTrack.id).toList();
        
        // Fisher-Yates shuffle
        for (int i = otherTracks.length - 1; i > 0; i--) {
          final j = _random.nextInt(i + 1);
          final temp = otherTracks[i];
          otherTracks[i] = otherTracks[j];
          otherTracks[j] = temp;
        }
        
        queue = [currentTrack, ...otherTracks];
        startIndex = 0;
      }

      state = state.copyWith(
        queue: queue,
        originalQueue: originalQueue,
        currentIndex: startIndex,
        currentTrack: queue[startIndex],
      );

      await _loadTrack(queue[startIndex]);
      await play();

    } catch (e) {
      log.error('Failed to set queue', error: e);
      state = state.copyWith(
        playerState: MusicPlayerState.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> playTrack(Track track, {List<Track>? context}) async {
    if (context != null && context.isNotEmpty) {
      // Playing from a specific context (album, playlist, etc.)
      final index = context.indexWhere((t) => t.id == track.id);
      await setQueue(context, startIndex: index >= 0 ? index : 0);
    } else {
      // Playing a single track
      await setQueue([track], startIndex: 0);
    }
  }

  Future<void> playAlbum(Album album, {int startIndex = 0}) async {
    await setQueue(album.tracks, startIndex: startIndex);
  }

  Future<void> addToQueue(Track track) async {
    final newQueue = [...state.queue, track];
    state = state.copyWith(queue: newQueue);
    
    // If nothing is playing, start playing
    if (state.currentIndex == -1) {
      await setQueue(newQueue, startIndex: 0);
    }
  }

  Future<void> playNext(Track track) async {
    final newQueue = [...state.queue];
    newQueue.insert(state.currentIndex + 1, track);
    state = state.copyWith(queue: newQueue);
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    
    final newQueue = [...state.queue];
    newQueue.removeAt(index);
    
    int newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex--;
    } else if (index == state.currentIndex) {
      // Current track was removed
      if (newQueue.isEmpty) {
        await stop();
        return;
      }
      newIndex = math.min(index, newQueue.length - 1);
      await _loadTrack(newQueue[newIndex]);
    }
    
    state = state.copyWith(
      queue: newQueue,
      currentIndex: newIndex,
    );
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final newQueue = [...state.queue];
    final track = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, track);
    
    // Adjust current index if needed
    int currentIndex = state.currentIndex;
    if (oldIndex == state.currentIndex) {
      currentIndex = newIndex;
    } else if (oldIndex < state.currentIndex && newIndex >= state.currentIndex) {
      currentIndex--;
    } else if (oldIndex > state.currentIndex && newIndex <= state.currentIndex) {
      currentIndex++;
    }
    
    state = state.copyWith(
      queue: newQueue,
      currentIndex: currentIndex,
    );
  }

  void clearQueue() {
    stop();
  }

  // Playback controls
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
      state = const MusicPlaybackState();
    } catch (e) {
      log.error('Failed to stop audio', error: e);
    }
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    
    int nextIndex = state.currentIndex + 1;
    
    if (nextIndex >= state.queue.length) {
      if (state.repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        return; // End of queue
      }
    }
    
    state = state.copyWith(currentIndex: nextIndex);
    await _loadTrack(state.queue[nextIndex]);
    await play();
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    
    // If more than 3 seconds into the song, restart it
    if (state.currentPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    
    int prevIndex = state.currentIndex - 1;
    
    if (prevIndex < 0) {
      if (state.repeatMode == RepeatMode.all) {
        prevIndex = state.queue.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    }
    
    state = state.copyWith(currentIndex: prevIndex);
    await _loadTrack(state.queue[prevIndex]);
    await play();
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      log.error('Failed to seek to position', error: e);
    }
  }

  Future<void> skipTo(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    
    state = state.copyWith(currentIndex: index);
    await _loadTrack(state.queue[index]);
    await play();
  }

  // Settings
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      state = state.copyWith(volume: clampedVolume);
    } catch (e) {
      log.error('Failed to set volume', error: e);
    }
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffle;
    
    if (newShuffle) {
      // Enable shuffle - randomize remaining tracks
      final currentTrack = state.queue[state.currentIndex];
      final upcomingTracks = state.queue.sublist(state.currentIndex + 1);
      final playedTracks = state.queue.sublist(0, state.currentIndex);
      
      // Shuffle upcoming tracks
      for (int i = upcomingTracks.length - 1; i > 0; i--) {
        final j = _random.nextInt(i + 1);
        final temp = upcomingTracks[i];
        upcomingTracks[i] = upcomingTracks[j];
        upcomingTracks[j] = temp;
      }
      
      final newQueue = [...playedTracks, currentTrack, ...upcomingTracks];
      state = state.copyWith(queue: newQueue, shuffle: newShuffle);
    } else {
      // Disable shuffle - restore original order
      if (state.originalQueue.isNotEmpty && state.currentIndex >= 0) {
        final currentTrack = state.queue[state.currentIndex];
        final newIndex = state.originalQueue.indexWhere((t) => t.id == currentTrack.id);
        state = state.copyWith(
          queue: [...state.originalQueue],
          currentIndex: newIndex >= 0 ? newIndex : 0,
          shuffle: newShuffle,
        );
      } else {
        state = state.copyWith(shuffle: newShuffle);
      }
    }
  }

  void cycleRepeat() {
    final modes = [RepeatMode.none, RepeatMode.all, RepeatMode.one];
    final currentIndex = modes.indexOf(state.repeatMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    state = state.copyWith(repeatMode: modes[nextIndex]);
  }

  // Private methods
  Future<void> _loadTrack(Track track) async {
    try {
      state = state.copyWith(
        currentTrack: track,
        isLoading: true,
      );

      // Set up background playback metadata
      final mediaItem = MediaItem(
        id: track.id,
        title: track.name,
        artist: track.displayArtist,
        album: track.album,
        artUri: track.imageUrl != null ? Uri.parse(track.imageUrl!) : null,
        duration: track.duration,
      );

      // Load audio source
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(track.streamUrl),
          tag: mediaItem,
        ),
      );

      state = state.copyWith(
        playerState: MusicPlayerState.paused,
        isLoading: false,
      );

      log.info('Track loaded: ${track.name}');
    } catch (e) {
      log.error('Failed to load track: ${track.name}', error: e);
      state = state.copyWith(
        playerState: MusicPlayerState.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  MusicPlayerState? _handleTrackCompleted() {
    if (state.repeatMode == RepeatMode.one) {
      // Repeat current track
      seek(Duration.zero);
      play();
      return null;
    } else {
      // Play next track
      next();
      return MusicPlayerState.paused;
    }
  }
}