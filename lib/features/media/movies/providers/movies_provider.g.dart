// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jellyfinServiceHash() => r'375d098508cf8395c7bc495170ca8d1628cab658';

/// See also [jellyfinService].
@ProviderFor(jellyfinService)
final jellyfinServiceProvider = AutoDisposeProvider<JellyfinService>.internal(
  jellyfinService,
  name: r'jellyfinServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellyfinServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellyfinServiceRef = AutoDisposeProviderRef<JellyfinService>;
String _$moviesHash() => r'407378d4957aea3f43bf3aa5bc284bd907a7449a';

/// See also [movies].
@ProviderFor(movies)
final moviesProvider = AutoDisposeFutureProvider<List<MediaItem>>.internal(
  movies,
  name: r'moviesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$moviesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MoviesRef = AutoDisposeFutureProviderRef<List<MediaItem>>;
String _$selectedMovieHash() => r'6976db99a9fa5257dcc58a66aa8447d107f78b3a';

/// See also [SelectedMovie].
@ProviderFor(SelectedMovie)
final selectedMovieProvider =
    AutoDisposeNotifierProvider<SelectedMovie, MediaItem?>.internal(
  SelectedMovie.new,
  name: r'selectedMovieProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMovieHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMovie = AutoDisposeNotifier<MediaItem?>;
String _$moviesRefresherHash() => r'e7a0be818a4b3de1dd9fd9943d99a4f61587be85';

/// Force refresh movies by clearing cache
///
/// Copied from [MoviesRefresher].
@ProviderFor(MoviesRefresher)
final moviesRefresherProvider =
    AutoDisposeNotifierProvider<MoviesRefresher, bool>.internal(
  MoviesRefresher.new,
  name: r'moviesRefresherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moviesRefresherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MoviesRefresher = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
