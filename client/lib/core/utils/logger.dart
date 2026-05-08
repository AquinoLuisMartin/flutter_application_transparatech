/// Application Logger
/// 
/// Centralized logging for the application
library;

import '../constants/app_constants.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class AppLogger {
  static const String _prefix = '[Verifi]';

  static void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!AppConstants.enableDebugLogging && level == LogLevel.debug) {
      return;
    }

    final tagPrefix = tag != null ? '[$tag]' : '';
    final levelPrefix = level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String();

    final logMessage = '$_prefix $levelPrefix $tagPrefix [$timestamp] $message';

    switch (level) {
      case LogLevel.debug:
        print(logMessage); // ignore: avoid_print
        break;
      case LogLevel.info:
        print(logMessage); // ignore: avoid_print
        break;
      case LogLevel.warning:
        print(logMessage); // ignore: avoid_print
        break;
      case LogLevel.error:
        print(logMessage); // ignore: avoid_print
        if (error != null) {
          print('Error: $error'); // ignore: avoid_print
        }
        if (stackTrace != null) {
          print('StackTrace:\n$stackTrace'); // ignore: avoid_print
        }
        break;
      case LogLevel.fatal:
        print(logMessage); // ignore: avoid_print
        if (error != null) {
          print('Error: $error'); // ignore: avoid_print
        }
        if (stackTrace != null) {
          print('StackTrace:\n$stackTrace'); // ignore: avoid_print
        }
        break;
    }
  }
}
