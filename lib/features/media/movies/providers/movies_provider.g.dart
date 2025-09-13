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
String _$movieByIdHash() => r'e21dd58c9d07bceabe0075cffa14b9cfbdce0a38';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [movieById].
@ProviderFor(movieById)
const movieByIdProvider = MovieByIdFamily();

/// See also [movieById].
class MovieByIdFamily extends Family<AsyncValue<MediaItem>> {
  /// See also [movieById].
  const MovieByIdFamily();

  /// See also [movieById].
  MovieByIdProvider call(
    String movieId,
  ) {
    return MovieByIdProvider(
      movieId,
    );
  }

  @override
  MovieByIdProvider getProviderOverride(
    covariant MovieByIdProvider provider,
  ) {
    return call(
      provider.movieId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'movieByIdProvider';
}

/// See also [movieById].
class MovieByIdProvider extends AutoDisposeFutureProvider<MediaItem> {
  /// See also [movieById].
  MovieByIdProvider(
    String movieId,
  ) : this._internal(
          (ref) => movieById(
            ref as MovieByIdRef,
            movieId,
          ),
          from: movieByIdProvider,
          name: r'movieByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$movieByIdHash,
          dependencies: MovieByIdFamily._dependencies,
          allTransitiveDependencies: MovieByIdFamily._allTransitiveDependencies,
          movieId: movieId,
        );

  MovieByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.movieId,
  }) : super.internal();

  final String movieId;

  @override
  Override overrideWith(
    FutureOr<MediaItem> Function(MovieByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MovieByIdProvider._internal(
        (ref) => create(ref as MovieByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        movieId: movieId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MediaItem> createElement() {
    return _MovieByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieByIdProvider && other.movieId == movieId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, movieId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MovieByIdRef on AutoDisposeFutureProviderRef<MediaItem> {
  /// The parameter `movieId` of this provider.
  String get movieId;
}

class _MovieByIdProviderElement
    extends AutoDisposeFutureProviderElement<MediaItem> with MovieByIdRef {
  _MovieByIdProviderElement(super.provider);

  @override
  String get movieId => (origin as MovieByIdProvider).movieId;
}

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
