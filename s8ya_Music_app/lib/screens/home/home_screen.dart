import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/song_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/section_header.dart';
import '../../widgets/horizontal_card_list.dart';

/// Home screen with music discovery sections.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final mostPlayed = ref.watch(mostPlayedProvider);
    final favorites = ref.watch(favoriteSongsProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider);
    final songCount = ref.watch(songCountProvider);
    final service = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentlyPlayedProvider);
          ref.invalidate(mostPlayedProvider);
          ref.invalidate(favoriteSongsProvider);
          ref.invalidate(recentlyAddedProvider);
          ref.invalidate(songCountProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar.large(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Text(AppStrings.appName),
                ],
              ),
              actions: [
                songCount.whenOrNull(
                  data: (count) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Chip(
                      label: Text('$count songs'),
                      avatar: const Icon(Icons.music_note_rounded, size: 16),
                    ),
                  ),
                ) ?? const SizedBox.shrink(),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recently Played
                  recentlyPlayed.when(
                    data: (songs) {
                      if (songs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SectionHeader(
                            title: AppStrings.recentlyPlayed,
                            icon: Icons.history_rounded,
                          ),
                          HorizontalCardList(
                            songs: songs.take(10).toList(),
                            onTap: (song, index) {
                              service.playQueue(songs, startIndex: index);
                            },
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Most Played
                  mostPlayed.when(
                    data: (songs) {
                      if (songs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SectionHeader(
                            title: AppStrings.mostPlayed,
                            icon: Icons.trending_up_rounded,
                          ),
                          HorizontalCardList(
                            songs: songs.take(10).toList(),
                            onTap: (song, index) {
                              service.playQueue(songs, startIndex: index);
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Favorites
                  favorites.when(
                    data: (songs) {
                      if (songs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SectionHeader(
                            title: AppStrings.favorites,
                            icon: Icons.favorite_rounded,
                            onSeeAll: () => {}, // Already a tab
                          ),
                          HorizontalCardList(
                            songs: songs.take(10).toList(),
                            onTap: (song, index) {
                              service.playQueue(songs, startIndex: index);
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Recently Added
                  recentlyAdded.when(
                    data: (songs) {
                      if (songs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SectionHeader(
                            title: AppStrings.recentlyAdded,
                            icon: Icons.new_releases_rounded,
                          ),
                          HorizontalCardList(
                            songs: songs.take(10).toList(),
                            onTap: (song, index) {
                              service.playQueue(songs, startIndex: index);
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Bottom padding for mini player
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
