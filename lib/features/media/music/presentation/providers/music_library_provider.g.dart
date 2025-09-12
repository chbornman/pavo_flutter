// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jellyfinMusicServiceHash() =>
    r'4953083805c120c629fa99dcb29d2089b40e8b9e';

/// See also [jellyfinMusicService].
@ProviderFor(jellyfinMusicService)
final jellyfinMusicServiceProvider =
    AutoDisposeProvider<JellyfinService>.internal(
  jellyfinMusicService,
  name: r'jellyfinMusicServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellyfinMusicServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellyfinMusicServiceRef = AutoDisposeProviderRef<JellyfinService>;
String _$musicArtistsHash() => r'3c86057d2687f11a67911f0e3cdffd7b40f1218b';

/// See also [musicArtists].
@ProviderFor(musicArtists)
final musicArtistsProvider = AutoDisposeFutureProvider<List<Artist>>.internal(
  musicArtists,
  name: r'musicArtistsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$musicArtistsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MusicArtistsRef = AutoDisposeFutureProviderRef<List<Artist>>;
String _$artistWithAlbumsHash() => r'de0e751cceacdd750d3ff3586389655b42d690fc';

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

/// See also [artistWithAlbums].
@ProviderFor(artistWithAlbums)
const artistWithAlbumsProvider = ArtistWithAlbumsFamily();

/// See also [artistWithAlbums].
class ArtistWithAlbumsFamily extends Family<AsyncValue<Artist>> {
  /// See also [artistWithAlbums].
  const ArtistWithAlbumsFamily();

  /// See also [artistWithAlbums].
  ArtistWithAlbumsProvider call(
    String artistId,
  ) {
    return ArtistWithAlbumsProvider(
      artistId,
    );
  }

  @override
  ArtistWithAlbumsProvider getProviderOverride(
    covariant ArtistWithAlbumsProvider provider,
  ) {
    return call(
      provider.artistId,
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
  String? get name => r'artistWithAlbumsProvider';
}

/// See also [artistWithAlbums].
class ArtistWithAlbumsProvider extends AutoDisposeFutureProvider<Artist> {
  /// See also [artistWithAlbums].
  ArtistWithAlbumsProvider(
    String artistId,
  ) : this._internal(
          (ref) => artistWithAlbums(
            ref as ArtistWithAlbumsRef,
            artistId,
          ),
          from: artistWithAlbumsProvider,
          name: r'artistWithAlbumsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$artistWithAlbumsHash,
          dependencies: ArtistWithAlbumsFamily._dependencies,
          allTransitiveDependencies:
              ArtistWithAlbumsFamily._allTransitiveDependencies,
          artistId: artistId,
        );

  ArtistWithAlbumsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.artistId,
  }) : super.internal();

  final String artistId;

  @override
  Override overrideWith(
    FutureOr<Artist> Function(ArtistWithAlbumsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArtistWithAlbumsProvider._internal(
        (ref) => create(ref as ArtistWithAlbumsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        artistId: artistId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Artist> createElement() {
    return _ArtistWithAlbumsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtistWithAlbumsProvider && other.artistId == artistId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, artistId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArtistWithAlbumsRef on AutoDisposeFutureProviderRef<Artist> {
  /// The parameter `artistId` of this provider.
  String get artistId;
}

class _ArtistWithAlbumsProviderElement
    extends AutoDisposeFutureProviderElement<Artist> with ArtistWithAlbumsRef {
  _ArtistWithAlbumsProviderElement(super.provider);

  @override
  String get artistId => (origin as ArtistWithAlbumsProvider).artistId;
}

String _$albumDetailsHash() => r'6d4bff6c5397ce3d89d36857eeec2e38cf6cf546';

/// See also [albumDetails].
@ProviderFor(albumDetails)
const albumDetailsProvider = AlbumDetailsFamily();

/// See also [albumDetails].
class AlbumDetailsFamily extends Family<AsyncValue<Album>> {
  /// See also [albumDetails].
  const AlbumDetailsFamily();

  /// See also [albumDetails].
  AlbumDetailsProvider call(
    String albumId,
  ) {
    return AlbumDetailsProvider(
      albumId,
    );
  }

  @override
  AlbumDetailsProvider getProviderOverride(
    covariant AlbumDetailsProvider provider,
  ) {
    return call(
      provider.albumId,
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
  String? get name => r'albumDetailsProvider';
}

/// See also [albumDetails].
class AlbumDetailsProvider extends AutoDisposeFutureProvider<Album> {
  /// See also [albumDetails].
  AlbumDetailsProvider(
    String albumId,
  ) : this._internal(
          (ref) => albumDetails(
            ref as AlbumDetailsRef,
            albumId,
          ),
          from: albumDetailsProvider,
          name: r'albumDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$albumDetailsHash,
          dependencies: AlbumDetailsFamily._dependencies,
          allTransitiveDependencies:
              AlbumDetailsFamily._allTransitiveDependencies,
          albumId: albumId,
        );

  AlbumDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.albumId,
  }) : super.internal();

  final String albumId;

  @override
  Override overrideWith(
    FutureOr<Album> Function(AlbumDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AlbumDetailsProvider._internal(
        (ref) => create(ref as AlbumDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        albumId: albumId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Album> createElement() {
    return _AlbumDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlbumDetailsProvider && other.albumId == albumId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, albumId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AlbumDetailsRef on AutoDisposeFutureProviderRef<Album> {
  /// The parameter `albumId` of this provider.
  String get albumId;
}

class _AlbumDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Album> with AlbumDetailsRef {
  _AlbumDetailsProviderElement(super.provider);

  @override
  String get albumId => (origin as AlbumDetailsProvider).albumId;
}

String _$searchMusicHash() => r'b7e8e2cb7fb8e27ec6fa130f4c17d5838a76115e';

/// See also [searchMusic].
@ProviderFor(searchMusic)
const searchMusicProvider = SearchMusicFamily();

/// See also [searchMusic].
class SearchMusicFamily extends Family<AsyncValue<List<Track>>> {
  /// See also [searchMusic].
  const SearchMusicFamily();

  /// See also [searchMusic].
  SearchMusicProvider call(
    String query,
  ) {
    return SearchMusicProvider(
      query,
    );
  }

  @override
  SearchMusicProvider getProviderOverride(
    covariant SearchMusicProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchMusicProvider';
}

/// See also [searchMusic].
class SearchMusicProvider extends AutoDisposeFutureProvider<List<Track>> {
  /// See also [searchMusic].
  SearchMusicProvider(
    String query,
  ) : this._internal(
          (ref) => searchMusic(
            ref as SearchMusicRef,
            query,
          ),
          from: searchMusicProvider,
          name: r'searchMusicProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchMusicHash,
          dependencies: SearchMusicFamily._dependencies,
          allTransitiveDependencies:
              SearchMusicFamily._allTransitiveDependencies,
          query: query,
        );

  SearchMusicProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Track>> Function(SearchMusicRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchMusicProvider._internal(
        (ref) => create(ref as SearchMusicRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Track>> createElement() {
    return _SearchMusicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchMusicProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchMusicRef on AutoDisposeFutureProviderRef<List<Track>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchMusicProviderElement
    extends AutoDisposeFutureProviderElement<List<Track>> with SearchMusicRef {
  _SearchMusicProviderElement(super.provider);

  @override
  String get query => (origin as SearchMusicProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
