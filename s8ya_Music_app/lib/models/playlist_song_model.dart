import 'package:flutter/foundation.dart';

/// Represents the many-to-many relationship between playlists and songs.
///
/// Maps to the `playlist_songs` table in SQLite.
@immutable
class PlaylistSongModel {
  /// The playlist this entry belongs to.
  final int playlistId;

  /// The song in the playlist.
  final int songId;

  /// The song's position/order within the playlist.
  final int position;

  /// Timestamp when the song was added to the playlist.
  final int addedDate;

  const PlaylistSongModel({
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedDate,
  });

  factory PlaylistSongModel.fromMap(Map<String, dynamic> map) {
    return PlaylistSongModel(
      playlistId: map['playlistId'] as int,
      songId: map['songId'] as int,
      position: map['position'] as int? ?? 0,
      addedDate: map['addedDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'songId': songId,
      'position': position,
      'addedDate': addedDate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistSongModel &&
          other.playlistId == playlistId &&
          other.songId == songId;

  @override
  int get hashCode => playlistId.hashCode ^ songId.hashCode;
}
