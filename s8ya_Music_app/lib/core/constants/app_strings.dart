/// All user-facing strings for the S8YA Music Player.
///
/// Centralized for easy maintenance and future localization.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'S8YA';
  static const String appTagline = 'Your Music, Your Way';

  // Navigation
  static const String home = 'Home';
  static const String library = 'Library';
  static const String favorites = 'Favorites';
  static const String playlists = 'Playlists';
  static const String settings = 'Settings';

  // Home Sections
  static const String recentlyPlayed = 'Recently Played';
  static const String mostPlayed = 'Most Played';
  static const String recentlyAdded = 'Recently Added';
  static const String albums = 'Albums';
  static const String artists = 'Artists';
  static const String genres = 'Genres';
  static const String folders = 'Folders';

  // Player
  static const String nowPlaying = 'Now Playing';
  static const String queue = 'Queue';
  static const String playNext = 'Play Next';
  static const String addToQueue = 'Add to Queue';
  static const String playbackSpeed = 'Playback Speed';
  static const String sleepTimer = 'Sleep Timer';
  static const String lyrics = 'Lyrics';
  static const String equalizer = 'Equalizer';
  static const String songInfo = 'Song Info';

  // Library
  static const String songs = 'Songs';
  static const String scanDevice = 'Scan Device';
  static const String scanning = 'Scanning...';
  static const String scanComplete = 'Scan Complete';
  static const String noSongsFound = 'No songs found';
  static const String scanDeviceMessage = 'Tap to scan your device for music';
  static const String refreshLibrary = 'Refresh Library';
  static const String importFolder = 'Import Folder';

  // Playlist
  static const String createPlaylist = 'Create Playlist';
  static const String deletePlaylist = 'Delete Playlist';
  static const String renamePlaylist = 'Rename Playlist';
  static const String playlistName = 'Playlist Name';
  static const String enterPlaylistName = 'Enter playlist name';
  static const String noPlaylists = 'No playlists yet';
  static const String addToPlaylist = 'Add to Playlist';
  static const String removeFromPlaylist = 'Remove from Playlist';
  static const String exportPlaylist = 'Export Playlist';
  static const String importPlaylist = 'Import Playlist';

  // Favorites
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String noFavorites = 'No favorites yet';
  static const String favoriteSongs = 'Favorite Songs';
  static const String favoriteArtists = 'Favorite Artists';
  static const String favoriteAlbums = 'Favorite Albums';

  // Search
  static const String search = 'Search';
  static const String searchHint = 'Search songs, artists, albums...';
  static const String noResults = 'No results found';
  static const String recentSearches = 'Recent Searches';

  // Queue
  static const String currentQueue = 'Current Queue';
  static const String clearQueue = 'Clear Queue';
  static const String saveQueue = 'Save Queue as Playlist';
  static const String emptyQueue = 'Queue is empty';

  // Folders
  static const String browseStorage = 'Browse Storage';
  static const String folderView = 'Folder View';
  static const String noFolders = 'No music folders found';

  // Settings
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String amoledMode = 'AMOLED Mode';
  static const String systemTheme = 'System';
  static const String accentColor = 'Accent Color';
  static const String backup = 'Backup';
  static const String restore = 'Restore';
  static const String clearCache = 'Clear Cache';
  static const String about = 'About';
  static const String privacy = 'Privacy';
  static const String permissions = 'Permissions';
  static const String statistics = 'Statistics';
  static const String backupRestore = 'Backup & Restore';
  static const String playback = 'Playback';
  static const String crossfade = 'Crossfade';
  static const String gaplessPlayback = 'Gapless Playback';

  // Statistics
  static const String totalSongs = 'Total Songs';
  static const String totalArtists = 'Total Artists';
  static const String totalAlbums = 'Total Albums';
  static const String listeningTime = 'Listening Time';
  static const String playCount = 'Play Count';

  // File Management
  static const String renameSong = 'Rename Song';
  static const String deleteSong = 'Delete Song';
  static const String shareSong = 'Share Song';
  static const String songDetails = 'Song Details';

  // Actions
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String rename = 'Rename';
  static const String save = 'Save';
  static const String create = 'Create';
  static const String ok = 'OK';
  static const String done = 'Done';
  static const String seeAll = 'See All';
  static const String sortBy = 'Sort By';
  static const String play = 'Play';
  static const String playAll = 'Play All';
  static const String shuffleAll = 'Shuffle All';

  // Sort Options
  static const String title = 'Title';
  static const String artist = 'Artist';
  static const String album = 'Album';
  static const String duration = 'Duration';
  static const String dateAdded = 'Date Added';
  static const String year = 'Year';
  static const String size = 'File Size';

  // Repeat Modes
  static const String repeatOff = 'Repeat Off';
  static const String repeatAll = 'Repeat All';
  static const String repeatOne = 'Repeat One';

  // Errors
  static const String errorLoadingSongs = 'Error loading songs';
  static const String errorPlayback = 'Error during playback';
  static const String errorPermission = 'Permission required';
  static const String errorPermissionMessage = 'S8YA needs access to your music files to play songs.';
  static const String errorDatabase = 'Database error';
  static const String errorFileNotFound = 'File not found';
  static const String errorUnknown = 'Something went wrong';
  static const String grantPermission = 'Grant Permission';

  // Confirmation
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmClearQueue = 'Clear the current queue?';
  static const String confirmClearCache = 'Clear all cached data?';
}
