import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../repositories/playlist_repository.dart';

/// Provider for the playlist repository.
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

/// Provider for all playlists.
final allPlaylistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getAllPlaylists();
});

/// Provider for songs in a specific playlist.
final playlistSongsProvider = FutureProvider.family<List<SongModel>, int>(
  (ref, playlistId) async {
    final repo = ref.watch(playlistRepositoryProvider);
    return repo.getPlaylistSongs(playlistId);
  },
);

/// Provider for a single playlist by ID.
final playlistByIdProvider = FutureProvider.family<PlaylistModel?, int>(
  (ref, id) async {
    final repo = ref.watch(playlistRepositoryProvider);
    return repo.getPlaylistById(id);
  },
);
