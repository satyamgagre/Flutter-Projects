import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/player_providers.dart';
import '../../providers/playlist_providers.dart';
import '../../widgets/album_art.dart';
import '../../widgets/empty_state.dart';

/// Queue screen with drag-to-reorder and save-as-playlist.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playerStateProvider);
    final service = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.currentQueue),
        actions: [
          // Save as playlist
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: AppStrings.saveQueue,
            onPressed: () => _saveAsPlaylist(context, ref),
          ),
          // Clear queue
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: AppStrings.clearQueue,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(AppStrings.clearQueue),
                  content: const Text(AppStrings.confirmClearQueue),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(AppStrings.cancel),
                    ),
                    FilledButton(
                      onPressed: () {
                        service.clearQueue();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          if (state.queue.isEmpty) {
            return const EmptyState(
              icon: Icons.queue_music_rounded,
              title: AppStrings.emptyQueue,
              subtitle: 'Play a song to start building your queue',
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: state.queue.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              service.moveQueueItem(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final song = state.queue[index];
              final isCurrent = index == state.currentIndex;

              return Dismissible(
                key: ValueKey('${song.id}_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: context.colorScheme.error,
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => service.removeFromQueue(index),
                child: ListTile(
                  key: ValueKey('tile_${song.id}_$index'),
                  leading: AlbumArt(songId: song.id, size: 48, borderRadius: 8),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? context.colorScheme.primary : null,
                      fontWeight: isCurrent ? FontWeight.w600 : null,
                    ),
                  ),
                  subtitle: Text(
                    '${song.artist} • ${song.formattedDuration}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle_rounded),
                  ),
                  onTap: () => service.skipToIndex(index),
                  selected: isCurrent,
                  selectedTileColor: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Error loading queue',
        ),
      ),
    );
  }

  void _saveAsPlaylist(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final playlistRepo = ref.read(playlistRepositoryProvider);
    final service = ref.read(audioPlayerServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.saveQueue),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: AppStrings.enterPlaylistName),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final id = await playlistRepo.createPlaylist(name);
                final songIds = service.queue.map((s) => s.id).toList();
                await playlistRepo.addSongsToPlaylist(id, songIds);
                ref.invalidate(allPlaylistsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Saved as "$name"');
                }
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
