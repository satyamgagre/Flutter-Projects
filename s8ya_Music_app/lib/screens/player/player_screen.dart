import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/duration_extensions.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/album_art_service.dart';
import '../../models/enums.dart' as app;
import '../../models/song_model.dart';
import '../../providers/player_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/album_art.dart';

/// Full-screen music player with dynamic theming and controls.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Color _dominantColor = const Color(0xFF6750A4);
  Color _secondaryColor = const Color(0xFF1C1B1F);

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    final state = AudioPlayerService.instance.currentState;
    if (state.currentSong != null) {
      final color = await AlbumArtService.instance.getDominantColor(state.currentSong!.id);
      final secondary = await AlbumArtService.instance.getVibrantColor(state.currentSong!.id);
      if (mounted) {
        setState(() {
          _dominantColor = color;
          _secondaryColor = secondary;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(playerStateProvider);
    final service = ref.read(audioPlayerServiceProvider);
    final isLandscape = context.isLandscape;

    return stateAsync.when(
      data: (state) {
        if (state.currentSong == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text('No song playing')),
          );
        }

        final song = state.currentSong!;

        // Reload colors when song changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadColors();
        });

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              color: Colors.white,
              onPressed: () => GoRouter.of(context).pop(),
            ),
            title: Text(
              AppStrings.nowPlaying,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.queue_music_rounded),
                color: Colors.white,
                onPressed: () => context.push('/queue'),
              ),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _dominantColor.withValues(alpha: 0.8),
                  _secondaryColor.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: isLandscape
                  ? _buildLandscapeLayout(context, state, service, song)
                  : _buildPortraitLayout(context, state, service, song),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Player error')),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerService service,
    SongModel song,
  ) {
    return Column(
      children: [
        const Spacer(),
        // Album Art
        Hero(
          tag: 'album_art_${song.id}',
          child: AlbumArt(
            songId: song.id,
            size: MediaQuery.of(context).size.width * 0.75,
            borderRadius: 24,
          ),
        )
            .animate(target: state.isPlaying ? 1 : 0)
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
            ),
        const SizedBox(height: 32),
        // Song info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                song.title,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${song.artist} • ${song.album}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Seek bar
        _buildSeekBar(context, state, service),
        const SizedBox(height: 16),
        // Main controls
        _buildControls(context, state, service),
        const SizedBox(height: 16),
        // Bottom actions
        _buildBottomActions(context, state, service),
        const Spacer(),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerService service,
    SongModel song,
  ) {
    return Row(
      children: [
        // Album art
        Expanded(
          child: Center(
            child: Hero(
              tag: 'album_art_${song.id}',
              child: AlbumArt(
                songId: song.id,
                size: MediaQuery.of(context).size.height * 0.6,
                borderRadius: 24,
              ),
            ),
          ),
        ),
        // Controls side
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.title,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSeekBar(context, state, service),
                const SizedBox(height: 16),
                _buildControls(context, state, service),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeekBar(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerService service,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: state.position.inMilliseconds.toDouble().clamp(
                    0.0,
                    state.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
                  ),
              max: state.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
              onChanged: (value) {
                service.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.position.formatted,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
                Text(
                  state.duration.formatted,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerService service,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: () => service.toggleShuffle(),
          icon: Icon(
            Icons.shuffle_rounded,
            color: state.shuffleMode != app.ShuffleMode.off
                ? context.colorScheme.primary
                : Colors.white70,
            size: 24,
          ),
        ),
        // Previous
        IconButton(
          onPressed: () => service.previous(),
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        // Play/Pause
        GestureDetector(
          onTap: () => service.togglePlayPause(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              state.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: _dominantColor,
              size: 40,
            ),
          ),
        )
            .animate(target: state.isPlaying ? 1 : 0)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),
        // Next
        IconButton(
          onPressed: () => service.next(),
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        // Repeat
        IconButton(
          onPressed: () => service.cycleRepeatMode(),
          icon: Icon(
            state.repeatMode == app.RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: state.repeatMode != app.RepeatMode.off
                ? context.colorScheme.primary
                : Colors.white70,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerService service,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Favorite
          IconButton(
            onPressed: () async {
              if (state.currentSong != null) {
                final repo = ref.read(songRepositoryProvider);
                await repo.toggleFavorite(state.currentSong!.id);
                ref.invalidate(favoriteSongsProvider);
              }
            },
            icon: Icon(
              state.currentSong?.favorite == true
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: state.currentSong?.favorite == true
                  ? Colors.red
                  : Colors.white70,
            ),
          ),
          // Speed
          IconButton(
            onPressed: () => _showSpeedSheet(context, service, state.speed),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed_rounded, color: Colors.white70, size: 20),
                if (state.speed != 1.0)
                  Text(
                    '${state.speed}x',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                  ),
              ],
            ),
          ),
          // Sleep Timer
          IconButton(
            onPressed: () => _showSleepTimerSheet(context, service, state),
            icon: Icon(
              Icons.bedtime_rounded,
              color: state.sleepTimerRemaining != null
                  ? context.colorScheme.primary
                  : Colors.white70,
            ),
          ),
          // Share
          IconButton(
            onPressed: () {
              if (state.currentSong != null) {
                // Share via song bottom sheet
              }
            },
            icon: const Icon(Icons.share_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _showSpeedSheet(
    BuildContext context,
    AudioPlayerService service,
    double currentSpeed,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.playbackSpeed,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.speedPresets.map((speed) {
                final isSelected = speed == currentSpeed;
                return ChoiceChip(
                  label: Text('${speed}x'),
                  selected: isSelected,
                  onSelected: (_) {
                    service.setSpeed(speed);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerSheet(
    BuildContext context,
    AudioPlayerService service,
    AudioPlayerState state,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.sleepTimer,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (state.sleepTimerRemaining != null)
              ListTile(
                leading: const Icon(Icons.timer_off_rounded),
                title: Text(
                  'Cancel Timer (${state.sleepTimerRemaining!.formatted} remaining)',
                ),
                onTap: () {
                  service.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
            ...AppConstants.sleepTimerPresets.map((minutes) => ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text('$minutes minutes'),
              onTap: () {
                service.startSleepTimer(Duration(minutes: minutes));
                Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Sleep timer set for $minutes minutes');
                }
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
