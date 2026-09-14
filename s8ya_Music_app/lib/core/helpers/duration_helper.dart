/// Helper utilities for duration formatting.
///
/// Provides human-readable duration strings for the player UI,
/// song lists, and statistics.
class DurationHelper {
  DurationHelper._();

  /// Formats a [Duration] as `MM:SS` or `H:MM:SS` if over an hour.
  ///
  /// Example: `Duration(minutes: 3, seconds: 45)` → `"3:45"`
  /// Example: `Duration(hours: 1, minutes: 5)` → `"1:05:00"`
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats duration from milliseconds.
  static String formatMs(int milliseconds) {
    return format(Duration(milliseconds: milliseconds));
  }

  /// Formats a duration as a human-readable string.
  ///
  /// Example: `Duration(hours: 2, minutes: 30)` → `"2h 30m"`
  /// Example: `Duration(minutes: 45)` → `"45m"`
  static String formatLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Formats total listening time for statistics.
  ///
  /// Example: `Duration(days: 2, hours: 5)` → `"2 days, 5 hours"`
  static String formatStats(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    final parts = <String>[];
    if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
    if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    if (minutes > 0 && days == 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    }

    return parts.isEmpty ? '0 minutes' : parts.join(', ');
  }
}
