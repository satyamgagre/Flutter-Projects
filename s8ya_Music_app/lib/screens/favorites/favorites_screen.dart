import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/song_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Favorites screen with songs, artists, and albums tabs.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteSongsProvider);
    final service = ref.read(audioPlayerServiceProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverAppBar.medium(
              title: const Text(AppStrings.favorites),
              bottom: const TabBar(
                tabs: [
                  Tab(text: AppStrings.songs),
                  Tab(text: AppStrings.artists),
                  Tab(text: AppStrings.albums),
                ],
              ),
            ),
          ],
          body: favoritesAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const EmptyState(
                  icon: Icons.favorite_outline_rounded,
                  title: AppStrings.noFavorites,
                  subtitle: 'Tap the heart icon on any song',
                );
              }

              // Extract unique artists and albums
              final artists = songs.map((s) => s.artist).toSet().toList()..sort();
              final albums = songs.map((s) => s.album).toSet().toList()..sort();

              return TabBarView(
                children: [
                  // Songs tab
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: songs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              Text(
                                '${songs.length} favorites',
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
                  ),
                  // Artists tab
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artistSongs = songs.where((s) => s.artist == artists[index]).toList();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Icon(Icons.person_rounded, color: context.colorScheme.onPrimaryContainer),
                        ),
                        title: Text(artists[index]),
                        subtitle: Text('${artistSongs.length} songs'),
                        onTap: () => service.playQueue(artistSongs),
                      );
                    },
                  ),
                  // Albums tab
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final albumSongs = songs.where((s) => s.album == albums[index]).toList();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.secondaryContainer,
                          child: Icon(Icons.album_rounded, color: context.colorScheme.onSecondaryContainer),
                        ),
                        title: Text(albums[index]),
                        subtitle: Text('${albumSongs.length} songs'),
                        onTap: () => service.playQueue(albumSongs),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const LoadingWidget(),
            error: (_, __) => const EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading favorites',
            ),
          ),
        ),
      ),
    );
  }
}
