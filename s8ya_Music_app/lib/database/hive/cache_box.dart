import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

/// Hive-based cache storage for album art paths and other temporary data.
///
/// Provides fast lookup for cached album artwork file paths,
/// avoiding repeated disk I/O checks.
class CacheBox {
  CacheBox._();
  static final CacheBox instance = CacheBox._();

  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.cacheBoxName);

  /// Gets the cached artwork path for a song ID.
  String? getArtworkPath(int songId) {
    return _box.get('art_$songId') as String?;
  }

  /// Caches an artwork path for a song ID.
  Future<void> setArtworkPath(int songId, String path) async {
    await _box.put('art_$songId', path);
  }

  /// Removes a cached artwork path.
  Future<void> removeArtworkPath(int songId) async {
    await _box.delete('art_$songId');
  }

  /// Gets a generic cached value.
  T? get<T>(String key) {
    return _box.get(key) as T?;
  }

  /// Sets a generic cached value.
  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  /// Clears all cached data.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Returns the number of cached entries.
  int get length => _box.length;
}
