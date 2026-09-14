import 'package:sqflite/sqflite.dart';
import '../../core/helpers/logger.dart';
import '../../models/song_model.dart';
import '../../models/enums.dart';
import '../database_helper.dart';

/// Data Access Object for song operations.
///
/// Provides all CRUD and query operations for the songs table,
/// optimized with batch operations and proper indexing.
class SongDao {
  SongDao._();
  static final SongDao instance = SongDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Inserts a single song. Uses REPLACE to handle duplicates by path.
  Future<int> insert(SongModel song) async {
    try {
      final db = await _db;
      return await db.insert(
        'songs',
        song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, st) {
      Logger.error('Failed to insert song: ${song.title}', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Inserts multiple songs in a single transaction for performance.
  Future<void> insertBatch(List<SongModel> songs) async {
    if (songs.isEmpty) return;

    try {
      final db = await _db;
      final batch = db.batch();

      for (final song in songs) {
        batch.insert(
          'songs',
          song.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      Logger.info('Batch inserted ${songs.length} songs', tag: 'SongDao');
    } catch (e, st) {
      Logger.error('Failed to batch insert songs', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Updates an existing song.
  Future<int> update(SongModel song) async {
    final db = await _db;
    return db.update('songs', song.toMap(), where: 'id = ?', whereArgs: [song.id]);
  }

  /// Deletes a song by ID.
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes multiple songs by their IDs.
  Future<void> deleteBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete('songs', where: 'id IN ($placeholders)', whereArgs: ids);
  }

  /// Returns all songs, sorted by the given criteria.
  Future<List<SongModel>> getAll({
    SortBy sortBy = SortBy.title,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    final db = await _db;
    final orderDir = sortOrder == SortOrder.ascending ? 'ASC' : 'DESC';
    final column = sortBy.columnName;

    // Use COLLATE NOCASE for text columns
    final collate = (sortBy == SortBy.title || sortBy == SortBy.artist || sortBy == SortBy.album)
        ? 'COLLATE NOCASE'
        : '';

    final maps = await db.query(
      'songs',
      orderBy: '$column $collate $orderDir',
    );

    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns a song by its ID.
  Future<SongModel?> getById(int id) async {
    final db = await _db;
    final maps = await db.query('songs', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return SongModel.fromMap(maps.first);
  }

  /// Returns a song by its file path.
  Future<SongModel?> getByPath(String path) async {
    final db = await _db;
    final maps = await db.query('songs', where: 'path = ?', whereArgs: [path], limit: 1);
    if (maps.isEmpty) return null;
    return SongModel.fromMap(maps.first);
  }

  /// Returns all favorite songs.
  Future<List<SongModel>> getFavorites({
    SortBy sortBy = SortBy.title,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    final db = await _db;
    final orderDir = sortOrder == SortOrder.ascending ? 'ASC' : 'DESC';
    final maps = await db.query(
      'songs',
      where: 'favorite = 1',
      orderBy: '${sortBy.columnName} $orderDir',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns recently played songs with timestamps.
  Future<List<SongModel>> getRecentlyPlayed({int limit = 30}) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT s.*, rp.playedAt as recentPlayedAt
      FROM songs s
      INNER JOIN (
        SELECT songId, MAX(playedAt) as playedAt
        FROM recently_played
        GROUP BY songId
      ) rp ON s.id = rp.songId
      ORDER BY rp.playedAt DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns the most played songs.
  Future<List<SongModel>> getMostPlayed({int limit = 25}) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'playCount > 0',
      orderBy: 'playCount DESC',
      limit: limit,
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns recently added songs.
  Future<List<SongModel>> getRecentlyAdded({int limit = 20}) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      orderBy: 'dateAdded DESC',
      limit: limit,
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns songs that have never been played.
  Future<List<SongModel>> getNeverPlayed() async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'playCount = 0',
      orderBy: 'dateAdded DESC',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Searches songs across title, artist, album, genre, and filename.
  Future<List<SongModel>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final db = await _db;
    final searchTerm = '%${query.trim()}%';
    final maps = await db.query(
      'songs',
      where: '''
        title LIKE ? OR
        artist LIKE ? OR
        album LIKE ? OR
        genre LIKE ? OR
        path LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm],
      orderBy: 'title COLLATE NOCASE ASC',
      limit: 50,
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns all songs by a specific artist.
  Future<List<SongModel>> getByArtist(String artist) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'artist = ?',
      whereArgs: [artist],
      orderBy: 'album COLLATE NOCASE ASC, trackNo ASC, title COLLATE NOCASE ASC',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns all songs in a specific album.
  Future<List<SongModel>> getByAlbum(String album) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'album = ?',
      whereArgs: [album],
      orderBy: 'discNo ASC, trackNo ASC',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns all songs of a specific genre.
  Future<List<SongModel>> getByGenre(String genre) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'genre = ?',
      whereArgs: [genre],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns all songs in a specific folder.
  Future<List<SongModel>> getByFolder(String folderPath) async {
    final db = await _db;
    final maps = await db.query(
      'songs',
      where: 'path LIKE ?',
      whereArgs: ['$folderPath%'],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return maps.map(SongModel.fromMap).toList();
  }

  /// Returns a distinct list of all artist names.
  Future<List<String>> getAllArtists() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT DISTINCT artist, COUNT(*) as count
      FROM songs
      GROUP BY artist
      ORDER BY artist COLLATE NOCASE ASC
    ''');
    return maps.map((m) => m['artist'] as String).toList();
  }

  /// Returns a distinct list of all album names with their artists.
  Future<List<Map<String, dynamic>>> getAllAlbums() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT album, artist, COUNT(*) as songCount,
             SUM(duration) as totalDuration,
             MIN(id) as firstSongId
      FROM songs
      GROUP BY album, artist
      ORDER BY album COLLATE NOCASE ASC
    ''');
  }

  /// Returns a distinct list of all genres with song counts.
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT genre, COUNT(*) as songCount
      FROM songs
      GROUP BY genre
      ORDER BY genre COLLATE NOCASE ASC
    ''');
  }

  /// Returns a distinct list of all folders containing songs.
  Future<List<Map<String, dynamic>>> getAllFolders() async {
    final db = await _db;
    // Extract folder path (everything before the last /)
    return db.rawQuery('''
      SELECT
        SUBSTR(path, 1, LENGTH(path) - LENGTH(REPLACE(SUBSTR(path, INSTR(path, '/')), '/', ''))) as folder,
        COUNT(*) as songCount
      FROM songs
      GROUP BY folder
      ORDER BY folder ASC
    ''');
  }

  /// Toggles the favorite status of a song.
  Future<bool> toggleFavorite(int songId) async {
    final db = await _db;
    final song = await getById(songId);
    if (song == null) return false;

    final newFavorite = song.favorite ? 0 : 1;
    await db.update(
      'songs',
      {'favorite': newFavorite},
      where: 'id = ?',
      whereArgs: [songId],
    );
    return newFavorite == 1;
  }

  /// Increments the play count and updates last played time.
  Future<void> incrementPlayCount(int songId) async {
    final db = await _db;
    await db.rawUpdate('''
      UPDATE songs
      SET playCount = playCount + 1,
          lastPlayed = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, songId]);
  }

  /// Returns library statistics.
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as totalSongs,
        COUNT(DISTINCT artist) as totalArtists,
        COUNT(DISTINCT album) as totalAlbums,
        COUNT(DISTINCT genre) as totalGenres,
        SUM(duration) as totalDuration,
        SUM(playCount) as totalPlayCount,
        COUNT(CASE WHEN favorite = 1 THEN 1 END) as totalFavorites
      FROM songs
    ''');
    return result.first;
  }

  /// Returns the total count of songs.
  Future<int> getCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns all existing song paths for duplicate/deletion detection.
  Future<Set<String>> getAllPaths() async {
    final db = await _db;
    final maps = await db.query('songs', columns: ['path']);
    return maps.map((m) => m['path'] as String).toSet();
  }

  /// Removes songs whose files no longer exist on disk.
  Future<int> removeDeletedSongs(List<String> deletedPaths) async {
    if (deletedPaths.isEmpty) return 0;

    final db = await _db;
    int deletedCount = 0;

    // Delete in batches of 100 to avoid SQL parameter limit
    for (int i = 0; i < deletedPaths.length; i += 100) {
      final batch = deletedPaths.skip(i).take(100).toList();
      final placeholders = List.filled(batch.length, '?').join(',');
      deletedCount += await db.delete(
        'songs',
        where: 'path IN ($placeholders)',
        whereArgs: batch,
      );
    }

    Logger.info('Removed $deletedCount deleted songs', tag: 'SongDao');
    return deletedCount;
  }
}
