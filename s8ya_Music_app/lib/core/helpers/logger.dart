import 'dart:developer' as developer;

/// Structured logging utility for the S8YA Music Player.
///
/// Provides leveled logging with consistent formatting.
/// Uses Dart's built-in `developer.log` for zero-overhead logging
/// when not attached to DevTools.
class Logger {
  Logger._();

  static const String _tag = 'S8YA';

  /// Logs a debug-level message.
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500,
    );
  }

  /// Logs an info-level message.
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800,
    );
  }

  /// Logs a warning-level message.
  static void warning(String message, {String? tag}) {
    developer.log(
      '⚠️ $message',
      name: tag ?? _tag,
      level: 900,
    );
  }

  /// Logs an error with optional exception and stack trace.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '❌ $message',
      name: tag ?? _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a performance-related message.
  static void performance(String message, {String? tag, Duration? elapsed}) {
    final suffix = elapsed != null ? ' [${elapsed.inMilliseconds}ms]' : '';
    developer.log(
      '⏱️ $message$suffix',
      name: tag ?? '$_tag/Perf',
      level: 800,
    );
  }
}
