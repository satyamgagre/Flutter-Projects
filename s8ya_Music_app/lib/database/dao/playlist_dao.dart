import 'package:sqflite/sqflite.dart';
import '../../models/playlist_model.dart';
import '../../models/song_model.dart';
import '../database_helper.dart';

/// Data Access Object for playlist operations.
///
/// Handles CRUD for playlists and the playlist-song junction table.
class PlaylistDao {
  PlaylistDao._();
  static final PlaylistDao instance = PlaylistDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Creates a new playlist and returns its ID.
  Future<int> create(String name) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert('playlists', {
      'name': name,
      'isPinned': 0,
      'createdDate': now,
      'updatedDate': now,
    });
  }

  /// Returns all playlists with song counts and total duration.
  Future<List<PlaylistModel>> getAll() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*,
             COALESCE(ps.songCount, 0) as songCount,
             COALESCE(ps.totalDuration, 0) as totalDuration
      FROM playlists p
      LEFT JOIN (
        SELECT playlistId,
               COUNT(*) as songCount,
               SUM(s.duration) as totalDuration
        FROM playlist_songs ps2
        JOIN songs s ON ps2.songId = s.id
        GROUP BY playlistId
      ) ps ON p.id = ps.playlistId
      ORDER BY p.isPinned DESC, p.updatedDate DESC
    ''');
    return maps.map(PlaylistModel.fromMap).toList();
  }

  /// Returns a single playlist by ID.
  Future<PlaylistModel?> getById(int id) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*,
             COALESCE(ps.songCount, 0) as songCount,
             COALESCE(ps.totalDuration, 0) as totalDuration
      FROM playlists p
      LEFT JOIN (
        SELECT playlistId,
               COUNT(*) as songCount,
               SUM(s.duration) as totalDuration
        FROM playlist_songs ps2
        JOIN songs s ON ps2.songId = s.id
        GROUP BY playlistId
      ) ps ON p.id = ps.playlistId
      WHERE p.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return PlaylistModel.fromMap(maps.first);
  }

  /// Renames a playlist.
  Future<void> rename(int id, String newName) async {
    final db = await _db;
    await db.update(
      'playlists',
      {'name': newName, 'updatedDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a playlist (cascade deletes playlist_songs entries).
  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  /// Toggles the pinned state of a playlist.
  Future<void> togglePin(int id) async {
    final db = await _db;
    await db.rawUpdate('''
      UPDATE playlists SET isPinned = CASE WHEN isPinned = 1 THEN 0 ELSE 1 END,
                           updatedDate = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, id]);
  }

  /// Adds a song to a playlist.
  Future<void> addSong(int playlistId, int songId) async {
    final db = await _db;

    // Get the next position
    final maxPos = await db.rawQuery(
      'SELECT MAX(position) as maxPos FROM playlist_songs WHERE playlistId = ?',
      [playlistId],
    );
    final nextPosition = ((maxPos.first['maxPos'] as int?) ?? -1) + 1;

    await db.insert(
      'playlist_songs',
      {
        'playlistId': playlistId,
        'songId': songId,
        'position': nextPosition,
        'addedDate': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Update playlist timestamp
    await db.update(
      'playlists',
      {'updatedDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Adds multiple songs to a playlist.
  Future<void> addSongs(int playlistId, List<int> songIds) async {
    if (songIds.isEmpty) return;

    final db = await _db;
    final maxPos = await db.rawQuery(
      'SELECT MAX(position) as maxPos FROM playlist_songs WHERE playlistId = ?',
      [playlistId],
    );
    int position = ((maxPos.first['maxPos'] as int?) ?? -1) + 1;

    final batch = db.batch();
    for (final songId in songIds) {
      batch.insert(
        'playlist_songs',
        {
          'playlistId': playlistId,
          'songId': songId,
          'position': position++,
          'addedDate': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);

    await db.update(
      'playlists',
      {'updatedDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Removes a song from a playlist.
  Future<void> removeSong(int playlistId, int songId) async {
    final db = await _db;
    await db.delete(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );
    await db.update(
      'playlists',
      {'updatedDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Returns all songs in a playlist, ordered by position.
  Future<List<SongModel>> getSongs(int playlistId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT s.*
      FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.songId
      WHERE ps.playlistId = ?
      ORDER BY ps.position ASC
    ''', [playlistId]);
    return maps.map(SongModel.fromMap).toList();
  }

  /// Reorders songs in a playlist.
  Future<void> reorderSongs(int playlistId, List<int> songIds) async {
    final db = await _db;
    final batch = db.batch();
    for (int i = 0; i < songIds.length; i++) {
      batch.update(
        'playlist_songs',
        {'position': i},
        where: 'playlistId = ? AND songId = ?',
        whereArgs: [playlistId, songIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Checks if a song is in a specific playlist.
  Future<bool> containsSong(int playlistId, int songId) async {
    final db = await _db;
    final result = await db.query(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
