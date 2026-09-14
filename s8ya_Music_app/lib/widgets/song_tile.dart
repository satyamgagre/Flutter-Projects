import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions/context_extensions.dart';
import '../models/song_model.dart';
import '../providers/player_providers.dart';
import 'album_art.dart';
import 'song_bottom_sheet.dart';

/// Reusable song list tile widget.
///
/// Displays album art, song title, artist, duration,
/// and an options menu. Highlights when currently playing.
class SongTile extends ConsumerWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final List<SongModel>? playQueue;
  final int? indexInQueue;
  final bool showTrackNumber;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.playQueue,
    this.indexInQueue,
    this.showTrackNumber = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider).valueOrNull;
    final isCurrentSong = currentSong?.id == song.id;

    return ListTile(
      onTap: onTap ?? () {
        final service = ref.read(audioPlayerServiceProvider);
        if (playQueue != null && indexInQueue != null) {
          service.playQueue(playQueue!, startIndex: indexInQueue!);
        } else {
          service.playSong(song);
        }
      },
      leading: showTrackNumber
          ? SizedBox(
              width: 48,
              child: Center(
                child: isCurrentSong
                    ? Icon(Icons.equalizer_rounded, color: context.colorScheme.primary)
                    : Text(
                        '${song.trackNo ?? 0}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            )
          : AlbumArt(songId: song.id, size: 48, borderRadius: 8),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrentSong ? context.colorScheme.primary : null,
          fontWeight: isCurrentSong ? FontWeight.w600 : null,
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
      trailing: trailing ?? IconButton(
        icon: const Icon(Icons.more_vert_rounded, size: 20),
        onPressed: () => SongBottomSheet.show(context, ref, song),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
