import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_strings.dart';
import '../core/extensions/context_extensions.dart';
import '../core/helpers/file_helper.dart';
import '../models/song_model.dart';
import '../providers/player_providers.dart';
import '../providers/playlist_providers.dart';
import '../providers/song_providers.dart';
import 'album_art.dart';

/// Bottom sheet displaying song options and actions.
class SongBottomSheet {
  SongBottomSheet._();

  /// Shows the song options bottom sheet.
  static void show(BuildContext context, WidgetRef ref, SongModel song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SongBottomSheetContent(song: song, parentRef: ref),
    );
  }
}

class _SongBottomSheetContent extends ConsumerWidget {
  final SongModel song;
  final WidgetRef parentRef;

  const _SongBottomSheetContent({required this.song, required this.parentRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(audioPlayerServiceProvider);
    final songRepo = ref.read(songRepositoryProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Song header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                AlbumArt(songId: song.id, size: 56, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artist} • ${song.album}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Options
          _OptionTile(
            icon: Icons.play_arrow_rounded,
            title: AppStrings.playNext,
            onTap: () {
              service.playNext(song);
              Navigator.pop(context);
              context.showSnackBar('"${song.title}" will play next');
            },
          ),
          _OptionTile(
            icon: Icons.queue_music_rounded,
            title: AppStrings.addToQueue,
            onTap: () {
              service.addToQueue(song);
              Navigator.pop(context);
              context.showSnackBar('Added to queue');
            },
          ),
          _OptionTile(
            icon: Icons.playlist_add_rounded,
            title: AppStrings.addToPlaylist,
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylistDialog(context, ref, song);
            },
          ),
          _OptionTile(
            icon: song.favorite
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            title: song.favorite
                ? AppStrings.removeFromFavorites
                : AppStrings.addToFavorites,
            iconColor: song.favorite ? Colors.red : null,
            onTap: () async {
              await songRepo.toggleFavorite(song.id);
              ref.invalidate(favoriteSongsProvider);
              ref.invalidate(songsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                context.showSnackBar(
                  song.favorite ? 'Removed from favorites' : 'Added to favorites',
                );
              }
            },
          ),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            title: AppStrings.songDetails,
            onTap: () {
              Navigator.pop(context);
              _showSongDetails(context, song);
            },
          ),
          _OptionTile(
            icon: Icons.share_rounded,
            title: AppStrings.shareSong,
            onTap: () async {
              Navigator.pop(context);
              await Share.shareXFiles(
                [XFile(song.path)],
                text: '${song.title} - ${song.artist}',
              );
            },
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            title: AppStrings.deleteSong,
            iconColor: context.colorScheme.error,
            titleColor: context.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ref, song);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static void _showAddToPlaylistDialog(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) {
    final playlists = ref.read(allPlaylistsProvider);
    final playlistRepo = ref.read(playlistRepositoryProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.addToPlaylist,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showCreatePlaylistDialog(context, ref, song);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(AppStrings.createPlaylist),
                  ),
                ],
              ),
            ),
            playlists.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(AppStrings.noPlaylists),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final playlist = list[index];
                    return ListTile(
                      leading: const Icon(Icons.playlist_play_rounded),
                      title: Text(playlist.name),
                      subtitle: Text('${playlist.songCount} songs'),
                      onTap: () async {
                        await playlistRepo.addSongToPlaylist(
                          playlist.id,
                          song.id,
                        );
                        ref.invalidate(allPlaylistsProvider);
                        ref.invalidate(playlistSongsProvider(playlist.id));
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to "${playlist.name}"',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Error loading playlists'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void _showCreatePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) {
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
                final id = await playlistRepo.createPlaylist(name);
                await playlistRepo.addSongToPlaylist(id, song.id);
                ref.invalidate(allPlaylistsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Created "$name" with 1 song');
                }
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }

  static void _showSongDetails(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.songDetails),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Title', song.title),
              _DetailRow('Artist', song.artist),
              _DetailRow('Album', song.album),
              _DetailRow('Genre', song.genre),
              if (song.year != null) _DetailRow('Year', '${song.year}'),
              _DetailRow('Duration', song.formattedDuration),
              _DetailRow('Size', FileHelper.formatSize(song.size)),
              _DetailRow('Format', song.fileExtension),
              _DetailRow('Play Count', '${song.playCount}'),
              _DetailRow('Path', song.path),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  static void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteSong),
        content: Text('Delete "${song.title}" from library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(songRepositoryProvider);
              await repo.deleteSong(song.id);
              ref.invalidate(songsProvider);
              ref.invalidate(favoriteSongsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                context.showSnackBar('"${song.title}" deleted');
              }
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

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: titleColor != null ? TextStyle(color: titleColor) : null),
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
