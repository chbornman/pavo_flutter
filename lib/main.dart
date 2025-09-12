import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/app.dart';
import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/core/cache/cache_init_service.dart';
import 'package:pavo_flutter/core/logging/app_logger.dart';
import 'package:pavo_flutter/core/logging/crash_reporter.dart';
import 'package:pavo_flutter/core/logging/logger_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  initializeLogging(verbose: kDebugMode);
  logger.info('Starting PAVO app', data: {
    'mode': kReleaseMode ? 'release' : 'debug',
    'platform': defaultTargetPlatform.toString(),
  });
  
  // Initialize crash reporting
  CrashReporter.initialize();
  
  try {
    await EnvConfig.init();
    logger.info('Environment configuration loaded successfully');
    
    // Initialize cache systems
    await CacheInitService.initialize();
    logger.info('Cache systems initialized successfully');
  } catch (e, stackTrace) {
    logger.error('Failed to initialize app configuration', 
      error: e, 
      stackTrace: stackTrace
    );
  }
  
  runApp(
    ProviderScope(
      observers: kDebugMode ? [LoggingProviderObserver()] : [],
      child: const PavoApp(),
    ),
  );
}