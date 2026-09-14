/// Represents a handled failure in the application.
///
/// Used in the repository layer to return failures instead of
/// throwing exceptions, enabling clean error handling in the UI.
abstract class Failure {
  final String message;
  final String? details;

  const Failure(this.message, {this.details});

  @override
  String toString() => '$runtimeType: $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.details});
}

class FileFailure extends Failure {
  const FileFailure(super.message, {super.details});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.details});
}

class PlayerFailure extends Failure {
  const PlayerFailure(super.message, {super.details});
}

class ScanFailure extends Failure {
  const ScanFailure(super.message, {super.details});
}

class BackupFailure extends Failure {
  const BackupFailure(super.message, {super.details});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.details});
}
