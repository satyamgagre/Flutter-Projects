import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/song_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Shows songs within a specific folder.
class FolderDetailScreen extends ConsumerWidget {
  final String folderPath;
  final String folderName;

  const FolderDetailScreen({
    super.key,
    required this.folderPath,
    required this.folderName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsByFolderProvider(folderPath));
    final service = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text(folderName)),
          songsAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No songs in this folder',
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
                          ],
                        ),
                      );
                    }
                    return SongTile(
                      song: songs[index - 1],
                      playQueue: songs,
                      indexInQueue: index - 1,
                    );
                  },
                  childCount: songs.length + 1,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: LoadingWidget()),
            error: (_, __) => const SliverFillRemaining(
              child: EmptyState(icon: Icons.error_outline, title: 'Error'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
