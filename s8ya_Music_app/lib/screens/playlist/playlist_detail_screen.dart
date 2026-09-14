import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/playlist_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Playlist detail screen with songs and reorder support.
class PlaylistDetailScreen extends ConsumerWidget {
  final int playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistByIdProvider(playlistId));
    final songsAsync = ref.watch(playlistSongsProvider(playlistId));
    final service = ref.read(audioPlayerServiceProvider);
    final playlistRepo = ref.read(playlistRepositoryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: playlistAsync.when(
              data: (p) => Text(p?.name ?? 'Playlist'),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Error'),
            ),
          ),
          songsAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.queue_music_rounded,
                    title: 'This playlist is empty',
                    subtitle: 'Add songs from the library',
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Row(
                          children: [
                            Text(
                              '${songs.length} songs',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            FilledButton.tonalIcon(
                              onPressed: () => service.playQueue(songs),
                              icon: const Icon(Icons.play_arrow_rounded, size: 18),
                              label: const Text(AppStrings.playAll),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: () {
                                service.playQueue(songs);
                                service.toggleShuffle();
                              },
                              icon: const Icon(Icons.shuffle_rounded, size: 18),
                            ),
                          ],
                        ),
                      );
                    }

                    final songIndex = index - 1;
                    final song = songs[songIndex];
                    return Dismissible(
                      key: ValueKey(song.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: context.colorScheme.error,
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await playlistRepo.removeSongFromPlaylist(playlistId, song.id);
                        ref.invalidate(playlistSongsProvider(playlistId));
                        ref.invalidate(allPlaylistsProvider);
                      },
                      child: SongTile(
                        song: song,
                        playQueue: songs,
                        indexInQueue: songIndex,
                      ),
                    );
                  },
                  childCount: songs.length + 1,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingWidget(),
            ),
            error: (_, __) => const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading songs',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
