import 'package:sqflite/sqflite.dart';
import '../../models/recently_played_model.dart';
import '../database_helper.dart';

/// Data Access Object for recently played tracks.
class RecentlyPlayedDao {
  RecentlyPlayedDao._();
  static final RecentlyPlayedDao instance = RecentlyPlayedDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Records a song as recently played.
  Future<void> add(int songId) async {
    final db = await _db;
    await db.insert('recently_played', {
      'songId': songId,
      'playedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // Keep only the last 500 entries to prevent table bloat
    await db.rawDelete('''
      DELETE FROM recently_played
      WHERE id NOT IN (
        SELECT id FROM recently_played
        ORDER BY playedAt DESC
        LIMIT 500
      )
    ''');
  }

  /// Returns recently played entries.
  Future<List<RecentlyPlayedModel>> getAll({int limit = 30}) async {
    final db = await _db;
    final maps = await db.query(
      'recently_played',
      orderBy: 'playedAt DESC',
      limit: limit,
    );
    return maps.map(RecentlyPlayedModel.fromMap).toList();
  }

  /// Clears all recently played history.
  Future<void> clear() async {
    final db = await _db;
    await db.delete('recently_played');
  }

  /// Returns the total listening time today in milliseconds.
  Future<int> getTodayListeningTime() async {
    final db = await _db;
    final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0,
    ).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT SUM(s.duration) as total
      FROM recently_played rp
      JOIN songs s ON rp.songId = s.id
      WHERE rp.playedAt >= ?
    ''', [todayStart]);

    return (result.first['total'] as int?) ?? 0;
  }

  /// Returns weekly listening stats (song count per day).
  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final db = await _db;
    final weekAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .millisecondsSinceEpoch;

    return db.rawQuery('''
      SELECT
        DATE(playedAt / 1000, 'unixepoch', 'localtime') as date,
        COUNT(*) as playCount,
        SUM(s.duration) as totalDuration
      FROM recently_played rp
      JOIN songs s ON rp.songId = s.id
      WHERE rp.playedAt >= ?
      GROUP BY date
      ORDER BY date ASC
    ''', [weekAgo]);
  }
}
