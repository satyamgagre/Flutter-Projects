import 'package:sqflite/sqflite.dart';
import '../../models/queue_item_model.dart';
import '../../models/song_model.dart';
import '../database_helper.dart';

/// Data Access Object for the playback queue.
///
/// Persists the current queue to SQLite so it survives app restarts.
class QueueDao {
  QueueDao._();
  static final QueueDao instance = QueueDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Saves the current queue (replaces any existing queue).
  Future<void> saveQueue(List<QueueItemModel> items) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('queue');
      final batch = txn.batch();
      for (final item in items) {
        batch.insert('queue', item.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Loads the persisted queue.
  Future<List<QueueItemModel>> loadQueue() async {
    final db = await _db;
    final maps = await db.query('queue', orderBy: 'position ASC');
    return maps.map(QueueItemModel.fromMap).toList();
  }

  /// Returns the songs in the persisted queue.
  Future<List<SongModel>> loadQueueSongs() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT s.*
      FROM songs s
      INNER JOIN queue q ON s.id = q.songId
      ORDER BY q.position ASC
    ''');
    return maps.map(SongModel.fromMap).toList();
  }

  /// Clears the persisted queue.
  Future<void> clearQueue() async {
    final db = await _db;
    await db.delete('queue');
  }
}
