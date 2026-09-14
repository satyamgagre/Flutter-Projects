import 'package:flutter/foundation.dart';

/// Represents a user-created playlist.
///
/// Maps to the `playlists` table in SQLite.
@immutable
class PlaylistModel {
  /// Unique identifier.
  final int id;

  /// Playlist name.
  final String name;

  /// Whether this playlist is pinned to the top.
  final bool isPinned;

  /// Optional cover image path.
  final String? coverPath;

  /// Number of songs in this playlist (computed, not stored).
  final int songCount;

  /// Total duration in milliseconds (computed, not stored).
  final int totalDuration;

  /// Creation timestamp (milliseconds since epoch).
  final int createdDate;

  /// Last update timestamp (milliseconds since epoch).
  final int updatedDate;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.isPinned = false,
    this.coverPath,
    this.songCount = 0,
    this.totalDuration = 0,
    required this.createdDate,
    required this.updatedDate,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] as int,
      name: map['name'] as String,
      isPinned: (map['isPinned'] as int? ?? 0) == 1,
      coverPath: map['coverPath'] as String?,
      songCount: map['songCount'] as int? ?? 0,
      totalDuration: map['totalDuration'] as int? ?? 0,
      createdDate: map['createdDate'] as int,
      updatedDate: map['updatedDate'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isPinned': isPinned ? 1 : 0,
      'coverPath': coverPath,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPinned': isPinned,
      'coverPath': coverPath,
      'songCount': songCount,
      'totalDuration': totalDuration,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
    };
  }

  PlaylistModel copyWith({
    int? id,
    String? name,
    bool? isPinned,
    String? coverPath,
    int? songCount,
    int? totalDuration,
    int? createdDate,
    int? updatedDate,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPinned: isPinned ?? this.isPinned,
      coverPath: coverPath ?? this.coverPath,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  /// Returns the formatted total duration.
  String get formattedDuration {
    final d = Duration(milliseconds: totalDuration);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlaylistModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlaylistModel(id: $id, name: $name, songCount: $songCount)';
}
