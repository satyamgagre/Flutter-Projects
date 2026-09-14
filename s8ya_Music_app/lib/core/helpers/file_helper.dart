import 'dart:math';

/// Helper utilities for file operations and formatting.
class FileHelper {
  FileHelper._();

  /// Formats a file size in bytes to a human-readable string.
  ///
  /// Example: `1048576` → `"1.0 MB"`
  /// Example: `1536` → `"1.5 KB"`
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
    final size = bytes / pow(1024, i);

    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Extracts the file name from a full file path.
  ///
  /// Example: `/storage/Music/song.mp3` → `"song.mp3"`
  static String getFileName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }

  /// Extracts the file name without extension.
  ///
  /// Example: `/storage/Music/song.mp3` → `"song"`
  static String getFileNameWithoutExtension(String path) {
    final fileName = getFileName(path);
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  /// Extracts the file extension (lowercase, without dot).
  ///
  /// Example: `/storage/Music/song.MP3` → `"mp3"`
  static String getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Extracts the directory path from a full file path.
  ///
  /// Example: `/storage/Music/song.mp3` → `"/storage/Music"`
  static String getDirectory(String path) {
    final lastSeparator = path.lastIndexOf(RegExp(r'[/\\]'));
    return lastSeparator != -1 ? path.substring(0, lastSeparator) : path;
  }

  /// Extracts the directory name from a full path.
  ///
  /// Example: `/storage/emulated/0/Music` → `"Music"`
  static String getDirectoryName(String path) {
    final dir = getDirectory(path);
    return dir.split(RegExp(r'[/\\]')).last;
  }

  /// Checks if a file extension is a supported audio format.
  static bool isSupportedAudio(String path) {
    const supported = {'mp3', 'aac', 'm4a', 'wav', 'flac', 'ogg', 'wma', 'opus'};
    return supported.contains(getExtension(path));
  }
}
