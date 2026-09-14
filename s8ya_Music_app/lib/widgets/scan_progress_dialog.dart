import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/music_scanner_service.dart';
import '../models/enums.dart';
import '../providers/scanner_providers.dart';

/// Dialog displaying real-time scan progress.
class ScanProgressDialog extends ConsumerWidget {
  const ScanProgressDialog({super.key});

  /// Shows the scan progress dialog and starts a scan.
  static Future<void> showAndScan(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ScanProgressDialog(),
    );

    await ref.read(scanProgressProvider.notifier).startScan();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(scanProgressProvider);

    return AlertDialog(
      title: Text(_getTitle(progress)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress.state == ScanState.scanning ||
              progress.state == ScanState.processing) ...[
            LinearProgressIndicator(
              value: progress.progressPercent > 0
                  ? progress.progressPercent
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          if (progress.currentFile != null)
            Text(
              progress.currentFile!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          Text(
            _getStatusText(progress),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (progress.state == ScanState.complete) ...[
            const SizedBox(height: 8),
            Text(
              '${progress.newSongs} new • ${progress.duplicates} existing • ${progress.deleted} removed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (progress.state == ScanState.complete ||
            progress.state == ScanState.error)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
      ],
    );
  }

  String _getTitle(ScanProgress progress) {
    switch (progress.state) {
      case ScanState.idle:
        return 'Ready to Scan';
      case ScanState.scanning:
        return 'Scanning...';
      case ScanState.processing:
        return 'Processing...';
      case ScanState.complete:
        return 'Scan Complete';
      case ScanState.error:
        return 'Scan Error';
    }
  }

  String _getStatusText(ScanProgress progress) {
    switch (progress.state) {
      case ScanState.idle:
        return 'Tap to start scanning';
      case ScanState.scanning:
        return 'Found ${progress.totalFound} files...';
      case ScanState.processing:
        return 'Processing ${progress.processed}/${progress.totalFound}';
      case ScanState.complete:
        return 'Found ${progress.newSongs} new songs';
      case ScanState.error:
        return progress.error ?? 'Unknown error';
    }
  }
}
