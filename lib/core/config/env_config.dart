import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration following Flutter best practices
/// 
/// This class uses the Singleton pattern (common in Flutter) to ensure
/// we only have one instance of our configuration throughout the app.
/// We use static getters to provide read-only access to env variables.
class EnvConfig {
  EnvConfig._(); // Private constructor prevents instantiation

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  // Service URLs - following naming convention from Pavo
  static String get immichUrl => 
      dotenv.env['NEXT_PUBLIC_IMMICH_URL'] ?? 'http://localhost:2283';
  
  static String get paperlessUrl => 
      dotenv.env['NEXT_PUBLIC_PAPERLESS_URL'] ?? 'http://localhost:8000';
  
  static String get jellyfinUrl => 
      dotenv.env['NEXT_PUBLIC_JELLYFIN_URL'] ?? 'http://localhost:8096';
  
  static String get audiobookshelfUrl => 
      dotenv.env['NEXT_PUBLIC_AUDIOBOOKSHELF_URL'] ?? 'http://localhost:13378';

  // API Keys - sensitive data
  static String? get immichApiKey => dotenv.env['IMMICH_API_KEY'];
  static String? get paperlessApiToken => dotenv.env['PAPERLESS_API_TOKEN'];
  static String? get jellyfinApiKey => dotenv.env['JELLYFIN_API_KEY'];
  static String? get jellyfinUserId => dotenv.env['JELLYFIN_USER_ID'];
  static String? get audiobookshelfApiKey => dotenv.env['AUDIOBOOKSHELF_API_KEY'];

  // App configuration
  static bool get isDevelopment => 
      dotenv.env['ENVIRONMENT']?.toLowerCase() == 'development';
  
  static int get cacheTimeout => 
      int.tryParse(dotenv.env['CACHE_TIMEOUT'] ?? '300') ?? 300; // 5 minutes default
  
  // Clerk authentication
  static String get clerkPublishableKey => 
      dotenv.env['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY'] ?? '';
}