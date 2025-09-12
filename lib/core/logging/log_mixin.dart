import 'package:pavo_flutter/core/logging/app_logger.dart';

/// Mixin to add logging capabilities to any class
mixin LogMixin {
  late final AppLogger log = logger.forService(runtimeType.toString());
  
  /// Log a method entry with parameters
  void logMethodEntry(String methodName, {Map<String, dynamic>? params}) {
    log.trace('→ $methodName', data: params);
  }
  
  /// Log a method exit with return value
  void logMethodExit(String methodName, {dynamic returnValue}) {
    log.trace('← $methodName', data: returnValue != null ? {'return': returnValue} : null);
  }
  
  /// Log an API call
  void logApiCall(String endpoint, {String? method, Map<String, dynamic>? params}) {
    log.debug('API Call: ${method ?? 'GET'} $endpoint', data: params);
  }
  
  /// Log an API response
  void logApiResponse(String endpoint, {int? statusCode, dynamic data}) {
    final logData = <String, dynamic>{};
    if (statusCode != null) logData['status'] = statusCode;
    if (data != null) logData['response'] = data.toString().substring(0, 200); // Truncate long responses
    
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      log.debug('API Response: $endpoint', data: logData);
    } else {
      log.warning('API Response: $endpoint', data: logData);
    }
  }
  
  /// Log a state change
  void logStateChange(String stateName, {dynamic oldValue, dynamic newValue}) {
    log.info('State change: $stateName', data: {
      if (oldValue != null) 'old': oldValue,
      if (newValue != null) 'new': newValue,
    });
  }
  
  /// Log a user action
  void logUserAction(String action, {Map<String, dynamic>? details}) {
    log.info('User action: $action', data: details);
  }
  
  /// Log performance metrics
  void logPerformance(String operation, Duration duration, {Map<String, dynamic>? extra}) {
    final data = <String, dynamic>{
      'duration_ms': duration.inMilliseconds,
      ...?extra,
    };
    
    if (duration.inMilliseconds > 1000) {
      log.warning('Slow operation: $operation', data: data);
    } else {
      log.debug('Performance: $operation', data: data);
    }
  }
}