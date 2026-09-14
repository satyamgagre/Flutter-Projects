import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rxdart/rxdart.dart';
import '../../models/song_model.dart';
import 'package:s8ya/models/enums.dart' as app;
import '../constants/app_constants.dart';
import '../helpers/logger.dart';

/// Represents the current state of the audio player.
class AudioPlayerState {
  final SongModel? currentSong;
  final List<SongModel> queue;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final app.PlayerState playerState;
  final app.RepeatMode repeatMode;
  final app.ShuffleMode shuffleMode;
  final double speed;
  final double pitch;
  final double volume;
  final bool isPlaying;
  final bool hasNext;
  final bool hasPrevious;
  final Duration? sleepTimerRemaining;

  const AudioPlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = -1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.playerState = app.PlayerState.idle,
    this.repeatMode = app.RepeatMode.off,
    this.shuffleMode = app.ShuffleMode.off,
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.isPlaying = false,
    this.hasNext = false,
    this.hasPrevious = false,
    this.sleepTimerRemaining,
  });

  AudioPlayerState copyWith({
    SongModel? currentSong,
    List<SongModel>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    app.PlayerState? playerState,
    app.RepeatMode? repeatMode,
    app.ShuffleMode? shuffleMode,
    double? speed,
    double? pitch,
    double? volume,
    bool? isPlaying,
    bool? hasNext,
    bool? hasPrevious,
    Duration? sleepTimerRemaining,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      playerState: playerState ?? this.playerState,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
    );
  }

  /// Progress percentage (0.0 to 1.0).
  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }
}

/// Core audio player service for S8YA Music Player.
///
/// Wraps just_audio's [ja.AudioPlayer] with queue management,
/// background playback via audio_service, sleep timer,
/// crossfade support, and comprehensive state streaming.
///
/// This is a singleton service initialized once at app startup.
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  late final ja.AudioPlayer _player;
  ja.AudioPlayer? _crossfadePlayer; // Secondary player for crossfade
  ja.ConcatenatingAudioSource? _playlist;

  // --- State ---
  final List<SongModel> _queue = [];
  final List<SongModel> _originalQueue = []; // Pre-shuffle order
  int _currentIndex = -1;
  app.RepeatMode _repeatMode = app.RepeatMode.off;
  app.ShuffleMode _shuffleMode = app.ShuffleMode.off;
  double _speed = 1.0;
  double _pitch = 1.0;
  Timer? _sleepTimer;
  Duration? _sleepTimerRemaining;
  Timer? _sleepTickTimer;
  bool _crossfadeEnabled = false;
  int _crossfadeDurationMs = AppConstants.crossfadeDurationMs;

  // --- Streams ---
  final _stateSubject = BehaviorSubject<AudioPlayerState>.seeded(
    const AudioPlayerState(),
  );
  final _currentSongSubject = BehaviorSubject<SongModel?>.seeded(null);
  final _queueSubject = BehaviorSubject<List<SongModel>>.seeded([]);

  /// Stream of the full player state.
  Stream<AudioPlayerState> get stateStream => _stateSubject.stream;

  /// Stream of the current song.
  Stream<SongModel?> get currentSongStream => _currentSongSubject.stream;

  /// Stream of the current queue.
  Stream<List<SongModel>> get queueStream => _queueSubject.stream;

  /// Current player state snapshot.
  AudioPlayerState get currentState => _stateSubject.value;

  /// Current song.
  SongModel? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  /// Current queue.
  List<SongModel> get queue => List.unmodifiable(_queue);

  /// Whether player is currently playing.
  bool get isPlaying => _player.playing;

  /// Initializes the audio player and sets up listeners.
  Future<void> initialize() async {
    _player = ja.AudioPlayer();

    // Listen to player state changes
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen(_onPositionChanged);
    _player.durationStream.listen(_onDurationChanged);
    _player.bufferedPositionStream.listen(_onBufferedPositionChanged);
    _player.currentIndexStream.listen(_onIndexChanged);
    _player.processingStateStream.listen(_onProcessingStateChanged);

    Logger.info('Audio player initialized', tag: 'Player');
  }

  /// Plays a single song.
  Future<void> playSong(SongModel song) async {
    await playQueue([song], startIndex: 0);
  }

  /// Plays a list of songs starting at [startIndex].
  Future<void> playQueue(
    List<SongModel> songs, {
    int startIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    try {
      _queue.clear();
      _queue.addAll(songs);
      _originalQueue.clear();
      _originalQueue.addAll(songs);
      _currentIndex = startIndex.clamp(0, songs.length - 1);

      // Apply shuffle if enabled
      if (_shuffleMode != app.ShuffleMode.off) {
        _shuffleQueue(keepCurrentSong: true);
      }

      // Build audio source
      await _buildAndSetAudioSource();

      // Seek to the start index and play
      await _player.seek(Duration.zero, index: _currentIndex);
      await _player.play();

      _updateState();
      _notifyQueueChanged();

      Logger.info('Playing: ${currentSong?.title}', tag: 'Player');
    } catch (e, st) {
      Logger.error('Failed to play queue', error: e, stackTrace: st);
      _emitError();
    }
  }

  /// Resumes or starts playback.
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      Logger.error('Failed to play', error: e);
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      Logger.error('Failed to pause', error: e);
    }
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stops playback and resets position.
  Future<void> stop() async {
    try {
      await _player.stop();
      _updateState();
    } catch (e) {
      Logger.error('Failed to stop', error: e);
    }
  }

  /// Seeks to a position in the current track.
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      Logger.error('Failed to seek', error: e);
    }
  }

  /// Skips to the next track.
  Future<void> next() async {
    try {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
        await _player.seek(Duration.zero, index: _currentIndex);
        if (!_player.playing) await _player.play();
        _updateState();
      } else if (_repeatMode == app.RepeatMode.all) {
        _currentIndex = 0;
        await _player.seek(Duration.zero, index: 0);
        if (!_player.playing) await _player.play();
        _updateState();
      }
    } catch (e) {
      Logger.error('Failed to skip to next', error: e);
    }
  }

  /// Skips to the previous track, or restarts if > 3 seconds in.
  Future<void> previous() async {
    try {
      final position = _player.position;
      if (position.inSeconds > 3) {
        // Restart current track
        await _player.seek(Duration.zero);
      } else if (_currentIndex > 0) {
        _currentIndex--;
        await _player.seek(Duration.zero, index: _currentIndex);
        if (!_player.playing) await _player.play();
        _updateState();
      } else if (_repeatMode == app.RepeatMode.all) {
        _currentIndex = _queue.length - 1;
        await _player.seek(Duration.zero, index: _currentIndex);
        if (!_player.playing) await _player.play();
        _updateState();
      } else {
        await _player.seek(Duration.zero);
      }
    } catch (e) {
      Logger.error('Failed to skip to previous', error: e);
    }
  }

  /// Skips to a specific index in the queue.
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    try {
      _currentIndex = index;
      await _player.seek(Duration.zero, index: index);
      if (!_player.playing) await _player.play();
      _updateState();
    } catch (e) {
      Logger.error('Failed to skip to index $index', error: e);
    }
  }

  // --- Repeat Mode ---

  /// Cycles to the next repeat mode.
  void cycleRepeatMode() {
    _repeatMode = app.RepeatModeExtension(_repeatMode).next;
    _player.setLoopMode(_getLoopMode());
    _updateState();
    Logger.debug('Repeat mode: $_repeatMode', tag: 'Player');
  }

  /// Sets a specific repeat mode.
  void setRepeatMode(app.RepeatMode mode) {
    _repeatMode = mode;
    _player.setLoopMode(_getLoopMode());
    _updateState();
  }

  ja.LoopMode _getLoopMode() {
    switch (_repeatMode) {
      case app.RepeatMode.off:
        return ja.LoopMode.off;
      case app.RepeatMode.all:
        return ja.LoopMode.all;
      case app.RepeatMode.one:
        return ja.LoopMode.one;
    }
  }

  // --- Shuffle ---

  /// Toggles shuffle mode.
  void toggleShuffle() {
    if (_shuffleMode == app.ShuffleMode.off) {
      _shuffleMode = app.ShuffleMode.on;
      _shuffleQueue(keepCurrentSong: true);
    } else {
      _shuffleMode = app.ShuffleMode.off;
      _restoreOriginalOrder();
    }
    _updateState();
    _notifyQueueChanged();
    Logger.debug('Shuffle mode: $_shuffleMode', tag: 'Player');
  }

  /// Sets smart shuffle mode.
  void setSmartShuffle() {
    _shuffleMode = app.ShuffleMode.smart;
    _smartShuffleQueue();
    _updateState();
    _notifyQueueChanged();
  }

  void _shuffleQueue({bool keepCurrentSong = false}) {
    if (_queue.isEmpty) return;

    final current = keepCurrentSong && _currentIndex >= 0 && _currentIndex < _queue.length
        ? _queue[_currentIndex]
        : null;

    _queue.shuffle(Random());

    if (current != null) {
      _queue.remove(current);
      _queue.insert(0, current);
      _currentIndex = 0;
    }
  }

  void _smartShuffleQueue() {
    if (_queue.length <= 2) return;

    final current = _currentIndex >= 0 && _currentIndex < _queue.length
        ? _queue[_currentIndex]
        : null;

    // Smart shuffle: group by artist/genre, then interleave
    final byArtist = <String, List<SongModel>>{};
    for (final song in _queue) {
      byArtist.putIfAbsent(song.artist, () => []).add(song);
    }

    // Shuffle within each artist group
    for (final songs in byArtist.values) {
      songs.shuffle(Random());
    }

    // Interleave artists to avoid consecutive same-artist tracks
    _queue.clear();
    final artists = byArtist.values.toList()..sort((a, b) => b.length.compareTo(a.length));
    while (artists.any((a) => a.isNotEmpty)) {
      for (final artistSongs in artists) {
        if (artistSongs.isNotEmpty) {
          _queue.add(artistSongs.removeAt(0));
        }
      }
    }

    if (current != null) {
      _queue.remove(current);
      _queue.insert(0, current);
      _currentIndex = 0;
    }
  }

  void _restoreOriginalOrder() {
    final current = currentSong;
    _queue.clear();
    _queue.addAll(_originalQueue);
    if (current != null) {
      _currentIndex = _queue.indexWhere((s) => s.id == current.id);
      if (_currentIndex == -1) _currentIndex = 0;
    }
  }

  // --- Playback Speed & Pitch ---

  /// Sets the playback speed.
  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(AppConstants.minPlaybackSpeed, AppConstants.maxPlaybackSpeed);
    await _player.setSpeed(_speed);
    _updateState();
  }

  /// Sets the audio pitch.
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _player.setPitch(_pitch);
    _updateState();
  }

  /// Sets the volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
    _updateState();
  }

  // --- Queue Management ---

  /// Adds a song to play next (after current track).
  void playNext(SongModel song) {
    final insertIndex = _currentIndex + 1;
    if (insertIndex <= _queue.length) {
      _queue.insert(insertIndex, song);
      _originalQueue.add(song);
      _rebuildAudioSourceAsync();
      _notifyQueueChanged();
      _updateState();
    }
  }

  /// Adds a song to the end of the queue.
  void addToQueue(SongModel song) {
    _queue.add(song);
    _originalQueue.add(song);
    _rebuildAudioSourceAsync();
    _notifyQueueChanged();
    _updateState();
  }

  /// Adds multiple songs to the end of the queue.
  void addAllToQueue(List<SongModel> songs) {
    _queue.addAll(songs);
    _originalQueue.addAll(songs);
    _rebuildAudioSourceAsync();
    _notifyQueueChanged();
    _updateState();
  }

  /// Removes a song from the queue at the given index.
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;

    if (index == _currentIndex) {
      // Skip to next before removing
      if (_queue.length > 1) {
        next();
      }
    }

    final song = _queue.removeAt(index);
    _originalQueue.remove(song);

    if (index < _currentIndex) {
      _currentIndex--;
    }

    _rebuildAudioSourceAsync();
    _notifyQueueChanged();
    _updateState();
  }

  /// Moves a song in the queue from [oldIndex] to [newIndex].
  void moveQueueItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Update current index
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    _rebuildAudioSourceAsync();
    _notifyQueueChanged();
    _updateState();
  }

  /// Clears the entire queue and stops playback.
  Future<void> clearQueue() async {
    await stop();
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    _notifyQueueChanged();
    _updateState();
  }

  // --- Sleep Timer ---

  /// Starts a sleep timer for the given duration.
  void startSleepTimer(Duration duration) {
    cancelSleepTimer();

    _sleepTimerRemaining = duration;

    // Tick every second for UI countdown
    _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimerRemaining == null) {
        timer.cancel();
        return;
      }

      _sleepTimerRemaining = _sleepTimerRemaining! - const Duration(seconds: 1);

      if (_sleepTimerRemaining!.inSeconds <= 0) {
        _onSleepTimerEnd();
        timer.cancel();
      } else if (_sleepTimerRemaining!.inSeconds <= 30) {
        // Fade out volume in the last 30 seconds
        final fadeVolume = _sleepTimerRemaining!.inSeconds / 30.0;
        _player.setVolume(fadeVolume);
      }

      _updateState();
    });

    _updateState();
    Logger.info('Sleep timer set for ${duration.inMinutes} minutes', tag: 'Player');
  }

  /// Cancels the active sleep timer.
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    _sleepTimerRemaining = null;
    _player.setVolume(1.0); // Restore volume
    _updateState();
  }

  void _onSleepTimerEnd() {
    pause();
    _player.setVolume(1.0);
    _sleepTimerRemaining = null;
    _updateState();
    Logger.info('Sleep timer ended', tag: 'Player');
  }

  // --- Crossfade ---

  /// Enables or disables crossfade.
  void setCrossfade(bool enabled, {int? durationMs}) {
    _crossfadeEnabled = enabled;
    if (durationMs != null) {
      _crossfadeDurationMs = durationMs;
    }
    Logger.debug('Crossfade: $_crossfadeEnabled (${_crossfadeDurationMs}ms)', tag: 'Player');
  }

  // --- Private Helpers ---

  /// Builds and sets the ConcatenatingAudioSource from the current queue.
  Future<void> _buildAndSetAudioSource() async {
    final sources = _queue.map((song) {
      // Use content URI on Android for scoped storage compatibility
      final uri = song.uri ?? song.path;
      if (uri.startsWith('content://')) {
        return ja.AudioSource.uri(Uri.parse(uri), tag: _buildMediaItem(song));
      } else {
        return ja.AudioSource.file(song.path, tag: _buildMediaItem(song));
      }
    }).toList();

    _playlist = ja.ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );

    await _player.setAudioSource(_playlist!, initialIndex: _currentIndex);
  }

  /// Rebuilds audio source asynchronously (for queue changes during playback).
  Future<void> _rebuildAudioSourceAsync() async {
    try {
      // Only rebuild if we have a playlist
      if (_playlist == null) return;

      // Save current position
      final currentPosition = _player.position;
      final wasPlaying = _player.playing;

      await _buildAndSetAudioSource();

      // Restore position
      await _player.seek(currentPosition, index: _currentIndex);
      if (wasPlaying) await _player.play();
    } catch (e) {
      Logger.error('Failed to rebuild audio source', error: e);
    }
  }

  MediaItem _buildMediaItem(SongModel song) {
    return MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: song.coverArt != null ? Uri.file(song.coverArt!) : null,
      extras: {'path': song.path},
    );
  }

  // --- Event Handlers ---

  void _onPlayerStateChanged(ja.PlayerState state) {
    _updateState();
  }

  void _onPositionChanged(Duration position) {
    _stateSubject.add(_stateSubject.value.copyWith(position: position));
  }

  void _onDurationChanged(Duration? duration) {
    _stateSubject.add(_stateSubject.value.copyWith(
      duration: duration ?? Duration.zero,
    ));
  }

  void _onBufferedPositionChanged(Duration buffered) {
    _stateSubject.add(_stateSubject.value.copyWith(bufferedPosition: buffered));
  }

  void _onIndexChanged(int? index) {
    if (index != null && index != _currentIndex && index < _queue.length) {
      _currentIndex = index;
      _currentSongSubject.add(currentSong);
      _updateState();
    }
  }

  void _onProcessingStateChanged(ja.ProcessingState state) {
    if (state == ja.ProcessingState.completed) {
      _handleTrackCompletion();
    }
    _updateState();
  }

  void _handleTrackCompletion() {
    if (_repeatMode == app.RepeatMode.one) {
      // Loop mode handles this
      return;
    }

    if (_currentIndex >= _queue.length - 1) {
      if (_repeatMode == app.RepeatMode.all) {
        // Loop mode handles this via ConcatenatingAudioSource
        return;
      }
      // End of queue, stop
      Logger.debug('Queue completed', tag: 'Player');
    }
  }

  void _updateState() {
    final song = currentSong;
    _currentSongSubject.add(song);

    final playerState = _mapProcessingState(_player.processingState);

    _stateSubject.add(AudioPlayerState(
      currentSong: song,
      queue: List.unmodifiable(_queue),
      currentIndex: _currentIndex,
      position: _player.position,
      duration: _player.duration ?? Duration.zero,
      bufferedPosition: _player.bufferedPosition,
      playerState: playerState,
      repeatMode: _repeatMode,
      shuffleMode: _shuffleMode,
      speed: _speed,
      pitch: _pitch,
      volume: _player.volume,
      isPlaying: _player.playing,
      hasNext: _currentIndex < _queue.length - 1 || _repeatMode == app.RepeatMode.all,
      hasPrevious: _currentIndex > 0 || _repeatMode == app.RepeatMode.all,
      sleepTimerRemaining: _sleepTimerRemaining,
    ));
  }

  app.PlayerState _mapProcessingState(ja.ProcessingState state) {
    switch (state) {
      case ja.ProcessingState.idle:
        return app.PlayerState.idle;
      case ja.ProcessingState.loading:
        return app.PlayerState.loading;
      case ja.ProcessingState.buffering:
        return app.PlayerState.buffering;
      case ja.ProcessingState.ready:
        return _player.playing ? app.PlayerState.playing : app.PlayerState.paused;
      case ja.ProcessingState.completed:
        return app.PlayerState.completed;
    }
  }

  void _emitError() {
    _stateSubject.add(_stateSubject.value.copyWith(
      playerState: app.PlayerState.error,
    ));
  }

  void _notifyQueueChanged() {
    _queueSubject.add(List.unmodifiable(_queue));
  }

  /// Disposes all resources.
  Future<void> dispose() async {
    cancelSleepTimer();
    await _player.dispose();
    await _crossfadePlayer?.dispose();
    await _stateSubject.close();
    await _currentSongSubject.close();
    await _queueSubject.close();
  }
}
