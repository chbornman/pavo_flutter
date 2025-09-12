import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic cache entry that stores data with metadata
/// This follows Flutter's pattern of immutable data classes
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => 
      DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl.inSeconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry<T>(
      data: json['data'] as T,
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(seconds: json['ttl']),
    );
  }
}

/// Cache manager following Flutter best practices:
/// - Uses SharedPreferences for persistent cache
/// - Memory cache for fast access
/// - Generic type support
/// - TTL (Time To Live) support like Pavo web
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // In-memory cache for fast access
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};
  
  // Persistent cache using SharedPreferences
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPersistedCache();
  }

  /// Store data in cache with TTL
  /// Uses both memory and persistent storage
  Future<void> set<T>({
    required String key,
    required T data,
    Duration ttl = const Duration(minutes: 5),
    bool persist = true,
  }) async {
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    // Always store in memory cache
    _memoryCache[key] = entry;

    // Optionally persist to disk
    if (persist && _prefs != null) {
      try {
        final json = jsonEncode(entry.toJson());
        await _prefs!.setString(key, json);
      } catch (e) {
        // If serialization fails, just keep in memory
        // Silently fail - caching is non-critical
      }
    }
  }

  /// Get data from cache
  /// Checks memory first, then persistent storage
  T? get<T>(String key) {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data as T?;
    }

    // Remove expired entry from memory
    if (memoryEntry?.isExpired == true) {
      _memoryCache.remove(key);
    }

    // Check persistent cache
    if (_prefs != null) {
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          final entry = CacheEntry<T>.fromJson(json);
          
          if (!entry.isExpired) {
            // Restore to memory cache for faster future access
            _memoryCache[key] = entry;
            return entry.data;
          } else {
            // Clean up expired entry
            _prefs!.remove(key);
          }
        } catch (e) {
          // Silently fail and remove invalid cache entry
          _prefs!.remove(key);
        }
      }
    }

    return null;
  }

  /// Check if cache contains valid (non-expired) entry
  bool contains(String key) {
    return get<dynamic>(key) != null;
  }

  /// Remove specific cache entry
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs?.remove(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((key) => 
        key.startsWith('cache_')).toList();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Clear expired entries
  Future<void> clearExpired() async {
    // Clear expired from memory
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // Clear expired from persistent storage
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString);
            final timestamp = DateTime.parse(json['timestamp']);
            final ttl = Duration(seconds: json['ttl']);
            if (DateTime.now().difference(timestamp) > ttl) {
              await _prefs!.remove(key);
            }
          } catch (_) {
            // Invalid entry, remove it
            await _prefs!.remove(key);
          }
        }
      }
    }
  }

  /// Load persisted cache into memory on startup
  Future<void> _loadPersistedCache() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        get<dynamic>(key); // This will load valid entries into memory
      }
    }
  }
}