import 'dart:convert';
import 'dart:io';
import '../helpers/logger.dart';
import 'storage_service.dart';
import '../../database/dao/song_dao.dart';
import '../../database/dao/playlist_dao.dart';
import '../../database/hive/settings_box.dart';

/// Service for backing up and restoring app data.
///
/// Supports:
/// - Export playlists, favorites, and settings to JSON
/// - Import from backup files
/// - Automatic backup scheduling (future)
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  /// Creates a full backup of playlists, favorites, and settings.
  ///
  /// Returns the path to the backup file.
  Future<String> createBackup() async {
    try {
      final storageService = StorageService.instance;
      final songDao = SongDao.instance;
      final playlistDao = PlaylistDao.instance;
      final settingsBox = SettingsBox.instance;

      // Gather data
      final favorites = await songDao.getFavorites();
      final playlists = await playlistDao.getAll();
      final playlistsWithSongs = <Map<String, dynamic>>[];

      for (final playlist in playlists) {
        final songs = await playlistDao.getSongs(playlist.id);
        playlistsWithSongs.add({
          'name': playlist.name,
          'isPinned': playlist.isPinned,
          'songs': songs.map((s) => {
            'title': s.title,
            'artist': s.artist,
            'album': s.album,
            'path': s.path,
            'duration': s.duration,
          }).toList(),
        });
      }

      final backupData = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'S8YA',
        'favorites': favorites.map((s) => {
          'title': s.title,
          'artist': s.artist,
          'album': s.album,
          'path': s.path,
        }).toList(),
        'playlists': playlistsWithSongs,
        'settings': settingsBox.exportAll(),
      };

      final fileName = 's8ya_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${storageService.backupDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      Logger.info('Backup created: $filePath', tag: 'Backup');
      return filePath;
    } catch (e, st) {
      Logger.error('Failed to create backup', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Restores data from a backup file.
  ///
  /// Restores playlists, favorites, and settings.
  /// Existing data is preserved — playlists are merged.
  Future<BackupRestoreResult> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Validate backup
      if (data['app'] != 'S8YA') {
        throw Exception('Invalid backup file');
      }

      int playlistsRestored = 0;
      int favoritesRestored = 0;

      // Restore playlists
      final playlists = data['playlists'] as List<dynamic>? ?? [];
      final playlistDao = PlaylistDao.instance;

      for (final playlistData in playlists) {
        try {
          final name = playlistData['name'] as String;
          await playlistDao.create(name);
          playlistsRestored++;
        } catch (e) {
          Logger.warning('Failed to restore playlist: ${playlistData['name']}');
        }
      }

      // Restore favorites
      final favorites = data['favorites'] as List<dynamic>? ?? [];
      final songDao = SongDao.instance;

      for (final favData in favorites) {
        try {
          final path = favData['path'] as String;
          final song = await songDao.getByPath(path);
          if (song != null && !song.favorite) {
            await songDao.toggleFavorite(song.id);
            favoritesRestored++;
          }
        } catch (e) {
          // Song may not exist on this device
          Logger.warning('Failed to restore favorite: ${favData['path']}');
        }
      }

      // Restore settings
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        await SettingsBox.instance.importAll(settings);
      }

      Logger.info(
        'Backup restored: $playlistsRestored playlists, $favoritesRestored favorites',
        tag: 'Backup',
      );

      return BackupRestoreResult(
        playlistsRestored: playlistsRestored,
        favoritesRestored: favoritesRestored,
        settingsRestored: settings != null,
      );
    } catch (e, st) {
      Logger.error('Failed to restore backup', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Lists available backup files.
  Future<List<FileSystemEntity>> listBackups() async {
    try {
      final backupDir = StorageService.instance.backupDir;
      if (!await backupDir.exists()) return [];

      final files = await backupDir
          .list()
          .where((e) => e.path.endsWith('.json'))
          .toList();

      files.sort((a, b) => b.path.compareTo(a.path));
      return files;
    } catch (e) {
      Logger.error('Failed to list backups', error: e);
      return [];
    }
  }

  /// Deletes a backup file.
  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        Logger.info('Deleted backup: $filePath', tag: 'Backup');
      }
    } catch (e) {
      Logger.error('Failed to delete backup', error: e);
    }
  }
}

/// Result of a backup restore operation.
class BackupRestoreResult {
  final int playlistsRestored;
  final int favoritesRestored;
  final bool settingsRestored;

  const BackupRestoreResult({
    this.playlistsRestored = 0,
    this.favoritesRestored = 0,
    this.settingsRestored = false,
  });

  @override
  String toString() {
    return 'Restored: $playlistsRestored playlists, $favoritesRestored favorites, settings: $settingsRestored';
  }
}
