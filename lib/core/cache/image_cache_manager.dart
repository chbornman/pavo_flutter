import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for images with aggressive memory limits
class CustomImageCacheManager extends CacheManager {
  static const key = 'customImageCache';
  
  static CustomImageCacheManager? _instance;
  
  factory CustomImageCacheManager() {
    _instance ??= CustomImageCacheManager._();
    return _instance!;
  }
  
  CustomImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(minutes: 5), // Short stale period
      maxNrOfCacheObjects: 100, // Limit number of cached images
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  /// Clear memory cache to free up RAM
  static void clearMemoryCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Configure image cache size
  static void configureCache() {
    // Limit memory cache size to prevent OOM
    PaintingBinding.instance.imageCache.maximumSize = 50; // Max 50 images in memory
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // Max 50MB
  }
}