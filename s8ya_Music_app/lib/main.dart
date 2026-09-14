import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'database/database_helper.dart';
import 'providers/app_providers.dart';

/// Entry point for the S8YA Music Player application.
///
/// Initializes all required services before launching the app:
/// - Hive for fast key-value storage (settings, cache)
/// - SQLite database for relational data (songs, playlists)
/// - System UI configuration
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for desktop platforms (Windows / Linux / macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Hive for settings and cache storage
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
  await Hive.openBox<dynamic>(AppConstants.cacheBoxName);

  // Initialize SQLite database
  await DatabaseHelper.instance.database;

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Support both portrait and landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const ProviderScope(
      child: S8YAApp(),
    ),
  );
}

/// Root widget of the S8YA Music Player application.
///
/// Uses [ConsumerWidget] for Riverpod state management integration.
/// Configures Material 3 theming with dynamic color support,
/// GoRouter for navigation, and responsive layout handling.
class S8YAApp extends ConsumerWidget {
  const S8YAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme(themeState.accentColor),
      darkTheme: themeState.isAmoled
          ? AppTheme.amoledTheme(themeState.accentColor)
          : AppTheme.darkTheme(themeState.accentColor),
      themeMode: themeState.themeMode,
      
      // Router configuration
      routerConfig: router,
    );
  }
}
