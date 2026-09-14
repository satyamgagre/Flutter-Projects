import '../database/hive/settings_box.dart';
import '../models/enums.dart' as app;
import '../models/settings_model.dart';
import '../core/constants/app_constants.dart';

/// Repository for application settings.
abstract class SettingsRepository {
  SettingsModel getSettings();
  Future<void> setShuffleMode(app.ShuffleMode mode);
  Future<void> setRepeatMode(app.RepeatMode mode);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setLastSong(int songId, int positionMs);
  (int?, int?) getLastSong();
  Future<void> setCrossfade(bool enabled, {int? durationMs});
  Future<void> setGapless(bool enabled);
  Future<void> setSortPreference(app.SortBy sortBy, app.SortOrder sortOrder);
  Future<void> clearAll();
  Map<String, dynamic> exportSettings();
  Future<void> importSettings(Map<String, dynamic> data);
}

/// Implementation of [SettingsRepository] using Hive.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsBox _box;

  SettingsRepositoryImpl({SettingsBox? box}) : _box = box ?? SettingsBox.instance;

  @override
  SettingsModel getSettings() {
    return SettingsModel(
      shuffleMode: app.ShuffleMode.values[_box.shuffleMode.clamp(0, app.ShuffleMode.values.length - 1)],
      repeatMode: app.RepeatMode.values[_box.repeatMode.clamp(0, app.RepeatMode.values.length - 1)],
      playbackSpeed: _box.playbackSpeed,
      crossfadeEnabled: _box.crossfadeEnabled,
      crossfadeDurationMs: _box.crossfadeDuration,
      gaplessEnabled: _box.gaplessEnabled,
      lastSongId: _box.lastSongId,
      lastPositionMs: _box.lastPosition,
      sortBy: app.SortBy.values[_box.sortBy.clamp(0, app.SortBy.values.length - 1)],
      sortOrder: app.SortOrder.values[_box.sortOrder.clamp(0, app.SortOrder.values.length - 1)],
    );
  }

  @override
  Future<void> setShuffleMode(app.ShuffleMode mode) async {
    await _box.setShuffleMode(mode.index);
  }

  @override
  Future<void> setRepeatMode(app.RepeatMode mode) async {
    await _box.setRepeatMode(mode.index);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _box.setPlaybackSpeed(
      speed.clamp(AppConstants.minPlaybackSpeed, AppConstants.maxPlaybackSpeed),
    );
  }

  @override
  Future<void> setLastSong(int songId, int positionMs) async {
    await Future.wait([
      _box.setLastSongId(songId),
      _box.setLastPosition(positionMs),
    ]);
  }

  @override
  (int?, int?) getLastSong() {
    return (_box.lastSongId, _box.lastPosition);
  }

  @override
  Future<void> setCrossfade(bool enabled, {int? durationMs}) async {
    await _box.setCrossfadeEnabled(enabled);
    if (durationMs != null) {
      await _box.setCrossfadeDuration(durationMs);
    }
  }

  @override
  Future<void> setGapless(bool enabled) async {
    await _box.setGaplessEnabled(enabled);
  }

  @override
  Future<void> setSortPreference(app.SortBy sortBy, app.SortOrder sortOrder) async {
    await Future.wait([
      _box.setSortBy(sortBy.index),
      _box.setSortOrder(sortOrder.index),
    ]);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  Map<String, dynamic> exportSettings() {
    return _box.exportAll();
  }

  @override
  Future<void> importSettings(Map<String, dynamic> data) async {
    await _box.importAll(data);
  }
}
