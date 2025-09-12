import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pavo_flutter/core/logging/app_logger.dart';

/// Crash reporter for handling uncaught errors
class CrashReporter {
  static void initialize() {
    // Capture Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.fatal(
        'Flutter Error',
        data: {
          'library': details.library,
          'context': details.context?.toString(),
          'silent': details.silent,
        },
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // In production, you would send this to a crash reporting service
      if (kReleaseMode) {
        _sendToCrashlytics(details.exception, details.stack);
      }
    };
    
    // Capture Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.fatal(
        'Uncaught Error',
        error: error,
        stackTrace: stack,
      );
      
      // In production, you would send this to a crash reporting service
      if (kReleaseMode) {
        _sendToCrashlytics(error, stack);
      }
      
      return true; // Prevents the app from crashing
    };
    
    logger.info('Crash reporter initialized');
  }
  
  /// Send crash report to external service (placeholder)
  static Future<void> _sendToCrashlytics(Object error, StackTrace? stack) async {
    // This is where you would integrate with services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // - etc.
    
    // For now, just log that we would send it
    logger.debug('Would send crash report to external service', data: {
      'error': error.toString(),
      'hasStackTrace': stack != null,
    });
  }
  
  /// Manually report an error
  static void reportError(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) {
    if (fatal) {
      logger.fatal(
        'Reported Fatal Error',
        data: context,
        error: error,
        stackTrace: stack,
      );
    } else {
      logger.error(
        'Reported Error',
        data: context,
        error: error,
        stackTrace: stack,
      );
    }
    
    if (kReleaseMode) {
      _sendToCrashlytics(error, stack);
    }
  }
  
  /// Report a caught exception with context
  static void reportCaughtException(
    Object exception,
    StackTrace? stack, {
    String? message,
    Map<String, dynamic>? data,
  }) {
    logger.error(
      message ?? 'Caught Exception',
      data: data,
      error: exception,
      stackTrace: stack,
    );
  }
  
  /// Run code in a guarded zone with error handling
  static Future<T?> runGuarded<T>(
    Future<T> Function() body, {
    String? operation,
  }) async {
    try {
      return await body();
    } catch (error, stack) {
      logger.error(
        'Error in guarded operation: ${operation ?? 'unknown'}',
        error: error,
        stackTrace: stack,
      );
      
      if (kReleaseMode) {
        _sendToCrashlytics(error, stack);
      }
      
      return null;
    }
  }
}