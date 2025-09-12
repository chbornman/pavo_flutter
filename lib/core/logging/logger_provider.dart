import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/core/logging/app_logger.dart';

/// Provider for the global logger instance
final loggerProvider = Provider<AppLogger>((ref) {
  return logger;
});

/// Provider for service-specific loggers
final serviceLoggerProvider = Provider.family<AppLogger, String>((ref, serviceName) {
  return logger.forService(serviceName);
});

/// Observer for Riverpod state changes
class LoggingProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    logger.trace('Provider added: ${provider.name ?? provider.runtimeType}', data: {
      'value': value?.runtimeType.toString(),
    });
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger.trace('Provider updated: ${provider.name ?? provider.runtimeType}', data: {
      'previousValue': previousValue?.runtimeType.toString(),
      'newValue': newValue?.runtimeType.toString(),
    });
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    logger.trace('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}