import 'package:flutter/foundation.dart';

/// Represents a song in the playback queue.
///
/// Maps to the `queue` table in SQLite for queue persistence.
@immutable
class QueueItemModel {
  /// The song in the queue.
  final int songId;

  /// Position in the queue (0-based index).
  final int position;

  const QueueItemModel({
    required this.songId,
    required this.position,
  });

  factory QueueItemModel.fromMap(Map<String, dynamic> map) {
    return QueueItemModel(
      songId: map['songId'] as int,
      position: map['position'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'position': position,
    };
  }

  QueueItemModel copyWith({
    int? songId,
    int? position,
  }) {
    return QueueItemModel(
      songId: songId ?? this.songId,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueItemModel &&
          other.songId == songId &&
          other.position == position;

  @override
  int get hashCode => songId.hashCode ^ position.hashCode;
}
