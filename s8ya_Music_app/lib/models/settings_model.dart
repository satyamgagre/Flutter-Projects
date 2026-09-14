import 'package:flutter/material.dart';
import 'enums.dart' as app;

/// Represents the complete application settings state.
///
/// Persisted to Hive for fast read/write access.
class SettingsModel {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool isAmoled;
  final app.ShuffleMode shuffleMode;
  final app.RepeatMode repeatMode;
  final double playbackSpeed;
  final double pitch;
  final bool crossfadeEnabled;
  final int crossfadeDurationMs;
  final bool gaplessEnabled;
  final app.SortBy sortBy;
  final app.SortOrder sortOrder;
  final int? lastSongId;
  final int? lastPositionMs;
  final List<String> scannedFolders;
  final int? lastScanTime;

  const SettingsModel({
    this.themeMode = ThemeMode.system,
    this.accentColor = const Color(0xFF6750A4),
    this.isAmoled = false,
    this.shuffleMode = app.ShuffleMode.off,
    this.repeatMode = app.RepeatMode.off,
    this.playbackSpeed = 1.0,
    this.pitch = 1.0,
    this.crossfadeEnabled = false,
    this.crossfadeDurationMs = 5000,
    this.gaplessEnabled = true,
    this.sortBy = app.SortBy.title,
    this.sortOrder = app.SortOrder.ascending,
    this.lastSongId,
    this.lastPositionMs,
    this.scannedFolders = const [],
    this.lastScanTime,
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? isAmoled,
    app.ShuffleMode? shuffleMode,
    app.RepeatMode? repeatMode,
    double? playbackSpeed,
    double? pitch,
    bool? crossfadeEnabled,
    int? crossfadeDurationMs,
    bool? gaplessEnabled,
    app.SortBy? sortBy,
    app.SortOrder? sortOrder,
    int? lastSongId,
    int? lastPositionMs,
    List<String>? scannedFolders,
    int? lastScanTime,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      isAmoled: isAmoled ?? this.isAmoled,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      pitch: pitch ?? this.pitch,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDurationMs: crossfadeDurationMs ?? this.crossfadeDurationMs,
      gaplessEnabled: gaplessEnabled ?? this.gaplessEnabled,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      lastSongId: lastSongId ?? this.lastSongId,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      scannedFolders: scannedFolders ?? this.scannedFolders,
      lastScanTime: lastScanTime ?? this.lastScanTime,
    );
  }
}
