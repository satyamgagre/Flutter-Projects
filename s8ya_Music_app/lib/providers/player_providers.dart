import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_player_service.dart';
import '../core/services/audio_handler.dart';
import '../models/song_model.dart';
import '../models/enums.dart';

/// Provider for the audio handler (initialized once).
final audioHandlerProvider = Provider<Future<AudioHandler>>((ref) async {
  return await AudioService.init(
    builder: () => S8YAAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.s8ya.app.audio',
      androidNotificationChannelName: 'S8YA Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );
});

/// Provider for the audio player service singleton.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService.instance;
});

/// Provider for the complete player state stream.
final playerStateProvider = StreamProvider<AudioPlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream;
});

/// Provider for the current song stream.
final currentSongProvider = StreamProvider<SongModel?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentSongStream;
});

/// Provider for whether audio is currently playing.
final isPlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.isPlaying).distinct();
});

/// Provider for the current position.
final positionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.position);
});

/// Provider for the current duration.
final durationProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.duration).distinct();
});

/// Provider for the current repeat mode.
final repeatModeProvider = StreamProvider<RepeatMode>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.repeatMode).distinct();
});

/// Provider for the current shuffle mode.
final shuffleModeProvider = StreamProvider<ShuffleMode>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.shuffleMode).distinct();
});

/// Provider for the current queue.
final currentQueueProvider = StreamProvider<List<SongModel>>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.queueStream;
});

/// Provider for sleep timer remaining.
final sleepTimerProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.sleepTimerRemaining).distinct();
});

/// Provider for playback speed.
final playbackSpeedProvider = StreamProvider<double>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.speed).distinct();
});

/// Provider for progress percentage (0.0 to 1.0).
final progressProvider = StreamProvider<double>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream.map((state) => state.progress);
});
