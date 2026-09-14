import 'package:flutter/foundation.dart';

/// Represents a single audio track in the S8YA Music Player.
///
/// Contains all metadata, playback statistics, and file information.
/// Maps directly to the `songs` table in SQLite.
@immutable
class SongModel {
  /// Unique identifier (from MediaStore or generated).
  final int id;

  /// Track title.
  final String title;

  /// Artist name.
  final String artist;

  /// Album name.
  final String album;

  /// Genre name.
  final String genre;

  /// Release year.
  final int? year;

  /// Track number within the album.
  final int? trackNo;

  /// Disc number for multi-disc albums.
  final int? discNo;

  /// Duration in milliseconds.
  final int duration;

  /// File size in bytes.
  final int size;

  /// Absolute file path on device storage.
  final String path;

  /// URI for accessing via MediaStore content provider.
  final String? uri;

  /// Path to cached album art (null if no art available).
  final String? coverArt;

  /// Whether this song is marked as a favorite.
  final bool favorite;

  /// User rating (0-5, 0 = unrated).
  final int rating;

  /// Total number of times this song has been played.
  final int playCount;

  /// Timestamp of the last time this song was played (milliseconds since epoch).
  final int? lastPlayed;

  /// Timestamp when this song was added to the library (milliseconds since epoch).
  final int dateAdded;

  /// Embedded or local LRC lyrics text.
  final String? lyrics;

  const SongModel({
    required this.id,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.genre = 'Unknown',
    this.year,
    this.trackNo,
    this.discNo,
    required this.duration,
    required this.size,
    required this.path,
    this.uri,
    this.coverArt,
    this.favorite = false,
    this.rating = 0,
    this.playCount = 0,
    this.lastPlayed,
    required this.dateAdded,
    this.lyrics,
  });

  /// Creates a [SongModel] from a SQLite row map.
  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String? ?? 'Unknown',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      genre: map['genre'] as String? ?? 'Unknown',
      year: map['year'] as int?,
      trackNo: map['trackNo'] as int?,
      discNo: map['discNo'] as int?,
      duration: map['duration'] as int? ?? 0,
      size: map['size'] as int? ?? 0,
      path: map['path'] as String,
      uri: map['uri'] as String?,
      coverArt: map['coverArt'] as String?,
      favorite: (map['favorite'] as int? ?? 0) == 1,
      rating: map['rating'] as int? ?? 0,
      playCount: map['playCount'] as int? ?? 0,
      lastPlayed: map['lastPlayed'] as int?,
      dateAdded: map['dateAdded'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      lyrics: map['lyrics'] as String?,
    );
  }

  /// Converts this song to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'year': year,
      'trackNo': trackNo,
      'discNo': discNo,
      'duration': duration,
      'size': size,
      'path': path,
      'uri': uri,
      'coverArt': coverArt,
      'favorite': favorite ? 1 : 0,
      'rating': rating,
      'playCount': playCount,
      'lastPlayed': lastPlayed,
      'dateAdded': dateAdded,
      'lyrics': lyrics,
    };
  }

  /// Creates a JSON-serializable map (for backup/export).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'year': year,
      'trackNo': trackNo,
      'discNo': discNo,
      'duration': duration,
      'size': size,
      'path': path,
      'uri': uri,
      'coverArt': coverArt,
      'favorite': favorite,
      'rating': rating,
      'playCount': playCount,
      'lastPlayed': lastPlayed,
      'dateAdded': dateAdded,
      'lyrics': lyrics,
    };
  }

  /// Creates a copy with the specified fields replaced.
  SongModel copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? genre,
    int? year,
    int? trackNo,
    int? discNo,
    int? duration,
    int? size,
    String? path,
    String? uri,
    String? coverArt,
    bool? favorite,
    int? rating,
    int? playCount,
    int? lastPlayed,
    int? dateAdded,
    String? lyrics,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNo: trackNo ?? this.trackNo,
      discNo: discNo ?? this.discNo,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      path: path ?? this.path,
      uri: uri ?? this.uri,
      coverArt: coverArt ?? this.coverArt,
      favorite: favorite ?? this.favorite,
      rating: rating ?? this.rating,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      dateAdded: dateAdded ?? this.dateAdded,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  /// Returns the formatted duration as `M:SS` or `H:MM:SS`.
  String get formattedDuration {
    final d = Duration(milliseconds: duration);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the folder name containing this song.
  String get folderName {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.length >= 2 ? parts[parts.length - 2] : 'Unknown';
  }

  /// Returns the file name of this song.
  String get fileName {
    return path.split(RegExp(r'[/\\]')).last;
  }

  /// Returns the file extension.
  String get fileExtension {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongModel && other.id == id && other.path == path;
  }

  @override
  int get hashCode => id.hashCode ^ path.hashCode;

  @override
  String toString() => 'SongModel(id: $id, title: $title, artist: $artist)';
}
