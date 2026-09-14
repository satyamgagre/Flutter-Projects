import 'dart:convert';
import 'dart:io';
import '../database/dao/playlist_dao.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../core/helpers/logger.dart';

/// Repository for playlist operations.
abstract class PlaylistRepository {
  Future<List<PlaylistModel>> getAllPlaylists();
  Future<PlaylistModel?> getPlaylistById(int id);
  Future<int> createPlaylist(String name);
  Future<void> renamePlaylist(int id, String newName);
  Future<void> deletePlaylist(int id);
  Future<void> togglePin(int id);
  Future<List<SongModel>> getPlaylistSongs(int playlistId);
  Future<void> addSongToPlaylist(int playlistId, int songId);
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds);
  Future<void> removeSongFromPlaylist(int playlistId, int songId);
  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds);
  Future<bool> playlistContainsSong(int playlistId, int songId);
  Future<String> exportPlaylist(int playlistId, String exportPath);
  Future<int> importPlaylist(String filePath);
}

/// Implementation of [PlaylistRepository] using PlaylistDao.
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistDao _dao;

  PlaylistRepositoryImpl({PlaylistDao? dao}) : _dao = dao ?? PlaylistDao.instance;

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    try {
      return await _dao.getAll();
    } catch (e) {
      Logger.error('Failed to get playlists', error: e);
      return [];
    }
  }

  @override
  Future<PlaylistModel?> getPlaylistById(int id) async {
    try {
      return await _dao.getById(id);
    } catch (e) {
      Logger.error('Failed to get playlist $id', error: e);
      return null;
    }
  }

  @override
  Future<int> createPlaylist(String name) async {
    try {
      final id = await _dao.create(name);
      Logger.info('Created playlist: $name (id: $id)', tag: 'Playlist');
      return id;
    } catch (e) {
      Logger.error('Failed to create playlist: $name', error: e);
      rethrow;
    }
  }

  @override
  Future<void> renamePlaylist(int id, String newName) async {
    try {
      await _dao.rename(id, newName);
    } catch (e) {
      Logger.error('Failed to rename playlist $id', error: e);
    }
  }

  @override
  Future<void> deletePlaylist(int id) async {
    try {
      await _dao.delete(id);
      Logger.info('Deleted playlist: $id', tag: 'Playlist');
    } catch (e) {
      Logger.error('Failed to delete playlist $id', error: e);
    }
  }

  @override
  Future<void> togglePin(int id) async {
    try {
      await _dao.togglePin(id);
    } catch (e) {
      Logger.error('Failed to toggle pin for playlist $id', error: e);
    }
  }

  @override
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    try {
      return await _dao.getSongs(playlistId);
    } catch (e) {
      Logger.error('Failed to get songs for playlist $playlistId', error: e);
      return [];
    }
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    try {
      await _dao.addSong(playlistId, songId);
    } catch (e) {
      Logger.error('Failed to add song $songId to playlist $playlistId', error: e);
    }
  }

  @override
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    try {
      await _dao.addSongs(playlistId, songIds);
    } catch (e) {
      Logger.error('Failed to add songs to playlist $playlistId', error: e);
    }
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await _dao.removeSong(playlistId, songId);
    } catch (e) {
      Logger.error('Failed to remove song $songId from playlist $playlistId', error: e);
    }
  }

  @override
  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds) async {
    try {
      await _dao.reorderSongs(playlistId, songIds);
    } catch (e) {
      Logger.error('Failed to reorder songs in playlist $playlistId', error: e);
    }
  }

  @override
  Future<bool> playlistContainsSong(int playlistId, int songId) async {
    try {
      return await _dao.containsSong(playlistId, songId);
    } catch (e) {
      Logger.error('Failed to check if song is in playlist', error: e);
      return false;
    }
  }

  @override
  Future<String> exportPlaylist(int playlistId, String exportPath) async {
    try {
      final playlist = await _dao.getById(playlistId);
      if (playlist == null) throw Exception('Playlist not found');

      final songs = await _dao.getSongs(playlistId);

      final exportData = {
        'playlist': playlist.toJson(),
        'songs': songs.map((s) => {
          'title': s.title,
          'artist': s.artist,
          'album': s.album,
          'path': s.path,
          'duration': s.duration,
        }).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      };

      final fileName = '${playlist.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.s8ya';
      final filePath = '$exportPath/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonEncode(exportData));

      Logger.info('Exported playlist to: $filePath', tag: 'Playlist');
      return filePath;
    } catch (e) {
      Logger.error('Failed to export playlist $playlistId', error: e);
      rethrow;
    }
  }

  @override
  Future<int> importPlaylist(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File not found');

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final playlistName = data['playlist']?['name'] as String? ?? 'Imported Playlist';
      final playlistId = await _dao.create(playlistName);

      Logger.info('Imported playlist: $playlistName (id: $playlistId)', tag: 'Playlist');
      return playlistId;
    } catch (e) {
      Logger.error('Failed to import playlist from: $filePath', error: e);
      rethrow;
    }
  }
}
