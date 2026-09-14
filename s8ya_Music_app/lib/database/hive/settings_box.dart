import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

/// Hive-based settings storage for fast read/write access.
///
/// Uses Hive instead of SQLite for settings because:
/// - Settings are read on every app start (Hive is faster for single-key reads)
/// - Settings are simple key-value pairs (no relational queries needed)
/// - Hive supports synchronous reads after initial open
class SettingsBox {
  SettingsBox._();
  static final SettingsBox instance = SettingsBox._();

  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.settingsBoxName);

  // --- Generic getters/setters ---

  /// Gets a value from settings, returning [defaultValue] if not found.
  T get<T>(String key, T defaultValue) {
    return _box.get(key, defaultValue: defaultValue) as T;
  }

  /// Sets a value in settings.
  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  /// Removes a key from settings.
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  // --- Typed accessors for common settings ---

  /// Gets the shuffle mode (0=off, 1=on, 2=smart).
  int get shuffleMode => get<int>(AppConstants.keyShuffle, 0);
  Future<void> setShuffleMode(int mode) => set(AppConstants.keyShuffle, mode);

  /// Gets the repeat mode (0=off, 1=all, 2=one).
  int get repeatMode => get<int>(AppConstants.keyRepeatMode, 0);
  Future<void> setRepeatMode(int mode) => set(AppConstants.keyRepeatMode, mode);

  /// Gets the playback speed.
  double get playbackSpeed =>
      get<double>(AppConstants.keyPlaybackSpeed, AppConstants.defaultPlaybackSpeed);
  Future<void> setPlaybackSpeed(double speed) =>
      set(AppConstants.keyPlaybackSpeed, speed);

  /// Gets the last played song ID.
  int? get lastSongId => _box.get(AppConstants.keyLastSongId) as int?;
  Future<void> setLastSongId(int? id) => set(AppConstants.keyLastSongId, id);

  /// Gets the last playback position in milliseconds.
  int? get lastPosition => _box.get(AppConstants.keyLastPosition) as int?;
  Future<void> setLastPosition(int? position) =>
      set(AppConstants.keyLastPosition, position);

  /// Whether crossfade is enabled.
  bool get crossfadeEnabled =>
      get<bool>(AppConstants.keyCrossfadeEnabled, false);
  Future<void> setCrossfadeEnabled(bool enabled) =>
      set(AppConstants.keyCrossfadeEnabled, enabled);

  /// Crossfade duration in milliseconds.
  int get crossfadeDuration =>
      get<int>(AppConstants.keyCrossfadeDuration, AppConstants.crossfadeDurationMs);
  Future<void> setCrossfadeDuration(int durationMs) =>
      set(AppConstants.keyCrossfadeDuration, durationMs);

  /// Whether gapless playback is enabled.
  bool get gaplessEnabled => get<bool>(AppConstants.keyGaplessEnabled, true);
  Future<void> setGaplessEnabled(bool enabled) =>
      set(AppConstants.keyGaplessEnabled, enabled);

  /// Gets the sort field preference.
  int get sortBy => get<int>(AppConstants.keySortBy, 0);
  Future<void> setSortBy(int sortByIndex) => set(AppConstants.keySortBy, sortByIndex);

  /// Gets the sort order preference.
  int get sortOrder => get<int>(AppConstants.keySortOrder, 0);
  Future<void> setSortOrder(int sortOrderIndex) =>
      set(AppConstants.keySortOrder, sortOrderIndex);

  /// Returns all settings as a map (for backup).
  Map<String, dynamic> exportAll() {
    final map = <String, dynamic>{};
    for (final key in _box.keys) {
      map[key.toString()] = _box.get(key);
    }
    return map;
  }

  /// Imports settings from a map (for restore).
  Future<void> importAll(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  /// Clears all settings.
  Future<void> clear() async {
    await _box.clear();
  }
}
