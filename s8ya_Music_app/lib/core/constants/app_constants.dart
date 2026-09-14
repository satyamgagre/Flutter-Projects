/// Application-wide constants for the S8YA Music Player.
///
/// Contains configuration values, box names, supported formats,
/// and default settings used throughout the application.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'S8YA';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.s8ya.app';

  // Hive Box Names
  static const String settingsBoxName = 'settings_box';
  static const String cacheBoxName = 'cache_box';

  // Database
  static const String databaseName = 's8ya_music.db';
  static const int databaseVersion = 1;

  // Supported Audio Formats
  static const List<String> supportedFormats = [
    'mp3', 'aac', 'm4a', 'wav', 'flac', 'ogg', 'wma', 'opus',
  ];

  // Player Defaults
  static const double defaultPlaybackSpeed = 1.0;
  static const double minPlaybackSpeed = 0.25;
  static const double maxPlaybackSpeed = 3.0;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;
  static const int crossfadeDurationMs = 5000;

  // UI Constants
  static const double miniPlayerHeight = 72.0;
  static const double bottomNavHeight = 80.0;
  static const int recentlyPlayedLimit = 30;
  static const int mostPlayedLimit = 25;
  static const int recentlyAddedLimit = 20;
  static const int searchHistoryLimit = 20;
  static const int horizontalCardCount = 6;

  // Album Art
  static const int artworkThumbnailSize = 200;
  static const int artworkFullSize = 600;
  static const int artworkQuality = 80;

  // Sleep Timer Presets (minutes)
  static const List<int> sleepTimerPresets = [5, 10, 15, 20, 30, 45, 60, 90, 120];

  // Playback Speed Presets
  static const List<double> speedPresets = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

  // Settings Keys (Hive)
  static const String keyThemeMode = 'theme_mode';
  static const String keyAccentColor = 'accent_color';
  static const String keyIsAmoled = 'is_amoled';
  static const String keyShuffle = 'shuffle';
  static const String keyRepeatMode = 'repeat_mode';
  static const String keyPlaybackSpeed = 'playback_speed';
  static const String keyLastSongId = 'last_song_id';
  static const String keyLastPosition = 'last_position';
  static const String keyCrossfadeEnabled = 'crossfade_enabled';
  static const String keyCrossfadeDuration = 'crossfade_duration';
  static const String keyGaplessEnabled = 'gapless_enabled';
  static const String keySortBy = 'sort_by';
  static const String keySortOrder = 'sort_order';
  static const String keyScannedFolders = 'scanned_folders';
  static const String keyLastScanTime = 'last_scan_time';
}
