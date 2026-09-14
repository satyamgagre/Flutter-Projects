import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/extensions/context_extensions.dart';
import '../models/song_model.dart';
import 'album_art.dart';

/// Horizontal scrolling list of song cards.
///
/// Used in home screen sections (Recently Played, Most Played, etc.).
class HorizontalCardList extends StatelessWidget {
  final List<SongModel> songs;
  final void Function(SongModel song, int index) onTap;
  final double cardWidth;
  final double cardHeight;

  const HorizontalCardList({
    super.key,
    required this.songs,
    required this.onTap,
    this.cardWidth = 140,
    this.cardHeight = 190,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Padding(
            padding: EdgeInsets.only(right: index < songs.length - 1 ? 12 : 0),
            child: _SongCard(
              song: song,
              width: cardWidth,
              onTap: () => onTap(song, index),
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: index * 50),
            duration: const Duration(milliseconds: 400),
          ).slideX(
            begin: 0.1,
            end: 0,
            delay: Duration(milliseconds: index * 50),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongModel song;
  final double width;
  final VoidCallback onTap;

  const _SongCard({
    required this.song,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            AlbumArt(
              songId: song.id,
              size: width,
              borderRadius: 12,
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // Artist
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
