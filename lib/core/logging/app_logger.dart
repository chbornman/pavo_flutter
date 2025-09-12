import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:logging/logging.dart' as logging;

/// Global logger instance
late final AppLogger logger;

/// Initialize the logging system
void initializeLogging({bool verbose = false}) {
  logger = AppLogger(verbose: verbose);
  _setupDartLogging();
}

/// Setup dart:developer logging integration
void _setupDartLogging() {
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    final level = _convertLoggingLevel(record.level);
    logger.log(
      level,
      record.message,
      time: record.time,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

Level _convertLoggingLevel(logging.Level level) {
  if (level == logging.Level.FINEST || level == logging.Level.FINER || level == logging.Level.FINE) {
    return Level.trace;
  } else if (level == logging.Level.CONFIG) {
    return Level.debug;
  } else if (level == logging.Level.INFO) {
    return Level.info;
  } else if (level == logging.Level.WARNING) {
    return Level.warning;
  } else if (level == logging.Level.SEVERE) {
    return Level.error;
  } else if (level == logging.Level.SHOUT) {
    return Level.fatal;
  }
  return Level.info;
}

/// Custom logger with structured logging support
class AppLogger {
  late final Logger _logger;
  final bool verbose;

  AppLogger({this.verbose = false}) {
    _logger = Logger(
      printer: _createPrinter(),
      filter: ProductionFilter(),
      output: _createOutput(),
    );
  }

  LogPrinter _createPrinter() {
    if (kReleaseMode) {
      return _StructuredPrinter();
    } else {
      return _CleanPrettyPrinter(verbose: verbose);
    }
  }

  LogOutput _createOutput() {
    return MultiOutput([
      ConsoleOutput(),
      if (!kReleaseMode) _FileOutput(),
    ]);
  }

  // Logging methods with structured data support
  void trace(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _logger.t(_formatMessage(message, data), time: time);
  }

  void debug(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _logger.d(_formatMessage(message, data), time: time);
  }

  void info(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _logger.i(_formatMessage(message, data), time: time);
  }

  void warning(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _logger.w(_formatMessage(message, data), time: time);
  }

  void error(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    _logger.e(
      _formatMessage(message, data),
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void fatal(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    _logger.f(
      _formatMessage(message, data),
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Generic log method
  void log(
    Level level,
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    _logger.log(
      level,
      _formatMessage(message, data),
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _formatMessage(String message, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return message;
    }
    
    if (kReleaseMode) {
      // In release mode, append data as JSON-like string
      final dataStr = data.entries
          .map((e) => '${e.key}=${_formatValue(e.value)}')
          .join(', ');
      return '$message [$dataStr]';
    } else {
      // In debug mode, format nicely
      final buffer = StringBuffer(message);
      if (data.isNotEmpty) {
        buffer.write('\n  Data: {');
        data.forEach((key, value) {
          buffer.write('\n    $key: ${_formatValue(value)}');
        });
        buffer.write('\n  }');
      }
      return buffer.toString();
    }
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return '"$value"';
    } else if (value is Map || value is List) {
      return value.toString();
    }
    return value.toString();
  }

  // Service-specific loggers
  AppLogger forService(String serviceName) {
    return _ServiceLogger(this, serviceName);
  }
}

/// Structured printer for production logs
class _StructuredPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = event.time.toIso8601String();
    final level = _levelString(event.level);
    final message = event.message;
    
    var logLine = '[$time] $level: $message';
    
    if (event.error != null) {
      logLine += ' | Error: ${event.error}';
    }
    
    if (event.stackTrace != null) {
      logLine += '\n${event.stackTrace}';
    }
    
    return [logLine];
  }

  String _levelString(Level level) {
    switch (level) {
      case Level.trace:
        return 'TRACE';
      case Level.debug:
        return 'DEBUG';
      case Level.info:
        return 'INFO';
      case Level.warning:
        return 'WARN';
      case Level.error:
        return 'ERROR';
      case Level.fatal:
        return 'FATAL';
      default:
        return 'INFO';
    }
  }
}

/// File output for development logging
class _FileOutput extends LogOutput {
  // This is a placeholder - in a real app, you'd write to a file
  // For now, it just prints with a FILE: prefix
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      debugPrint('FILE: $line');
    }
  }
}

/// Clean pretty printer that only shows stack traces for errors
class _CleanPrettyPrinter extends LogPrinter {
  final bool verbose;
  
  _CleanPrettyPrinter({this.verbose = false});

  @override
  List<String> log(LogEvent event) {
    final color = _getColor(event.level);
    final level = _getLevelString(event.level);
    final time = event.time.toIso8601String().substring(11, 19); // HH:mm:ss
    
    final buffer = <String>[];
    
    // Main log line: [TIME] LEVEL: message
    final message = event.message.toString();
    buffer.add('$color[$time] $level: $message');
    
    // Error if present
    if (event.error != null) {
      buffer.add('$color  Error: ${event.error}');
    }
    
    // Only show stack trace for errors/fatal or if verbose mode is on
    final showStackTrace = verbose || 
        event.level == Level.error || 
        event.level == Level.fatal ||
        event.level == Level.warning;
    
    if (showStackTrace && event.stackTrace != null) {
      final stackLines = event.stackTrace.toString().split('\n');
      // Show first 2-3 lines of stack trace
      final linesToShow = event.level == Level.error || event.level == Level.fatal ? 3 : 2;
      for (int i = 0; i < stackLines.length && i < linesToShow; i++) {
        buffer.add('$color  ${stackLines[i]}');
      }
    }
    
    return buffer;
  }
  
  String _getLevelString(Level level) {
    switch (level) {
      case Level.trace:
        return 'TRACE';
      case Level.debug:
        return 'DEBUG';
      case Level.info:
        return 'INFO';
      case Level.warning:
        return 'WARN';
      case Level.error:
        return 'ERROR';
      case Level.fatal:
        return 'FATAL';
      default:
        return 'INFO';
    }
  }
  
  String _getColor(Level level) {
    const reset = '\x1B[0m';
    switch (level) {
      case Level.trace:
        return '\x1B[90m'; // Gray
      case Level.debug:
        return '\x1B[36m'; // Cyan
      case Level.info:
        return '\x1B[34m'; // Blue
      case Level.warning:
        return '\x1B[33m'; // Yellow
      case Level.error:
        return '\x1B[31m'; // Red
      case Level.fatal:
        return '\x1B[35m'; // Magenta
      default:
        return reset;
    }
  }
}

/// Service-specific logger that prefixes all messages
class _ServiceLogger extends AppLogger {
  final AppLogger _parent;
  final String _serviceName;

  _ServiceLogger(this._parent, this._serviceName) : super(verbose: _parent.verbose);

  @override
  void trace(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _parent.trace('[$_serviceName] $message', data: data, time: time);
  }

  @override
  void debug(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _parent.debug('[$_serviceName] $message', data: data, time: time);
  }

  @override
  void info(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _parent.info('[$_serviceName] $message', data: data, time: time);
  }

  @override
  void warning(String message, {Map<String, dynamic>? data, DateTime? time}) {
    _parent.warning('[$_serviceName] $message', data: data, time: time);
  }

  @override
  void error(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    _parent.error(
      '[$_serviceName] $message',
      data: data,
      error: error,
      stackTrace: stackTrace,
      time: time,
    );
  }

  @override
  void fatal(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    _parent.fatal(
      '[$_serviceName] $message',
      data: data,
      error: error,
      stackTrace: stackTrace,
      time: time,
    );
  }
}