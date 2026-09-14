/// Asset path references for the S8YA Music Player.
///
/// Centralizes all asset paths for easy management
/// and compile-time path validation.
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';

  // Images
  static const String logo = '$_imagesPath/logo.png';
  static const String defaultAlbumArt = '$_imagesPath/default_album_art.png';
  static const String splashBackground = '$_imagesPath/splash_bg.png';
  static const String emptyState = '$_imagesPath/empty_state.png';

  // Icons
  static const String appIcon = '$_iconsPath/app_icon.png';
}
