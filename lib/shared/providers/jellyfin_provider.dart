import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';

/// Singleton provider for JellyfinService
/// This ensures we only create one instance of the service
final jellyfinServiceProvider = Provider<JellyfinService>((ref) {
  return JellyfinService();
});