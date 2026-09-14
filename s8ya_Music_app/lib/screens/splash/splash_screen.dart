import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/scanner_providers.dart';
import '../../providers/song_providers.dart';

/// Animated splash screen with permission handling and initialization.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusText = 'Initializing...';
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize storage
      setState(() => _statusText = 'Setting up storage...');
      await StorageService.instance.initialize();

      // Initialize audio player
      setState(() => _statusText = 'Loading player...');
      await AudioPlayerService.instance.initialize();

      // Check permissions
      setState(() => _statusText = 'Checking permissions...');
      final hasPermission = await PermissionService.instance.requestAudioPermission();

      if (!hasPermission) {
        setState(() {
          _permissionDenied = true;
          _statusText = 'Permission required';
        });
        return;
      }

      // Check if first launch or need scan
      setState(() => _statusText = 'Loading library...');
      final songCount = await ref.read(songRepositoryProvider).getSongCount();

      if (songCount == 0) {
        // First launch - scan device
        setState(() => _statusText = 'Scanning for music...');
        await ref.read(scanProgressProvider.notifier).startScan();
      }

      // Request notification permission (non-blocking)
      PermissionService.instance.requestNotificationPermission();

      ref.read(appInitializedProvider.notifier).state = true;

      // Navigate to home
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() => _statusText = 'Error: ${e.toString()}');
    }
  }

  Future<void> _requestPermission() async {
    final isPermanentlyDenied = await PermissionService.instance.isAudioPermanentlyDenied();
    
    if (isPermanentlyDenied) {
      await PermissionService.instance.openSettings();
    } else {
      final granted = await PermissionService.instance.requestAudioPermission();
      if (granted) {
        setState(() => _permissionDenied = false);
        _initialize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primary.withValues(alpha: 0.15),
              context.colorScheme.surface,
              context.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Logo icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.headphones_rounded,
                    size: 60,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                // App name
                Text(
                  AppStrings.appName,
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: context.colorScheme.primary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 300.ms),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  AppStrings.appTagline,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                const Spacer(flex: 2),
                // Status or permission request
                if (_permissionDenied) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 48,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.errorPermissionMessage,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.security_rounded),
                          label: const Text(AppStrings.grantPermission),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Loading indicator
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        const LinearProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          _statusText,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
