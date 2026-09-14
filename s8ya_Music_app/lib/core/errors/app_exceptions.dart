/// Base exception class for all S8YA application errors.
///
/// Provides a consistent error structure with human-readable messages
/// and optional technical details for logging.
abstract class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.details, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message${details != null ? ' ($details)' : ''}';
}

/// Thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.details, super.stackTrace});
}

/// Thrown when a required file is not found or inaccessible.
class FileNotFoundException extends AppException {
  final String filePath;
  const FileNotFoundException(this.filePath, {super.details, super.stackTrace})
      : super('File not found: $filePath');
}

/// Thrown when a required permission is not granted.
class PermissionException extends AppException {
  const PermissionException(super.message, {super.details, super.stackTrace});
}

/// Thrown when the audio player encounters an error.
class PlayerException extends AppException {
  const PlayerException(super.message, {super.details, super.stackTrace});
}

/// Thrown when an audio scan operation fails.
class ScanException extends AppException {
  const ScanException(super.message, {super.details, super.stackTrace});
}

/// Thrown when a backup or restore operation fails.
class BackupException extends AppException {
  const BackupException(super.message, {super.details, super.stackTrace});
}

/// Thrown when a playlist operation fails.
class PlaylistException extends AppException {
  const PlaylistException(super.message, {super.details, super.stackTrace});
}

/// Thrown when a search operation fails.
class SearchException extends AppException {
  const SearchException(super.message, {super.details, super.stackTrace});
}
