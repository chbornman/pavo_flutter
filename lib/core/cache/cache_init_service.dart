import 'package:pavo_flutter/core/cache/cache_manager.dart';
import 'package:pavo_flutter/core/cache/image_cache_manager.dart';

/// Service to initialize all cache managers and configure optimal settings
class CacheInitService {
  static Future<void> initialize() async {
    // Initialize the main cache manager
    await CacheManager().init();
    
    // Configure image cache for better performance
    CustomImageCacheManager.configureCache();
    
    // Clear expired cache entries on startup
    await _cleanupExpiredCache();
  }
  
  /// Clear expired entries from all cache systems
  static Future<void> _cleanupExpiredCache() async {
    try {
      // Clean up API response cache
      await CacheManager().clearExpired();
      
      // Clear Flutter's image memory cache if needed
      CustomImageCacheManager.clearMemoryCache();
      
    } catch (e) {
      // Silently fail - cache cleanup is not critical
    }
  }
  
  /// Force refresh all movie-related caches
  static Future<void> refreshMovieCaches() async {
    final cacheManager = CacheManager();
    
    // Clear movies cache to force fresh fetch
    await cacheManager.remove('jellyfin_movies');
    
    // Keep backup cache for offline support
    // Don't clear 'jellyfin_movies_backup'
  }
  
  /// Get cache statistics for debugging
  static Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'memory_cache_objects': 'Image cache configured',
      'disk_cache_status': 'Persistent cache initialized',
    };
  }
}