import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/services/album_art_service.dart';
import '../core/extensions/context_extensions.dart';

/// Reusable album art widget with caching and fallback.
///
/// Displays the embedded artwork for a song, with a
/// gradient fallback icon when no artwork is available.
class AlbumArt extends StatefulWidget {
  final int songId;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const AlbumArt({
    super.key,
    required this.songId,
    this.size = 48,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  @override
  State<AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<AlbumArt> {
  Uint8List? _artwork;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(AlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _loaded = false;
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    final art = await AlbumArtService.instance.getArtwork(widget.songId);
    if (mounted) {
      setState(() {
        _artwork = art;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _loaded && _artwork != null
            ? Image.memory(
                _artwork!,
                fit: widget.fit,
                width: widget.size,
                height: widget.size,
                gaplessPlayback: true,
              )
            : _FallbackArt(size: widget.size),
      ),
    );
  }
}

/// Fallback widget displayed when no album art is available.
class _FallbackArt extends StatelessWidget {
  final double size;

  const _FallbackArt({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primaryContainer,
            context.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.4,
        color: context.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
      ),
    );
  }
}
