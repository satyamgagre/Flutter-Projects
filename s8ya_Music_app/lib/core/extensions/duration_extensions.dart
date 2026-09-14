import '../helpers/duration_helper.dart';

/// Extension methods on [Duration] for convenient formatting.
extension DurationExtensions on Duration {
  /// Formats as `MM:SS` or `H:MM:SS`.
  ///
  /// Example: `Duration(minutes: 3, seconds: 45).formatted` → `"3:45"`
  String get formatted => DurationHelper.format(this);

  /// Formats as a human-readable long string.
  ///
  /// Example: `Duration(hours: 2, minutes: 30).formattedLong` → `"2h 30m"`
  String get formattedLong => DurationHelper.formatLong(this);

  /// Formats for statistics display.
  String get formattedStats => DurationHelper.formatStats(this);
}
