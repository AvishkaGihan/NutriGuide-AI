import 'dart:developer' as dev;

enum LogLevel { debug, info, warning, error }

class LoggingService {
  // Private constructor
  LoggingService._();
  static final LoggingService instance = LoggingService._();

  void log(String message,
      {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    final prefix = _getPrefix(level);

    // In production, we would filter sensitive PII here before sending to a remote service.
    // For MVP/Debug, we print to console.

    dev.log(
      '[$prefix] $message',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      name: 'NutriGuide',
    );
  }

  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message, [Object? error]) =>
      log(message, level: LogLevel.warning, error: error);
  void error(String message, Object error, [StackTrace? stackTrace]) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);

  String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}
