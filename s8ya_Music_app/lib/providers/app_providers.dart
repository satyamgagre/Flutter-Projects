/// Top-level application providers for S8YA.
///
/// Re-exports commonly used providers and defines
/// cross-cutting concerns like initialization state.
export '../core/theme/theme_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/permission_service.dart';
import '../core/services/storage_service.dart';

/// Provider for the permission service singleton.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService.instance;
});

/// Provider for the storage service singleton.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

/// Provider tracking whether the app has been fully initialized.
/// This becomes true after permissions, database, and storage are set up.
final appInitializedProvider = StateProvider<bool>((ref) => false);

/// Provider tracking whether this is the first app launch.
final isFirstLaunchProvider = StateProvider<bool>((ref) => true);
