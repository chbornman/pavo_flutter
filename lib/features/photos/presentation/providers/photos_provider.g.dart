// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photosNotifierHash() => r'74c04553679dad075286f5df7b055b61a8856c16';

/// Main photos notifier using Riverpod code generation
/// This follows Flutter's reactive state management patterns
///
/// Copied from [PhotosNotifier].
@ProviderFor(PhotosNotifier)
final photosNotifierProvider =
    AutoDisposeNotifierProvider<PhotosNotifier, PhotosState>.internal(
  PhotosNotifier.new,
  name: r'photosNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photosNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhotosNotifier = AutoDisposeNotifier<PhotosState>;
String _$photoSearchNotifierHash() =>
    r'f40a7af317d06fa7d98b42e68e7ca3920ba8e0cf';

/// Search provider for photo search functionality
///
/// Copied from [PhotoSearchNotifier].
@ProviderFor(PhotoSearchNotifier)
final photoSearchNotifierProvider =
    AutoDisposeNotifierProvider<PhotoSearchNotifier, PhotosState>.internal(
  PhotoSearchNotifier.new,
  name: r'photoSearchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photoSearchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhotoSearchNotifier = AutoDisposeNotifier<PhotosState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
