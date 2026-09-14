import 'package:flutter/foundation.dart';

/// Represents a recently played track entry.
///
/// Maps to the `recently_played` table in SQLite.
@immutable
class RecentlyPlayedModel {
  /// The song that was played.
  final int songId;

  /// Timestamp when the song was played (milliseconds since epoch).
  final int playedAt;

  const RecentlyPlayedModel({
    required this.songId,
    required this.playedAt,
  });

  factory RecentlyPlayedModel.fromMap(Map<String, dynamic> map) {
    return RecentlyPlayedModel(
      songId: map['songId'] as int,
      playedAt: map['playedAt'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'playedAt': playedAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentlyPlayedModel &&
          other.songId == songId &&
          other.playedAt == playedAt;

  @override
  int get hashCode => songId.hashCode ^ playedAt.hashCode;
}
