import '../database/dao/queue_dao.dart';
import '../models/queue_item_model.dart';
import '../models/song_model.dart';
import '../core/helpers/logger.dart';

/// Repository for queue persistence.
abstract class QueueRepository {
  Future<void> saveQueue(List<SongModel> songs);
  Future<List<SongModel>> loadQueue();
  Future<void> clearQueue();
}

/// Implementation of [QueueRepository] using QueueDao.
class QueueRepositoryImpl implements QueueRepository {
  final QueueDao _dao;

  QueueRepositoryImpl({QueueDao? dao}) : _dao = dao ?? QueueDao.instance;

  @override
  Future<void> saveQueue(List<SongModel> songs) async {
    try {
      final items = List.generate(
        songs.length,
        (i) => QueueItemModel(songId: songs[i].id, position: i),
      );
      await _dao.saveQueue(items);
      Logger.debug('Saved queue with ${songs.length} songs', tag: 'Queue');
    } catch (e) {
      Logger.error('Failed to save queue', error: e);
    }
  }

  @override
  Future<List<SongModel>> loadQueue() async {
    try {
      return await _dao.loadQueueSongs();
    } catch (e) {
      Logger.error('Failed to load queue', error: e);
      return [];
    }
  }

  @override
  Future<void> clearQueue() async {
    try {
      await _dao.clearQueue();
    } catch (e) {
      Logger.error('Failed to clear queue', error: e);
    }
  }
}
