// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_shows_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tvShowsHash() => r'cd13ecedc25f2cbcfd26d31fe6b3eec6061c91cd';

/// See also [tvShows].
@ProviderFor(tvShows)
final tvShowsProvider = AutoDisposeFutureProvider<List<MediaItem>>.internal(
  tvShows,
  name: r'tvShowsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tvShowsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TvShowsRef = AutoDisposeFutureProviderRef<List<MediaItem>>;
String _$tvShowByIdHash() => r'6ec5f313aab84dabbc294ba86ac35412a71d7af1';

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

/// See also [tvShowById].
@ProviderFor(tvShowById)
const tvShowByIdProvider = TvShowByIdFamily();

/// See also [tvShowById].
class TvShowByIdFamily extends Family<AsyncValue<MediaItem>> {
  /// See also [tvShowById].
  const TvShowByIdFamily();

  /// See also [tvShowById].
  TvShowByIdProvider call(
    String showId,
  ) {
    return TvShowByIdProvider(
      showId,
    );
  }

  @override
  TvShowByIdProvider getProviderOverride(
    covariant TvShowByIdProvider provider,
  ) {
    return call(
      provider.showId,
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
  String? get name => r'tvShowByIdProvider';
}

/// See also [tvShowById].
class TvShowByIdProvider extends AutoDisposeFutureProvider<MediaItem> {
  /// See also [tvShowById].
  TvShowByIdProvider(
    String showId,
  ) : this._internal(
          (ref) => tvShowById(
            ref as TvShowByIdRef,
            showId,
          ),
          from: tvShowByIdProvider,
          name: r'tvShowByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tvShowByIdHash,
          dependencies: TvShowByIdFamily._dependencies,
          allTransitiveDependencies:
              TvShowByIdFamily._allTransitiveDependencies,
          showId: showId,
        );

  TvShowByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showId,
  }) : super.internal();

  final String showId;

  @override
  Override overrideWith(
    FutureOr<MediaItem> Function(TvShowByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TvShowByIdProvider._internal(
        (ref) => create(ref as TvShowByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showId: showId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MediaItem> createElement() {
    return _TvShowByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TvShowByIdProvider && other.showId == showId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TvShowByIdRef on AutoDisposeFutureProviderRef<MediaItem> {
  /// The parameter `showId` of this provider.
  String get showId;
}

class _TvShowByIdProviderElement
    extends AutoDisposeFutureProviderElement<MediaItem> with TvShowByIdRef {
  _TvShowByIdProviderElement(super.provider);

  @override
  String get showId => (origin as TvShowByIdProvider).showId;
}

String _$tvShowSeasonsHash() => r'd5029b95a1e1aa796c6773d3842c51ddfb859be9';

/// See also [tvShowSeasons].
@ProviderFor(tvShowSeasons)
const tvShowSeasonsProvider = TvShowSeasonsFamily();

/// See also [tvShowSeasons].
class TvShowSeasonsFamily extends Family<AsyncValue<List<Season>>> {
  /// See also [tvShowSeasons].
  const TvShowSeasonsFamily();

  /// See also [tvShowSeasons].
  TvShowSeasonsProvider call(
    String showId,
  ) {
    return TvShowSeasonsProvider(
      showId,
    );
  }

  @override
  TvShowSeasonsProvider getProviderOverride(
    covariant TvShowSeasonsProvider provider,
  ) {
    return call(
      provider.showId,
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
  String? get name => r'tvShowSeasonsProvider';
}

/// See also [tvShowSeasons].
class TvShowSeasonsProvider extends AutoDisposeFutureProvider<List<Season>> {
  /// See also [tvShowSeasons].
  TvShowSeasonsProvider(
    String showId,
  ) : this._internal(
          (ref) => tvShowSeasons(
            ref as TvShowSeasonsRef,
            showId,
          ),
          from: tvShowSeasonsProvider,
          name: r'tvShowSeasonsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tvShowSeasonsHash,
          dependencies: TvShowSeasonsFamily._dependencies,
          allTransitiveDependencies:
              TvShowSeasonsFamily._allTransitiveDependencies,
          showId: showId,
        );

  TvShowSeasonsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showId,
  }) : super.internal();

  final String showId;

  @override
  Override overrideWith(
    FutureOr<List<Season>> Function(TvShowSeasonsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TvShowSeasonsProvider._internal(
        (ref) => create(ref as TvShowSeasonsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showId: showId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Season>> createElement() {
    return _TvShowSeasonsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TvShowSeasonsProvider && other.showId == showId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TvShowSeasonsRef on AutoDisposeFutureProviderRef<List<Season>> {
  /// The parameter `showId` of this provider.
  String get showId;
}

class _TvShowSeasonsProviderElement
    extends AutoDisposeFutureProviderElement<List<Season>>
    with TvShowSeasonsRef {
  _TvShowSeasonsProviderElement(super.provider);

  @override
  String get showId => (origin as TvShowSeasonsProvider).showId;
}

String _$seasonEpisodesHash() => r'be8262381a3b629bf3099857d3d00711712a6ffe';

/// See also [seasonEpisodes].
@ProviderFor(seasonEpisodes)
const seasonEpisodesProvider = SeasonEpisodesFamily();

/// See also [seasonEpisodes].
class SeasonEpisodesFamily extends Family<AsyncValue<List<Episode>>> {
  /// See also [seasonEpisodes].
  const SeasonEpisodesFamily();

  /// See also [seasonEpisodes].
  SeasonEpisodesProvider call(
    String showId,
    String seasonId,
  ) {
    return SeasonEpisodesProvider(
      showId,
      seasonId,
    );
  }

  @override
  SeasonEpisodesProvider getProviderOverride(
    covariant SeasonEpisodesProvider provider,
  ) {
    return call(
      provider.showId,
      provider.seasonId,
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
  String? get name => r'seasonEpisodesProvider';
}

/// See also [seasonEpisodes].
class SeasonEpisodesProvider extends AutoDisposeFutureProvider<List<Episode>> {
  /// See also [seasonEpisodes].
  SeasonEpisodesProvider(
    String showId,
    String seasonId,
  ) : this._internal(
          (ref) => seasonEpisodes(
            ref as SeasonEpisodesRef,
            showId,
            seasonId,
          ),
          from: seasonEpisodesProvider,
          name: r'seasonEpisodesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seasonEpisodesHash,
          dependencies: SeasonEpisodesFamily._dependencies,
          allTransitiveDependencies:
              SeasonEpisodesFamily._allTransitiveDependencies,
          showId: showId,
          seasonId: seasonId,
        );

  SeasonEpisodesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showId,
    required this.seasonId,
  }) : super.internal();

  final String showId;
  final String seasonId;

  @override
  Override overrideWith(
    FutureOr<List<Episode>> Function(SeasonEpisodesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeasonEpisodesProvider._internal(
        (ref) => create(ref as SeasonEpisodesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showId: showId,
        seasonId: seasonId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Episode>> createElement() {
    return _SeasonEpisodesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonEpisodesProvider &&
        other.showId == showId &&
        other.seasonId == seasonId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showId.hashCode);
    hash = _SystemHash.combine(hash, seasonId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeasonEpisodesRef on AutoDisposeFutureProviderRef<List<Episode>> {
  /// The parameter `showId` of this provider.
  String get showId;

  /// The parameter `seasonId` of this provider.
  String get seasonId;
}

class _SeasonEpisodesProviderElement
    extends AutoDisposeFutureProviderElement<List<Episode>>
    with SeasonEpisodesRef {
  _SeasonEpisodesProviderElement(super.provider);

  @override
  String get showId => (origin as SeasonEpisodesProvider).showId;
  @override
  String get seasonId => (origin as SeasonEpisodesProvider).seasonId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
