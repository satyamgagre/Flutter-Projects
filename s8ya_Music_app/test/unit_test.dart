import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:s8ya/models/song_model.dart';
import 'package:s8ya/models/enums.dart' as app;
import 'package:s8ya/core/helpers/file_helper.dart';
import 'package:s8ya/core/services/audio_player_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SongModel Tests', () {
    test('SongModel properties and formattedDuration', () {
      const song = SongModel(
        id: 1,
        title: 'Song Title',
        artist: 'Artist Name',
        album: 'Album Name',
        duration: 215000, // 3 mins 35 secs
        size: 5242880,
        path: r'C:\Music\TestArtist\Album\Song Title.mp3',
        dateAdded: 1700000000000,
      );

      expect(song.title, 'Song Title');
      expect(song.formattedDuration, '3:35');
      expect(song.fileName, 'Song Title.mp3');
      expect(song.fileExtension, 'MP3');
      expect(song.folderName, 'Album');
    });

    test('SongModel toMap and fromMap roundtrip', () {
      const original = SongModel(
        id: 42,
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        album: 'A Night at the Opera',
        genre: 'Rock',
        duration: 354000,
        size: 8000000,
        path: '/storage/music/queen.mp3',
        dateAdded: 1600000000,
        favorite: true,
        playCount: 15,
      );

      final map = original.toMap();
      final reconstructed = SongModel.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.artist, original.artist);
      expect(reconstructed.album, original.album);
      expect(reconstructed.favorite, true);
      expect(reconstructed.playCount, 15);
      expect(reconstructed.formattedDuration, '5:54');
    });
  });

  group('FileHelper Tests', () {
    test('formatSize formats correctly', () {
      expect(FileHelper.formatSize(0), '0 B');
      expect(FileHelper.formatSize(1024), '1.0 KB');
      expect(FileHelper.formatSize(1048576), '1.0 MB');
      expect(FileHelper.formatSize(1073741824), '1.0 GB');
    });

    test('getFileName and getExtension handle both slash types', () {
      expect(FileHelper.getFileName(r'C:\Music\track.flac'), 'track.flac');
      expect(FileHelper.getFileName('/music/downloads/track.ogg'), 'track.ogg');
      expect(FileHelper.getExtension('song.mp3'), 'mp3');
      expect(FileHelper.getExtension('SONG.WAV'), 'wav');
      expect(FileHelper.isSupportedAudio('track.flac'), true);
      expect(FileHelper.isSupportedAudio('document.pdf'), false);
    });
  });

  group('AudioPlayerState Tests', () {
    test('AudioPlayerState default values and copyWith', () {
      const state = AudioPlayerState();
      expect(state.isPlaying, false);
      expect(state.repeatMode, app.RepeatMode.off);
      expect(state.shuffleMode, app.ShuffleMode.off);
      expect(state.progress, 0.0);

      final updated = state.copyWith(
        isPlaying: true,
        duration: const Duration(seconds: 200),
        position: const Duration(seconds: 50),
      );
      expect(updated.isPlaying, true);
      expect(updated.progress, 0.25);
    });
  });

  group('SQLite FFI In-Memory Database Tests', () {
    test('can create tables and perform CRUD in SQLite via FFI', () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('''
        CREATE TABLE songs (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          album TEXT NOT NULL,
          path TEXT NOT NULL UNIQUE,
          duration INTEGER NOT NULL,
          size INTEGER NOT NULL,
          dateAdded INTEGER NOT NULL
        )
      ''');

      await db.insert('songs', {
        'id': 1,
        'title': 'Test Song',
        'artist': 'Test Artist',
        'album': 'Test Album',
        'path': r'C:\Music\test.mp3',
        'duration': 180000,
        'size': 4000000,
        'dateAdded': DateTime.now().millisecondsSinceEpoch,
      });

      final rows = await db.query('songs');
      expect(rows.length, 1);
      expect(rows.first['title'], 'Test Song');

      await db.close();
    });
  });
}
