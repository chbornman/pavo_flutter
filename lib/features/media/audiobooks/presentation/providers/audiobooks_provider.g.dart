// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audiobooks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audiobooksRepositoryHash() =>
    r'a3983a13344ceaccf7c9dd489ac0cbe6b6febe37';

/// See also [audiobooksRepository].
@ProviderFor(audiobooksRepository)
final audiobooksRepositoryProvider =
    AutoDisposeProvider<AudiobooksRepository>.internal(
  audiobooksRepository,
  name: r'audiobooksRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audiobooksRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudiobooksRepositoryRef = AutoDisposeProviderRef<AudiobooksRepository>;
String _$coverUrlHash() => r'4538b20a32b42bc8f77d0424a7fdeb06f1f18031';

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

/// See also [coverUrl].
@ProviderFor(coverUrl)
const coverUrlProvider = CoverUrlFamily();

/// See also [coverUrl].
class CoverUrlFamily extends Family<String> {
  /// See also [coverUrl].
  const CoverUrlFamily();

  /// See also [coverUrl].
  CoverUrlProvider call(
    String audiobookId, {
    int? width,
    int? height,
  }) {
    return CoverUrlProvider(
      audiobookId,
      width: width,
      height: height,
    );
  }

  @override
  CoverUrlProvider getProviderOverride(
    covariant CoverUrlProvider provider,
  ) {
    return call(
      provider.audiobookId,
      width: provider.width,
      height: provider.height,
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
  String? get name => r'coverUrlProvider';
}

/// See also [coverUrl].
class CoverUrlProvider extends AutoDisposeProvider<String> {
  /// See also [coverUrl].
  CoverUrlProvider(
    String audiobookId, {
    int? width,
    int? height,
  }) : this._internal(
          (ref) => coverUrl(
            ref as CoverUrlRef,
            audiobookId,
            width: width,
            height: height,
          ),
          from: coverUrlProvider,
          name: r'coverUrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$coverUrlHash,
          dependencies: CoverUrlFamily._dependencies,
          allTransitiveDependencies: CoverUrlFamily._allTransitiveDependencies,
          audiobookId: audiobookId,
          width: width,
          height: height,
        );

  CoverUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.audiobookId,
    required this.width,
    required this.height,
  }) : super.internal();

  final String audiobookId;
  final int? width;
  final int? height;

  @override
  Override overrideWith(
    String Function(CoverUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoverUrlProvider._internal(
        (ref) => create(ref as CoverUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        audiobookId: audiobookId,
        width: width,
        height: height,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _CoverUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverUrlProvider &&
        other.audiobookId == audiobookId &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, audiobookId.hashCode);
    hash = _SystemHash.combine(hash, width.hashCode);
    hash = _SystemHash.combine(hash, height.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoverUrlRef on AutoDisposeProviderRef<String> {
  /// The parameter `audiobookId` of this provider.
  String get audiobookId;

  /// The parameter `width` of this provider.
  int? get width;

  /// The parameter `height` of this provider.
  int? get height;
}

class _CoverUrlProviderElement extends AutoDisposeProviderElement<String>
    with CoverUrlRef {
  _CoverUrlProviderElement(super.provider);

  @override
  String get audiobookId => (origin as CoverUrlProvider).audiobookId;
  @override
  int? get width => (origin as CoverUrlProvider).width;
  @override
  int? get height => (origin as CoverUrlProvider).height;
}

String _$audiobooksListHash() => r'0262185394ca8024dac76be108dd29dfcc50e575';

abstract class _$AudiobooksList
    extends BuildlessAutoDisposeAsyncNotifier<List<AudiobookEntity>> {
  late final AudiobookFilter filter;
  late final AudiobookSort sort;

  FutureOr<List<AudiobookEntity>> build({
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  });
}

/// See also [AudiobooksList].
@ProviderFor(AudiobooksList)
const audiobooksListProvider = AudiobooksListFamily();

/// See also [AudiobooksList].
class AudiobooksListFamily extends Family<AsyncValue<List<AudiobookEntity>>> {
  /// See also [AudiobooksList].
  const AudiobooksListFamily();

  /// See also [AudiobooksList].
  AudiobooksListProvider call({
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  }) {
    return AudiobooksListProvider(
      filter: filter,
      sort: sort,
    );
  }

  @override
  AudiobooksListProvider getProviderOverride(
    covariant AudiobooksListProvider provider,
  ) {
    return call(
      filter: provider.filter,
      sort: provider.sort,
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
  String? get name => r'audiobooksListProvider';
}

/// See also [AudiobooksList].
class AudiobooksListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AudiobooksList, List<AudiobookEntity>> {
  /// See also [AudiobooksList].
  AudiobooksListProvider({
    AudiobookFilter filter = AudiobookFilter.all,
    AudiobookSort sort = AudiobookSort.nameAsc,
  }) : this._internal(
          () => AudiobooksList()
            ..filter = filter
            ..sort = sort,
          from: audiobooksListProvider,
          name: r'audiobooksListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$audiobooksListHash,
          dependencies: AudiobooksListFamily._dependencies,
          allTransitiveDependencies:
              AudiobooksListFamily._allTransitiveDependencies,
          filter: filter,
          sort: sort,
        );

  AudiobooksListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.sort,
  }) : super.internal();

  final AudiobookFilter filter;
  final AudiobookSort sort;

  @override
  FutureOr<List<AudiobookEntity>> runNotifierBuild(
    covariant AudiobooksList notifier,
  ) {
    return notifier.build(
      filter: filter,
      sort: sort,
    );
  }

  @override
  Override overrideWith(AudiobooksList Function() create) {
    return ProviderOverride(
      origin: this,
      override: AudiobooksListProvider._internal(
        () => create()
          ..filter = filter
          ..sort = sort,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        sort: sort,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AudiobooksList, List<AudiobookEntity>>
      createElement() {
    return _AudiobooksListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AudiobooksListProvider &&
        other.filter == filter &&
        other.sort == sort;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, sort.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AudiobooksListRef
    on AutoDisposeAsyncNotifierProviderRef<List<AudiobookEntity>> {
  /// The parameter `filter` of this provider.
  AudiobookFilter get filter;

  /// The parameter `sort` of this provider.
  AudiobookSort get sort;
}

class _AudiobooksListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AudiobooksList,
        List<AudiobookEntity>> with AudiobooksListRef {
  _AudiobooksListProviderElement(super.provider);

  @override
  AudiobookFilter get filter => (origin as AudiobooksListProvider).filter;
  @override
  AudiobookSort get sort => (origin as AudiobooksListProvider).sort;
}

String _$inProgressAudiobooksHash() =>
    r'bbe7275509386ddafd73891b3794d25f457c62ba';

/// See also [InProgressAudiobooks].
@ProviderFor(InProgressAudiobooks)
final inProgressAudiobooksProvider = AutoDisposeAsyncNotifierProvider<
    InProgressAudiobooks, List<AudiobookEntity>>.internal(
  InProgressAudiobooks.new,
  name: r'inProgressAudiobooksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inProgressAudiobooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InProgressAudiobooks
    = AutoDisposeAsyncNotifier<List<AudiobookEntity>>;
String _$recentSessionsHash() => r'86950d86020969da677d3b5200564b06f6b3373e';

/// See also [RecentSessions].
@ProviderFor(RecentSessions)
final recentSessionsProvider = AutoDisposeAsyncNotifierProvider<RecentSessions,
    List<PlaybackSessionEntity>>.internal(
  RecentSessions.new,
  name: r'recentSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecentSessions
    = AutoDisposeAsyncNotifier<List<PlaybackSessionEntity>>;
String _$playbackSessionHash() => r'47277c7f494c057a3285fa12dcf91cfd1e2d3b35';

abstract class _$PlaybackSession
    extends BuildlessAutoDisposeAsyncNotifier<PlaybackSessionEntity?> {
  late final String audiobookId;

  FutureOr<PlaybackSessionEntity?> build(
    String audiobookId,
  );
}

/// See also [PlaybackSession].
@ProviderFor(PlaybackSession)
const playbackSessionProvider = PlaybackSessionFamily();

/// See also [PlaybackSession].
class PlaybackSessionFamily extends Family<AsyncValue<PlaybackSessionEntity?>> {
  /// See also [PlaybackSession].
  const PlaybackSessionFamily();

  /// See also [PlaybackSession].
  PlaybackSessionProvider call(
    String audiobookId,
  ) {
    return PlaybackSessionProvider(
      audiobookId,
    );
  }

  @override
  PlaybackSessionProvider getProviderOverride(
    covariant PlaybackSessionProvider provider,
  ) {
    return call(
      provider.audiobookId,
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
  String? get name => r'playbackSessionProvider';
}

/// See also [PlaybackSession].
class PlaybackSessionProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PlaybackSession, PlaybackSessionEntity?> {
  /// See also [PlaybackSession].
  PlaybackSessionProvider(
    String audiobookId,
  ) : this._internal(
          () => PlaybackSession()..audiobookId = audiobookId,
          from: playbackSessionProvider,
          name: r'playbackSessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playbackSessionHash,
          dependencies: PlaybackSessionFamily._dependencies,
          allTransitiveDependencies:
              PlaybackSessionFamily._allTransitiveDependencies,
          audiobookId: audiobookId,
        );

  PlaybackSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.audiobookId,
  }) : super.internal();

  final String audiobookId;

  @override
  FutureOr<PlaybackSessionEntity?> runNotifierBuild(
    covariant PlaybackSession notifier,
  ) {
    return notifier.build(
      audiobookId,
    );
  }

  @override
  Override overrideWith(PlaybackSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: PlaybackSessionProvider._internal(
        () => create()..audiobookId = audiobookId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        audiobookId: audiobookId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PlaybackSession,
      PlaybackSessionEntity?> createElement() {
    return _PlaybackSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaybackSessionProvider && other.audiobookId == audiobookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, audiobookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlaybackSessionRef
    on AutoDisposeAsyncNotifierProviderRef<PlaybackSessionEntity?> {
  /// The parameter `audiobookId` of this provider.
  String get audiobookId;
}

class _PlaybackSessionProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PlaybackSession,
        PlaybackSessionEntity?> with PlaybackSessionRef {
  _PlaybackSessionProviderElement(super.provider);

  @override
  String get audiobookId => (origin as PlaybackSessionProvider).audiobookId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
