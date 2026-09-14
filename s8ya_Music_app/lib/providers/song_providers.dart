import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song_model.dart';
import '../models/enums.dart';
import '../repositories/song_repository.dart';

/// Provider for the song repository.
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepositoryImpl();
});

/// Provider for all songs with sorting.
final allSongsProvider = FutureProvider.family<List<SongModel>, (SortBy, SortOrder)>(
  (ref, params) async {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getAllSongs(sortBy: params.$1, sortOrder: params.$2);
  },
);

/// Provider for all songs with default sorting.
final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllSongs();
});

/// Provider for favorite songs.
final favoriteSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getFavorites();
});

/// Provider for recently played songs.
final recentlyPlayedProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getRecentlyPlayed();
});

/// Provider for most played songs.
final mostPlayedProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getMostPlayed();
});

/// Provider for recently added songs.
final recentlyAddedProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getRecentlyAdded();
});

/// Provider for songs by a specific artist.
final songsByArtistProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, artist) async {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getSongsByArtist(artist);
  },
);

/// Provider for songs in a specific album.
final songsByAlbumProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, album) async {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getSongsByAlbum(album);
  },
);

/// Provider for songs of a specific genre.
final songsByGenreProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, genre) async {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getSongsByGenre(genre);
  },
);

/// Provider for songs in a specific folder.
final songsByFolderProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, folder) async {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getSongsByFolder(folder);
  },
);

/// Provider for all distinct artists.
final allArtistsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllArtists();
});

/// Provider for all albums with metadata.
final allAlbumsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllAlbums();
});

/// Provider for all genres with counts.
final allGenresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllGenres();
});

/// Provider for all folders with counts.
final allFoldersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllFolders();
});

/// Provider for search results.
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<SongModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(songRepositoryProvider);
  return repo.searchSongs(query);
});

/// Provider for library statistics.
final libraryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getStatistics();
});

/// Provider for total song count.
final songCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongCount();
});
