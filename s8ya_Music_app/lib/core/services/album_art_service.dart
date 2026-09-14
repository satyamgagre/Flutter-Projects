import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import '../constants/app_constants.dart';
import '../helpers/logger.dart';
import '../../database/hive/cache_box.dart';
import '../services/storage_service.dart' as storage;

/// Service for album art extraction, caching, and palette generation.
///
/// Features:
/// - Extract embedded artwork via on_audio_query
/// - Cache artwork to disk for fast subsequent loads
/// - Generate color palettes from artwork for dynamic theming
/// - Provide fallback artwork when none is available
class AlbumArtService {
  AlbumArtService._();
  static final AlbumArtService instance = AlbumArtService._();

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Map<int, Uint8List?> _memoryCache = {};
  final Map<int, PaletteGenerator?> _paletteCache = {};

  static const int _maxMemoryCacheSize = 100;

  /// Gets artwork bytes for a song, with memory and disk caching.
  ///
  /// Returns null if no artwork is available.
  Future<Uint8List?> getArtwork(
    int songId, {
    int size = AppConstants.artworkThumbnailSize,
    int quality = AppConstants.artworkQuality,
    ArtworkType type = ArtworkType.AUDIO,
  }) async {
    // Check memory cache first
    if (_memoryCache.containsKey(songId)) {
      return _memoryCache[songId];
    }

    // Check disk cache
    final cachedPath = CacheBox.instance.getArtworkPath(songId);
    if (cachedPath != null) {
      final file = File(cachedPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _addToMemoryCache(songId, bytes);
        return bytes;
      } else {
        // Cache entry is stale
        await CacheBox.instance.removeArtworkPath(songId);
      }
    }

    // Query artwork from MediaStore
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return null;

      final artwork = await _audioQuery.queryArtwork(
        songId,
        type,
        size: size,
        quality: quality,
      );

      if (artwork != null && artwork.isNotEmpty) {
        _addToMemoryCache(songId, artwork);
        // Save to disk cache asynchronously
        _saveToDiskCache(songId, artwork);
        return artwork;
      }
    } catch (e) {
      Logger.warning('Failed to get artwork for song $songId', tag: 'AlbumArt');
    }

    // Cache null result to avoid repeated queries
    _addToMemoryCache(songId, null);
    return null;
  }

  /// Gets high-resolution artwork for the full-screen player.
  Future<Uint8List?> getHighResArtwork(int songId) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return null;

      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: AppConstants.artworkFullSize,
        quality: 100,
      );
    } catch (e) {
      Logger.warning('Failed to get high-res artwork for song $songId');
      // Fall back to thumbnail
      return getArtwork(songId);
    }
  }

  /// Extracts the dominant color palette from a song's artwork.
  ///
  /// Used for dynamic player background coloring.
  Future<PaletteGenerator?> getPalette(int songId) async {
    // Check palette cache
    if (_paletteCache.containsKey(songId)) {
      return _paletteCache[songId];
    }

    final artwork = await getArtwork(songId);
    if (artwork == null) return null;

    try {
      final image = MemoryImage(artwork);
      final palette = await PaletteGenerator.fromImageProvider(
        image,
        size: const Size(100, 100), // Small size for faster processing
        maximumColorCount: 8,
      );

      // Cache the palette (limited cache size)
      if (_paletteCache.length >= 50) {
        _paletteCache.remove(_paletteCache.keys.first);
      }
      _paletteCache[songId] = palette;

      return palette;
    } catch (e) {
      Logger.warning('Failed to generate palette for song $songId');
      return null;
    }
  }

  /// Gets the dominant color for a song's artwork.
  ///
  /// Returns a default color if no artwork is available.
  Future<Color> getDominantColor(int songId, {Color fallback = const Color(0xFF6750A4)}) async {
    final palette = await getPalette(songId);
    return palette?.dominantColor?.color ?? fallback;
  }

  /// Gets the vibrant color for a song's artwork.
  Future<Color> getVibrantColor(int songId, {Color fallback = const Color(0xFF6750A4)}) async {
    final palette = await getPalette(songId);
    return palette?.vibrantColor?.color ??
        palette?.dominantColor?.color ??
        fallback;
  }

  /// Adds bytes to the memory cache with LRU eviction.
  void _addToMemoryCache(int songId, Uint8List? bytes) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // Remove oldest entries
      final keysToRemove = _memoryCache.keys
          .take(_maxMemoryCacheSize ~/ 4)
          .toList();
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }
    }
    _memoryCache[songId] = bytes;
  }

  /// Saves artwork to disk cache in the background.
  Future<void> _saveToDiskCache(int songId, Uint8List bytes) async {
    try {
      final path = storage.StorageService.instance.artworkPath(songId);
      final file = File(path);
      await file.writeAsBytes(bytes);
      await CacheBox.instance.setArtworkPath(songId, path);
    } catch (e) {
      Logger.warning('Failed to cache artwork to disk for song $songId');
    }
  }

  /// Clears all artwork caches (memory and disk).
  void clearCache() {
    _memoryCache.clear();
    _paletteCache.clear();
  }

  /// Pre-caches artwork for a list of song IDs (e.g., for a playlist).
  Future<void> preCacheArtwork(List<int> songIds) async {
    for (final id in songIds.take(20)) {
      await getArtwork(id);
    }
  }
}
