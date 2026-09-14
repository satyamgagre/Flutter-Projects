import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/playlist_model.dart';
import '../../providers/playlist_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Playlist list screen with create, pin, rename, delete.
class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text(AppStrings.playlists),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showCreateDialog(context, ref),
              ),
            ],
          ),
          playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.playlist_play_rounded,
                    title: AppStrings.noPlaylists,
                    subtitle: 'Create your first playlist',
                    action: FilledButton.icon(
                      onPressed: () => _showCreateDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.createPlaylist),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isTablet ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playlists[index];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/playlist/${playlist.id}'),
                          onLongPress: () => _showPlaylistOptions(context, ref, playlist),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.playlist_play_rounded,
                                      color: context.colorScheme.primary,
                                    ),
                                    if (playlist.isPinned) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.push_pin_rounded,
                                        size: 14,
                                        color: context.colorScheme.primary,
                                      ),
                                    ],
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert_rounded, size: 18),
                                      onPressed: () => _showPlaylistOptions(context, ref, playlist),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  playlist.name,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${playlist.songCount} songs • ${playlist.formattedDuration}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 50),
                        duration: 300.ms,
                      ).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        delay: Duration(milliseconds: index * 50),
                      );
                    },
                    childCount: playlists.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingWidget(),
            ),
            error: (_, __) => const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading playlists',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final playlistRepo = ref.read(playlistRepositoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.createPlaylist),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: AppStrings.enterPlaylistName,
          ),
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
                await playlistRepo.createPlaylist(name);
                ref.invalidate(allPlaylistsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, WidgetRef ref, PlaylistModel playlist) {
    final playlistRepo = ref.read(playlistRepositoryProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text(AppStrings.playAll),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/playlist/${playlist.id}');
              },
            ),
            ListTile(
              leading: Icon(playlist.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded),
              title: Text(playlist.isPinned ? 'Unpin' : 'Pin to Top'),
              onTap: () async {
                await playlistRepo.togglePin(playlist.id);
                ref.invalidate(allPlaylistsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text(AppStrings.renamePlaylist),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, ref, playlist);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: Theme.of(ctx).colorScheme.error),
              title: Text(AppStrings.deletePlaylist, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, playlist);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    final playlistRepo = ref.read(playlistRepositoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.renamePlaylist),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: AppStrings.playlistName),
          autofocus: true,
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
                await playlistRepo.renamePlaylist(playlist.id, name);
                ref.invalidate(allPlaylistsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PlaylistModel playlist) {
    final playlistRepo = ref.read(playlistRepositoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deletePlaylist),
        content: Text('Delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await playlistRepo.deletePlaylist(playlist.id);
              ref.invalidate(allPlaylistsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
