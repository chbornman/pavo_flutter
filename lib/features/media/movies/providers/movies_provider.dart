import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';
import 'package:pavo_flutter/core/cache/cache_init_service.dart';

part 'movies_provider.g.dart';

@riverpod
JellyfinService jellyfinService(JellyfinServiceRef ref) {
  return JellyfinService();
}

@riverpod
Future<List<MediaItem>> movies(MoviesRef ref) async {
  final service = ref.watch(jellyfinServiceProvider);
  return service.getMovies();
}

@riverpod
Future<MediaItem> movieById(MovieByIdRef ref, String movieId) async {
  final service = ref.watch(jellyfinServiceProvider);
  return service.getMovieById(movieId);
}

@riverpod
class SelectedMovie extends _$SelectedMovie {
  @override
  MediaItem? build() => null;
  
  void select(MediaItem movie) {
    state = movie;
  }
  
  void clear() {
    state = null;
  }
}

/// Force refresh movies by clearing cache
@riverpod
class MoviesRefresher extends _$MoviesRefresher {
  @override
  bool build() => false;
  
  Future<void> refresh() async {
    state = true;
    await CacheInitService.refreshMovieCaches();
    state = false;
  }
}