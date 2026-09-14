import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// State class holding the current theme configuration.
class ThemeState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool isAmoled;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.accentColor = const Color(0xFF6750A4),
    this.isAmoled = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? isAmoled,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      isAmoled: isAmoled ?? this.isAmoled,
    );
  }
}

/// Notifier that manages theme state and persists preferences to Hive.
///
/// Supports:
/// - Theme mode switching (light, dark, system)
/// - AMOLED mode toggle
/// - Accent color selection from predefined palette
class ThemeNotifier extends StateNotifier<ThemeState> {
  final Box<dynamic> _settingsBox;

  ThemeNotifier(this._settingsBox) : super(const ThemeState()) {
    _loadTheme();
  }

  /// Loads persisted theme preferences from Hive.
  void _loadTheme() {
    final themeModeIndex = _settingsBox.get(
      AppConstants.keyThemeMode,
      defaultValue: ThemeMode.system.index,
    ) as int;
    final accentColorValue = _settingsBox.get(
      AppConstants.keyAccentColor,
      defaultValue: AppColors.accentColors.first.toARGB32(),
    ) as int;
    final isAmoled = _settingsBox.get(
      AppConstants.keyIsAmoled,
      defaultValue: false,
    ) as bool;

    state = ThemeState(
      themeMode: ThemeMode.values[themeModeIndex],
      accentColor: Color(accentColorValue),
      isAmoled: isAmoled,
    );
  }

  /// Updates the current theme mode and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _settingsBox.put(AppConstants.keyThemeMode, mode.index);
  }

  /// Updates the accent color and persists the choice.
  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    await _settingsBox.put(AppConstants.keyAccentColor, color.toARGB32());
  }

  /// Toggles AMOLED mode and persists the choice.
  Future<void> toggleAmoled() async {
    final newValue = !state.isAmoled;
    state = state.copyWith(
      isAmoled: newValue,
      themeMode: newValue ? ThemeMode.dark : state.themeMode,
    );
    await _settingsBox.put(AppConstants.keyIsAmoled, newValue);
    if (newValue) {
      await _settingsBox.put(AppConstants.keyThemeMode, ThemeMode.dark.index);
    }
  }
}

/// Provider for the theme state, backed by Hive persistence.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final settingsBox = Hive.box<dynamic>(AppConstants.settingsBoxName);
  return ThemeNotifier(settingsBox);
});
