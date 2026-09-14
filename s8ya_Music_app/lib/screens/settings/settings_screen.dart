import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/helpers/file_helper.dart';
import '../../core/services/storage_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/song_providers.dart';
import '../../providers/scanner_providers.dart';

/// Settings screen with appearance, playback, and data management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final statsAsync = ref.watch(libraryStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: const Text(AppStrings.settings)),
          SliverList(
            delegate: SliverChildListDelegate([
              // --- Appearance ---
              _SectionTitle(AppStrings.theme),
              // Theme mode
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text(AppStrings.theme),
                subtitle: Text(_themeModeLabel(themeState.themeMode)),
                onTap: () => _showThemeDialog(context, ref),
              ),
              // AMOLED
              SwitchListTile(
                secondary: const Icon(Icons.contrast_rounded),
                title: const Text(AppStrings.amoledMode),
                subtitle: const Text('Pure black background'),
                value: themeState.isAmoled,
                onChanged: (_) => themeNotifier.toggleAmoled(),
              ),
              // Accent color
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text(AppStrings.accentColor),
                trailing: CircleAvatar(
                  radius: 14,
                  backgroundColor: themeState.accentColor,
                ),
                onTap: () => _showColorPicker(context, ref),
              ),
              const Divider(),

              // --- Playback ---
              _SectionTitle(AppStrings.playback),
              SwitchListTile(
                secondary: const Icon(Icons.graphic_eq_rounded),
                title: const Text(AppStrings.crossfade),
                subtitle: const Text('Blend between tracks'),
                value: false, // TODO: Wire to settings
                onChanged: (_) {},
              ),
              SwitchListTile(
                secondary: const Icon(Icons.music_note_rounded),
                title: const Text(AppStrings.gaplessPlayback),
                subtitle: const Text('Seamless track transitions'),
                value: true,
                onChanged: (_) {},
              ),
              const Divider(),

              // --- Library ---
              _SectionTitle(AppStrings.library),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text(AppStrings.scanDevice),
                subtitle: const Text('Scan for new music files'),
                onTap: () async {
                  await ref.read(scanProgressProvider.notifier).startScan();
                  ref.invalidate(songsProvider);
                  if (context.mounted) {
                    context.showSnackBar(AppStrings.scanComplete);
                  }
                },
              ),
              const Divider(),

              // --- Data ---
              _SectionTitle(AppStrings.backupRestore),
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded),
                title: const Text(AppStrings.clearCache),
                subtitle: FutureBuilder<int>(
                  future: StorageService.instance.getCacheSize(),
                  builder: (ctx, snapshot) {
                    final size = snapshot.data ?? 0;
                    return Text('${FileHelper.formatSize(size)} cached');
                  },
                ),
                onTap: () async {
                  await StorageService.instance.clearAllCache();
                  if (context.mounted) {
                    context.showSnackBar('Cache cleared');
                  }
                },
              ),
              const Divider(),

              // --- Statistics ---
              _SectionTitle(AppStrings.statistics),
              statsAsync.when(
                data: (stats) {
                  final totalSongs = stats['totalSongs'] ?? 0;
                  final totalArtists = stats['totalArtists'] ?? 0;
                  final totalAlbums = stats['totalAlbums'] ?? 0;
                  final totalPlayCount = stats['totalPlayCount'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatChip(Icons.music_note_rounded, '$totalSongs', AppStrings.songs),
                        _StatChip(Icons.person_rounded, '$totalArtists', AppStrings.artists),
                        _StatChip(Icons.album_rounded, '$totalAlbums', AppStrings.albums),
                        _StatChip(Icons.play_arrow_rounded, '$totalPlayCount', 'Plays'),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Divider(),

              // --- About ---
              _SectionTitle(AppStrings.about),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text(AppStrings.appName),
                subtitle: Text('Version ${AppConstants.appVersion}'),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppStrings.lightMode;
      case ThemeMode.dark:
        return AppStrings.darkMode;
      case ThemeMode.system:
        return AppStrings.systemTheme;
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    final current = ref.read(themeProvider).themeMode;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(AppStrings.theme),
        children: [
          RadioListTile<ThemeMode>(
            title: const Text(AppStrings.systemTheme),
            value: ThemeMode.system,
            groupValue: current,
            onChanged: (v) {
              if (v != null) notifier.setThemeMode(v);
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text(AppStrings.lightMode),
            value: ThemeMode.light,
            groupValue: current,
            onChanged: (v) {
              if (v != null) notifier.setThemeMode(v);
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text(AppStrings.darkMode),
            value: ThemeMode.dark,
            groupValue: current,
            onChanged: (v) {
              if (v != null) notifier.setThemeMode(v);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    final current = ref.read(themeProvider).accentColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.accentColor),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppColors.accentColors.map((color) {
            final isSelected = color.toARGB32() == current.toARGB32();
            return GestureDetector(
              onTap: () {
                notifier.setAccentColor(color);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Theme.of(ctx).colorScheme.onSurface, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$value $label'),
    );
  }
}
