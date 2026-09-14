import 'package:flutter/material.dart';

/// Extension methods on [BuildContext] for convenient access
/// to commonly used Flutter framework objects.
extension ContextExtensions on BuildContext {
  // --- Theme ---

  /// Access the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Access the current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // --- Media Query ---

  /// Access the current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Bottom padding (for notch/gesture bar).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Top padding (for status bar).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Whether the device is a tablet (width >= 600).
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;

  /// Whether the device is in landscape mode.
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  // --- Navigation ---

  /// Pop the current route.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // --- Snackbar ---

  /// Shows a snackbar with the given [message].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
  }

  /// Shows an error snackbar.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
