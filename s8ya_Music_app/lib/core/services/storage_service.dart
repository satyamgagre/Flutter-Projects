import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../helpers/logger.dart';

/// Service for managing application file storage paths.
///
/// Provides abstracted access to platform-specific directories:
/// - Application documents directory (persistent data)
/// - Application cache directory (temporary data)
/// - Album art cache directory
/// - Backup directory
/// - Lyrics directory
class StorageService {
  StorageService._();

  /// Singleton instance.
  static final StorageService instance = StorageService._();

  Directory? _appDocDir;
  Directory? _cacheDir;
  Directory? _artworkDir;
  Directory? _backupDir;
  Directory? _lyricsDir;

  /// Initializes storage directories.
  ///
  /// Creates required subdirectories if they don't exist.
  /// Should be called during app startup.
  Future<void> initialize() async {
    try {
      _appDocDir = await getApplicationDocumentsDirectory();
      _cacheDir = await getTemporaryDirectory();

      // Create subdirectories
      _artworkDir = Directory('${_cacheDir!.path}/artwork');
      _backupDir = Directory('${_appDocDir!.path}/backups');
      _lyricsDir = Directory('${_appDocDir!.path}/lyrics');

      await Future.wait([
        _artworkDir!.create(recursive: true),
        _backupDir!.create(recursive: true),
        _lyricsDir!.create(recursive: true),
      ]);

      Logger.info('Storage directories initialized', tag: 'Storage');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize storage',
        tag: 'Storage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns the application documents directory.
  Directory get appDocDir {
    if (_appDocDir == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _appDocDir!;
  }

  /// Returns the application cache directory.
  Directory get cacheDir {
    if (_cacheDir == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _cacheDir!;
  }

  /// Returns the artwork cache directory.
  Directory get artworkDir {
    if (_artworkDir == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _artworkDir!;
  }

  /// Returns the backup directory.
  Directory get backupDir {
    if (_backupDir == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _backupDir!;
  }

  /// Returns the lyrics directory.
  Directory get lyricsDir {
    if (_lyricsDir == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _lyricsDir!;
  }

  /// Returns the path for cached artwork for a given song ID.
  String artworkPath(int songId) {
    return '${artworkDir.path}/art_$songId.jpg';
  }

  /// Checks if cached artwork exists for a song.
  bool hasArtwork(int songId) {
    return File(artworkPath(songId)).existsSync();
  }

  /// Clears the artwork cache.
  Future<void> clearArtworkCache() async {
    try {
      if (await artworkDir.exists()) {
        await artworkDir.delete(recursive: true);
        await artworkDir.create(recursive: true);
      }
      Logger.info('Artwork cache cleared', tag: 'Storage');
    } catch (e) {
      Logger.error('Failed to clear artwork cache', error: e);
    }
  }

  /// Clears all cached data.
  Future<void> clearAllCache() async {
    try {
      if (await cacheDir.exists()) {
        final entities = await cacheDir.list().toList();
        for (final entity in entities) {
          await entity.delete(recursive: true);
        }
      }
      // Recreate artwork dir
      await artworkDir.create(recursive: true);
      Logger.info('All cache cleared', tag: 'Storage');
    } catch (e) {
      Logger.error('Failed to clear cache', error: e);
    }
  }

  /// Returns the total size of cached data in bytes.
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      Logger.error('Failed to calculate cache size', error: e);
      return 0;
    }
  }
}
