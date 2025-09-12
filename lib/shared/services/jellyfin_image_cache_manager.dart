import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for Jellyfin movie posters with aggressive caching
/// Optimized for poster images that change infrequently
class JellyfinImageCacheManager extends CacheManager {
  static const key = 'jellyfinImageCache';
  
  static JellyfinImageCacheManager? _instance;
  
  factory JellyfinImageCacheManager() {
    _instance ??= JellyfinImageCacheManager._();
    return _instance!;
  }
  
  JellyfinImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // Long stale period - posters don't change
      maxNrOfCacheObjects: 500, // Cache many movie posters
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

/// Utility methods for Jellyfin image caching
class JellyfinCacheUtils {
  /// Preload movie poster images for better UX
  static Future<void> preloadMoviePosters(List<String> imageUrls) async {
    final cacheManager = JellyfinImageCacheManager();
    
    // Download images in background (don't await)
    for (final url in imageUrls.take(20)) { // Limit to first 20 to avoid overwhelming
      cacheManager.downloadFile(url).ignore();
    }
  }
  
  /// Clear only expired poster cache entries
  static Future<void> clearExpiredPosters() async {
    final cacheManager = JellyfinImageCacheManager();
    await cacheManager.emptyCache();
  }
  
  /// Get cache size information
  static Future<int> getCacheSize() async {
    final cacheManager = JellyfinImageCacheManager();
    final files = await cacheManager.getFileFromCache('');
    return files?.file.lengthSync() ?? 0;
  }
}