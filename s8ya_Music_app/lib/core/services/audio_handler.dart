import 'package:audio_service/audio_service.dart';
import 'package:s8ya/models/enums.dart' as app;
import '../helpers/logger.dart';
import 'audio_player_service.dart';

/// Custom [AudioHandler] for S8YA background audio.
///
/// Integrates with Android's MediaSession and iOS's NowPlayingInfo
/// to provide:
/// - Lock screen controls
/// - Notification media controls
/// - Headset/bluetooth button support
/// - Android Auto / CarPlay integration
class S8YAAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _playerService;

  S8YAAudioHandler() : _playerService = AudioPlayerService.instance {
    _init();
  }

  void _init() {
    // Subscribe to player state changes and update audio_service state
    _playerService.stateStream.listen((state) {
      // Update media item
      if (state.currentSong != null) {
        final song = state.currentSong!;
        mediaItem.add(MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(milliseconds: song.duration),
          artUri: song.coverArt != null ? Uri.file(song.coverArt!) : null,
        ));
      }

      // Update playback state
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          state.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(state.playerState),
        playing: state.isPlaying,
        updatePosition: state.position,
        bufferedPosition: state.bufferedPosition,
        speed: state.speed,
        queueIndex: state.currentIndex,
      ));
    });

    // Update queue
    _playerService.queueStream.listen((songs) {
      queue.add(songs.map((song) => MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
      )).toList());
    });

    Logger.info('Audio handler initialized', tag: 'AudioHandler');
  }

  AudioProcessingState _mapProcessingState(app.PlayerState state) {
    switch (state) {
      case app.PlayerState.idle:
        return AudioProcessingState.idle;
      case app.PlayerState.loading:
        return AudioProcessingState.loading;
      case app.PlayerState.buffering:
        return AudioProcessingState.buffering;
      case app.PlayerState.playing:
      case app.PlayerState.paused:
        return AudioProcessingState.ready;
      case app.PlayerState.completed:
        return AudioProcessingState.completed;
      case app.PlayerState.error:
        return AudioProcessingState.error;
    }
  }

  @override
  Future<void> play() => _playerService.play();

  @override
  Future<void> pause() => _playerService.pause();

  @override
  Future<void> stop() => _playerService.stop();

  @override
  Future<void> seek(Duration position) => _playerService.seek(position);

  @override
  Future<void> skipToNext() => _playerService.next();

  @override
  Future<void> skipToPrevious() => _playerService.previous();

  @override
  Future<void> skipToQueueItem(int index) => _playerService.skipToIndex(index);

  @override
  Future<void> setSpeed(double speed) => _playerService.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _playerService.setRepeatMode(app.RepeatMode.off);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        _playerService.setRepeatMode(app.RepeatMode.all);
        break;
      case AudioServiceRepeatMode.one:
        _playerService.setRepeatMode(app.RepeatMode.one);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    switch (shuffleMode) {
      case AudioServiceShuffleMode.none:
        if (_playerService.currentState.shuffleMode != app.ShuffleMode.off) {
          _playerService.toggleShuffle();
        }
        break;
      case AudioServiceShuffleMode.all:
      case AudioServiceShuffleMode.group:
        if (_playerService.currentState.shuffleMode == app.ShuffleMode.off) {
          _playerService.toggleShuffle();
        }
        break;
    }
  }
}
