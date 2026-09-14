import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/backup_service.dart';

/// Provider for the backup service singleton.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService.instance;
});

/// Provider for the list of available backups.
final backupListProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(backupServiceProvider);
  final backups = await service.listBackups();
  return backups.map((e) => e.path).toList();
});
