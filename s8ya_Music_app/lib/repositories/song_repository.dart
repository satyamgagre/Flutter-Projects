import '../database/dao/song_dao.dart';
import '../database/dao/recently_played_dao.dart';
import '../models/song_model.dart';
import '../models/enums.dart';
import '../core/helpers/logger.dart';

/// Repository for song-related operations.
///
/// Acts as the single source of truth for song data,
/// coordinating between the SongDao and RecentlyPlayedDao.
/// Follows the Repository Pattern to abstract data access.
abstract class SongRepository {
  Future<List<SongModel>> getAllSongs({SortBy sortBy, SortOrder sortOrder});
  Future<SongModel?> getSongById(int id);
  Future<List<SongModel>> searchSongs(String query);
  Future<List<SongModel>> getFavorites({SortBy sortBy, SortOrder sortOrder});
  Future<List<SongModel>> getRecentlyPlayed({int limit});
  Future<List<SongModel>> getMostPlayed({int limit});
  Future<List<SongModel>> getRecentlyAdded({int limit});
  Future<List<SongModel>> getNeverPlayed();
  Future<List<SongModel>> getSongsByArtist(String artist);
  Future<List<SongModel>> getSongsByAlbum(String album);
  Future<List<SongModel>> getSongsByGenre(String genre);
  Future<List<SongModel>> getSongsByFolder(String folderPath);
  Future<List<String>> getAllArtists();
  Future<List<Map<String, dynamic>>> getAllAlbums();
  Future<List<Map<String, dynamic>>> getAllGenres();
  Future<List<Map<String, dynamic>>> getAllFolders();
  Future<bool> toggleFavorite(int songId);
  Future<void> recordPlay(int songId);
  Future<void> updateSong(SongModel song);
  Future<void> deleteSong(int songId);
  Future<Map<String, dynamic>> getStatistics();
  Future<int> getSongCount();
}

/// Implementation of [SongRepository] using SQLite DAOs.
class SongRepositoryImpl implements SongRepository {
  final SongDao _songDao;
  final RecentlyPlayedDao _recentlyPlayedDao;

  SongRepositoryImpl({
    SongDao? songDao,
    RecentlyPlayedDao? recentlyPlayedDao,
  })  : _songDao = songDao ?? SongDao.instance,
        _recentlyPlayedDao = recentlyPlayedDao ?? RecentlyPlayedDao.instance;

  @override
  Future<List<SongModel>> getAllSongs({
    SortBy sortBy = SortBy.title,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    try {
      return await _songDao.getAll(sortBy: sortBy, sortOrder: sortOrder);
    } catch (e, st) {
      Logger.error('Failed to get all songs', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<SongModel?> getSongById(int id) async {
    try {
      return await _songDao.getById(id);
    } catch (e) {
      Logger.error('Failed to get song by id: $id', error: e);
      return null;
    }
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    try {
      return await _songDao.search(query);
    } catch (e) {
      Logger.error('Search failed for: $query', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getFavorites({
    SortBy sortBy = SortBy.title,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    try {
      return await _songDao.getFavorites(sortBy: sortBy, sortOrder: sortOrder);
    } catch (e) {
      Logger.error('Failed to get favorites', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getRecentlyPlayed({int limit = 30}) async {
    try {
      return await _songDao.getRecentlyPlayed(limit: limit);
    } catch (e) {
      Logger.error('Failed to get recently played', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getMostPlayed({int limit = 25}) async {
    try {
      return await _songDao.getMostPlayed(limit: limit);
    } catch (e) {
      Logger.error('Failed to get most played', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getRecentlyAdded({int limit = 20}) async {
    try {
      return await _songDao.getRecentlyAdded(limit: limit);
    } catch (e) {
      Logger.error('Failed to get recently added', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getNeverPlayed() async {
    try {
      return await _songDao.getNeverPlayed();
    } catch (e) {
      Logger.error('Failed to get never played', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getSongsByArtist(String artist) async {
    try {
      return await _songDao.getByArtist(artist);
    } catch (e) {
      Logger.error('Failed to get songs by artist: $artist', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getSongsByAlbum(String album) async {
    try {
      return await _songDao.getByAlbum(album);
    } catch (e) {
      Logger.error('Failed to get songs by album: $album', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getSongsByGenre(String genre) async {
    try {
      return await _songDao.getByGenre(genre);
    } catch (e) {
      Logger.error('Failed to get songs by genre: $genre', error: e);
      return [];
    }
  }

  @override
  Future<List<SongModel>> getSongsByFolder(String folderPath) async {
    try {
      return await _songDao.getByFolder(folderPath);
    } catch (e) {
      Logger.error('Failed to get songs by folder: $folderPath', error: e);
      return [];
    }
  }

  @override
  Future<List<String>> getAllArtists() async {
    try {
      return await _songDao.getAllArtists();
    } catch (e) {
      Logger.error('Failed to get all artists', error: e);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllAlbums() async {
    try {
      return await _songDao.getAllAlbums();
    } catch (e) {
      Logger.error('Failed to get all albums', error: e);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    try {
      return await _songDao.getAllGenres();
    } catch (e) {
      Logger.error('Failed to get all genres', error: e);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllFolders() async {
    try {
      return await _songDao.getAllFolders();
    } catch (e) {
      Logger.error('Failed to get all folders', error: e);
      return [];
    }
  }

  @override
  Future<bool> toggleFavorite(int songId) async {
    try {
      return await _songDao.toggleFavorite(songId);
    } catch (e) {
      Logger.error('Failed to toggle favorite for song: $songId', error: e);
      return false;
    }
  }

  @override
  Future<void> recordPlay(int songId) async {
    try {
      await Future.wait([
        _songDao.incrementPlayCount(songId),
        _recentlyPlayedDao.add(songId),
      ]);
    } catch (e) {
      Logger.error('Failed to record play for song: $songId', error: e);
    }
  }

  @override
  Future<void> updateSong(SongModel song) async {
    try {
      await _songDao.update(song);
    } catch (e) {
      Logger.error('Failed to update song: ${song.id}', error: e);
    }
  }

  @override
  Future<void> deleteSong(int songId) async {
    try {
      await _songDao.delete(songId);
    } catch (e) {
      Logger.error('Failed to delete song: $songId', error: e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _songDao.getStatistics();
    } catch (e) {
      Logger.error('Failed to get statistics', error: e);
      return {};
    }
  }

  @override
  Future<int> getSongCount() async {
    try {
      return await _songDao.getCount();
    } catch (e) {
      Logger.error('Failed to get song count', error: e);
      return 0;
    }
  }
}
