/// Enumerations used throughout the S8YA Music Player.
///
/// Provides type-safe representations of player states,
/// sorting options, and configuration modes.

/// Repeat mode for audio playback.
enum RepeatMode {
  /// No repeat — stop after last track.
  off,

  /// Repeat the entire queue.
  all,

  /// Repeat the current track.
  one,
}

/// Shuffle mode for audio playback.
enum ShuffleMode {
  /// Sequential playback.
  off,

  /// Standard random shuffle.
  on,

  /// Smart shuffle — avoids recently played tracks
  /// and considers genre/artist variety.
  smart,
}

/// Sort field options for song lists.
enum SortBy {
  title,
  artist,
  album,
  duration,
  dateAdded,
  year,
  size,
  playCount,
  lastPlayed,
}

/// Sort direction.
enum SortOrder {
  ascending,
  descending,
}

/// Player processing state.
enum PlayerState {
  idle,
  loading,
  buffering,
  playing,
  paused,
  completed,
  error,
}

/// Scan progress state.
enum ScanState {
  idle,
  scanning,
  processing,
  complete,
  error,
}

/// Extension on [SortBy] for display names and database column mapping.
extension SortByExtension on SortBy {
  String get displayName {
    switch (this) {
      case SortBy.title:
        return 'Title';
      case SortBy.artist:
        return 'Artist';
      case SortBy.album:
        return 'Album';
      case SortBy.duration:
        return 'Duration';
      case SortBy.dateAdded:
        return 'Date Added';
      case SortBy.year:
        return 'Year';
      case SortBy.size:
        return 'Size';
      case SortBy.playCount:
        return 'Play Count';
      case SortBy.lastPlayed:
        return 'Last Played';
    }
  }

  String get columnName {
    switch (this) {
      case SortBy.title:
        return 'title';
      case SortBy.artist:
        return 'artist';
      case SortBy.album:
        return 'album';
      case SortBy.duration:
        return 'duration';
      case SortBy.dateAdded:
        return 'dateAdded';
      case SortBy.year:
        return 'year';
      case SortBy.size:
        return 'size';
      case SortBy.playCount:
        return 'playCount';
      case SortBy.lastPlayed:
        return 'lastPlayed';
    }
  }
}

/// Extension on [RepeatMode] for cycling through modes.
extension RepeatModeExtension on RepeatMode {
  RepeatMode get next {
    switch (this) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }
}
