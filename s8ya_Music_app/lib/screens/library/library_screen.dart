import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/enums.dart';
import '../../providers/song_providers.dart';
import '../../providers/scanner_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// State provider for current sort preferences.
final librarySortByProvider = StateProvider<SortBy>((ref) => SortBy.title);
final librarySortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.ascending);

/// Library screen showing all songs with sort and scan.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(librarySortByProvider);
    final sortOrder = ref.watch(librarySortOrderProvider);
    final songsAsync = ref.watch(allSongsProvider((sortBy, sortOrder)));
    final scanProgress = ref.watch(scanProgressProvider);
    final service = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(scanProgressProvider.notifier).startScan();
          ref.invalidate(allSongsProvider);
          ref.invalidate(songsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: const Text(AppStrings.library),
              actions: [
                // Scan button
                if (scanProgress.state == ScanState.scanning ||
                    scanProgress.state == ScanState.processing)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: scanProgress.progressPercent > 0
                            ? scanProgress.progressPercent
                            : null,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: AppStrings.scanDevice,
                    onPressed: () async {
                      await ref.read(scanProgressProvider.notifier).startScan();
                      ref.invalidate(allSongsProvider);
                      ref.invalidate(songsProvider);
                      if (context.mounted) {
                        context.showSnackBar(
                          'Found ${scanProgress.newSongs} new songs',
                        );
                      }
                    },
                  ),
                // Sort button
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: AppStrings.sortBy,
                  onPressed: () => _showSortSheet(context, ref),
                ),
              ],
            ),
            // Play All / Shuffle buttons
            songsAsync.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.library_music_rounded,
                      title: AppStrings.noSongsFound,
                      subtitle: AppStrings.scanDeviceMessage,
                      action: FilledButton.icon(
                        onPressed: () {
                          ref.read(scanProgressProvider.notifier).startScan();
                        },
                        icon: const Icon(Icons.search_rounded),
                        label: const Text(AppStrings.scanDevice),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        // Header with count and action buttons
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              Text(
                                '${songs.length} ${AppStrings.songs.toLowerCase()}',
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
                                tooltip: AppStrings.shuffleAll,
                              ),
                            ],
                          ),
                        );
                      }

                      final songIndex = index - 1;
                      return SongTile(
                        song: songs[songIndex],
                        playQueue: songs,
                        indexInQueue: songIndex,
                      );
                    },
                    childCount: songs.length + 1, // +1 for header
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: LoadingWidget(message: 'Loading songs...'),
              ),
              error: (error, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: AppStrings.errorLoadingSongs,
                  subtitle: error.toString(),
                ),
              ),
            ),
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final currentSortBy = ref.read(librarySortByProvider);
    final currentSortOrder = ref.read(librarySortOrderProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.sortBy,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      currentSortOrder == SortOrder.ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                    ),
                    onPressed: () {
                      ref.read(librarySortOrderProvider.notifier).state =
                          currentSortOrder == SortOrder.ascending
                              ? SortOrder.descending
                              : SortOrder.ascending;
                      Navigator.pop(ctx);
                    },
                    tooltip: currentSortOrder == SortOrder.ascending
                        ? 'Ascending'
                        : 'Descending',
                  ),
                ],
              ),
            ),
            ...SortBy.values.map((sortBy) => RadioListTile<SortBy>(
              title: Text(sortBy.displayName),
              value: sortBy,
              groupValue: currentSortBy,
              onChanged: (value) {
                if (value != null) {
                  ref.read(librarySortByProvider.notifier).state = value;
                }
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
