import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/extensions/context_extensions.dart';
import '../providers/player_providers.dart';
import 'album_art.dart';

/// Animated mini player widget displayed above the bottom navigation.
///
/// Features:
/// - Album art with hero animation (transitions to full player)
/// - Song title and artist (marquee on overflow)
/// - Play/pause and next buttons
/// - Linear progress indicator
/// - Tap to open full player
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playerStateProvider);

    return stateAsync.when(
      data: (state) {
        if (state.currentSong == null) return const SizedBox.shrink();

        final song = state.currentSong!;
        final service = ref.read(audioPlayerServiceProvider);

        return GestureDetector(
          onTap: () => context.push('/player'),
          // Swipe up to open player
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
              context.push('/player');
            }
          },
          child: Container(
            height: AppConstants.miniPlayerHeight,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.primary,
                  ),
                  minHeight: 2,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Album Art
                        Hero(
                          tag: 'album_art_${song.id}',
                          child: AlbumArt(
                            songId: song.id,
                            size: 48,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        IconButton(
                          onPressed: () => service.togglePlayPause(),
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: state.hasNext ? () => service.next() : null,
                          icon: const Icon(Icons.skip_next_rounded, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
