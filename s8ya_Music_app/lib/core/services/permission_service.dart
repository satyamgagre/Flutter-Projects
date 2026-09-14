import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/logger.dart';

/// Service for managing application permissions.
///
/// Handles platform-specific permission requests for:
/// - Audio/storage access (READ_MEDIA_AUDIO on Android 13+, READ_EXTERNAL_STORAGE on older)
/// - Notification permissions (for media controls)
class PermissionService {
  PermissionService._();

  /// Singleton instance.
  static final PermissionService instance = PermissionService._();

  /// Checks and requests audio storage permission.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  /// On non-Android/iOS platforms, always returns `true`.
  Future<bool> requestAudioPermission() async {
    // Desktop platforms don't need runtime permissions
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    try {
      // On Android 13+ (API 33+), use READ_MEDIA_AUDIO
      // On older Android, use READ_EXTERNAL_STORAGE
      // permission_handler handles this automatically with Permission.audio
      PermissionStatus status = await Permission.audio.status;

      if (status.isGranted) {
        Logger.info('Audio permission already granted', tag: 'Permission');
        return true;
      }

      if (status.isPermanentlyDenied) {
        Logger.warning('Audio permission permanently denied', tag: 'Permission');
        return false;
      }

      // Request permission
      status = await Permission.audio.request();
      Logger.info('Audio permission status: $status', tag: 'Permission');
      return status.isGranted;
    } catch (e, stackTrace) {
      Logger.error(
        'Error requesting audio permission',
        tag: 'Permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Checks if audio permission is currently granted.
  Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    try {
      final status = await Permission.audio.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking audio permission', error: e);
      return false;
    }
  }

  /// Requests notification permission (Android 13+).
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      Logger.error('Error requesting notification permission', error: e);
      return false;
    }
  }

  /// Opens the app settings page for manual permission management.
  Future<bool> openSettings() async {
    return openAppSettings();
  }

  /// Checks if audio permission is permanently denied.
  Future<bool> isAudioPermanentlyDenied() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    try {
      final status = await Permission.audio.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }
}
