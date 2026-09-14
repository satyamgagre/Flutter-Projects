import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/music_scanner_service.dart';

/// Provider for the music scanner service.
final musicScannerProvider = Provider<MusicScannerService>((ref) {
  return MusicScannerService.instance;
});

/// Provider for tracking scan progress state.
final scanProgressProvider = StateNotifierProvider<ScanProgressNotifier, ScanProgress>((ref) {
  return ScanProgressNotifier(ref.watch(musicScannerProvider));
});

/// Notifier that manages scan state and triggers scans.
class ScanProgressNotifier extends StateNotifier<ScanProgress> {
  final MusicScannerService _scanner;

  ScanProgressNotifier(this._scanner) : super(const ScanProgress());

  /// Initiates a full device scan.
  Future<void> startScan() async {
    await _scanner.scanDevice(
      onProgress: (progress) {
        if (mounted) {
          state = progress;
        }
      },
    );
  }

  /// Scans a specific folder.
  Future<void> scanFolder(String folderPath) async {
    await _scanner.scanFolder(
      folderPath,
      onProgress: (progress) {
        if (mounted) {
          state = progress;
        }
      },
    );
  }

  /// Refreshes the library.
  Future<void> refresh() async {
    await _scanner.refreshLibrary(
      onProgress: (progress) {
        if (mounted) {
          state = progress;
        }
      },
    );
  }

  /// Resets scan state to idle.
  void reset() {
    state = const ScanProgress();
  }
}
