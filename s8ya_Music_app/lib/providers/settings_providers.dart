import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/settings_repository.dart';
import '../models/settings_model.dart';

/// Provider for the settings repository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

/// Provider for the current settings snapshot.
final settingsProvider = Provider<SettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});
