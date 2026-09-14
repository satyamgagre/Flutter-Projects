import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_lib;
import '../core/constants/app_constants.dart';
import '../core/helpers/logger.dart';

/// SQLite database helper for the S8YA Music Player.
///
/// Manages database lifecycle, table creation, and migrations.
/// Uses the singleton pattern to ensure a single database connection.
class DatabaseHelper {
  DatabaseHelper._();

  /// Singleton instance.
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  /// Returns the database instance, creating it if necessary.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path_lib.join(dbPath, AppConstants.databaseName);

    Logger.info('Initializing database at: $fullPath', tag: 'Database');

    return openDatabase(
      fullPath,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configures the database connection.
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    // Enable WAL mode for better concurrent read/write performance
    await db.execute('PRAGMA journal_mode = WAL');
  }

  /// Creates all database tables.
  Future<void> _onCreate(Database db, int version) async {
    Logger.info('Creating database tables (version $version)', tag: 'Database');

    final batch = db.batch();

    // Songs table
    batch.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL DEFAULT 'Unknown Artist',
        album TEXT NOT NULL DEFAULT 'Unknown Album',
        genre TEXT NOT NULL DEFAULT 'Unknown',
        year INTEGER,
        trackNo INTEGER,
        discNo INTEGER,
        duration INTEGER NOT NULL DEFAULT 0,
        size INTEGER NOT NULL DEFAULT 0,
        path TEXT NOT NULL UNIQUE,
        uri TEXT,
        coverArt TEXT,
        favorite INTEGER NOT NULL DEFAULT 0,
        rating INTEGER NOT NULL DEFAULT 0,
        playCount INTEGER NOT NULL DEFAULT 0,
        lastPlayed INTEGER,
        dateAdded INTEGER NOT NULL,
        lyrics TEXT
      )
    ''');

    // Playlists table
    batch.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        coverPath TEXT,
        createdDate INTEGER NOT NULL,
        updatedDate INTEGER NOT NULL
      )
    ''');

    // Playlist songs junction table
    batch.execute('''
      CREATE TABLE playlist_songs (
        playlistId INTEGER NOT NULL,
        songId INTEGER NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        addedDate INTEGER NOT NULL,
        PRIMARY KEY (playlistId, songId),
        FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // Recently played table
    batch.execute('''
      CREATE TABLE recently_played (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        songId INTEGER NOT NULL,
        playedAt INTEGER NOT NULL,
        FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // Queue table
    batch.execute('''
      CREATE TABLE queue (
        songId INTEGER NOT NULL,
        position INTEGER NOT NULL,
        PRIMARY KEY (songId, position),
        FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // Performance indexes
    batch.execute('CREATE INDEX idx_songs_title ON songs(title COLLATE NOCASE)');
    batch.execute('CREATE INDEX idx_songs_artist ON songs(artist COLLATE NOCASE)');
    batch.execute('CREATE INDEX idx_songs_album ON songs(album COLLATE NOCASE)');
    batch.execute('CREATE INDEX idx_songs_genre ON songs(genre)');
    batch.execute('CREATE INDEX idx_songs_favorite ON songs(favorite)');
    batch.execute('CREATE INDEX idx_songs_play_count ON songs(playCount DESC)');
    batch.execute('CREATE INDEX idx_songs_date_added ON songs(dateAdded DESC)');
    batch.execute('CREATE INDEX idx_songs_last_played ON songs(lastPlayed DESC)');
    batch.execute('CREATE INDEX idx_recently_played_date ON recently_played(playedAt DESC)');
    batch.execute('CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlistId)');
    batch.execute('CREATE INDEX idx_queue_position ON queue(position ASC)');

    await batch.commit(noResult: true);
    Logger.info('Database tables created successfully', tag: 'Database');
  }

  /// Handles database schema upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info(
      'Upgrading database from v$oldVersion to v$newVersion',
      tag: 'Database',
    );
    // Future migration logic goes here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE songs ADD COLUMN newField TEXT');
    // }
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
      Logger.info('Database closed', tag: 'Database');
    }
  }

  /// Deletes the entire database (for testing/reset).
  Future<void> deleteDatabase() async {
    await close();
    final dbPath = await getDatabasesPath();
    final fullPath = path_lib.join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(fullPath);
    Logger.info('Database deleted', tag: 'Database');
  }
}
