import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podwave/core/audio/media_notification_service.dart';
import 'package:podwave/core/constants/app_durations.dart';
import 'package:podwave/core/storage/playback_position_service.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  final _currentSongController = BehaviorSubject<SongModel?>();
  final _isPlayingController = BehaviorSubject<bool>.seeded(false);
  final _positionController = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _durationController = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _isInitializedController = BehaviorSubject<bool>.seeded(false);

  List<SongModel> _queue = [];
  int _currentIndex = -1;

  final PlaybackPositionService _positionService = PlaybackPositionService();
  Timer? _positionSaveTimer;

  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get isInitializedStream => _isInitializedController.stream;

  SongModel? get currentSong => _currentSongController.valueOrNull;
  List<SongModel> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex >= 0 && _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  bool get isPlaying => _isPlayingController.valueOrNull ?? false;
  Duration get position => _positionController.valueOrNull ?? Duration.zero;
  Duration get duration => _durationController.valueOrNull ?? Duration.zero;
  AudioPlayer get player => _player;

  Future<void> initialize() async {
    try {
      await MediaNotificationService.instance.initialize(
        onRewind: () => seekBackward(const Duration(seconds: 10)),
        onStop: () => stop(),
        onForward: () => seekForward(const Duration(seconds: 10)),
      );
    } catch (e) {
      debugPrint('MediaNotificationService initialization error: $e');
    }

    try {
      _player.positionStream.listen((position) {
        _positionController.add(position);
      });

      _player.playingStream.listen((playing) {
        if (playing) {
          _startPositionSaveTimer();
        } else {
          _stopPositionSaveTimer();
        }
      });

      _player.durationStream.listen((duration) {
        if (duration != null) {
          _durationController.add(duration);
        }
      });

      _player.playingStream.listen((playing) {
        _isPlayingController.add(playing);
        final song = _currentSongController.valueOrNull;
        if (song != null) {
          MediaNotificationService.instance.show(song, isPlaying: playing);
        }
      });

      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _isPlayingController.add(false);
          _positionController.add(Duration.zero);
          _clearPositionForCurrentSong();
          MediaNotificationService.instance.cancel();
        }
      });

      _isInitializedController.add(true);
    } catch (e) {
      debugPrint('AudioPlayerService initialization error: $e');
    }
  }

  /// Gets the saved position for a song before playing.
  /// Returns null if no position exists.
  Duration? getSavedPosition(String songId) {
    final positionMs = _positionService.getPosition(songId);
    if (positionMs != null) {
      return Duration(milliseconds: positionMs);
    }
    return null;
  }

  void setQueue(List<SongModel> songs, int index) {
    _queue = List.from(songs);
    _currentIndex = index.clamp(0, songs.length - 1);
  }

  Future<void> playSong(SongModel song, {Duration? startPosition, List<SongModel>? queue, int? queueIndex}) async {
    try {
      if (queue != null && queueIndex != null) {
        setQueue(queue, queueIndex);
      } else if (_queue.isEmpty || !_queue.any((s) => s.id == song.id)) {
        _queue = [song];
        _currentIndex = 0;
      } else {
        _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      }

      final audioSource = AudioSource.file(song.filePath);
      await _player.setAudioSource(audioSource);
      _currentSongController.add(song);

      if (startPosition != null) {
        await _player.seek(startPosition);
      }

      await _player.play();
      await MediaNotificationService.instance.show(song, isPlaying: true);
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    _currentIndex++;
    await playSong(_queue[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (!hasPrevious) return;
    _currentIndex--;
    await playSong(_queue[_currentIndex]);
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekForward(Duration duration) async {
    final newPosition = _player.position + duration;
    await seek(newPosition);
  }

  Future<void> seekBackward(Duration duration) async {
    final newPosition = _player.position - duration;
    if (newPosition.isNegative) {
      await seek(Duration.zero);
    } else {
      await seek(newPosition);
    }
  }

  Future<void> seekToPosition(double progress) async {
    final totalDuration = _player.duration ?? Duration.zero;
    final position = Duration(
      milliseconds: (totalDuration.inMilliseconds * progress).round(),
    );
    await seek(position);
  }

  Future<void> stop() async {
    await _saveCurrentPosition();
    _stopPositionSaveTimer();
    await _player.stop();
    _currentSongController.add(null);
    _positionController.add(Duration.zero);
    await MediaNotificationService.instance.cancel();
  }

  void _startPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(
      AppDurations.positionSaveInterval,
      (_) => _saveCurrentPosition(),
    );
  }

  void _stopPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
  }

  Future<void> _saveCurrentPosition() async {
    final song = _currentSongController.valueOrNull;
    final position = _positionController.valueOrNull;
    final duration = _durationController.valueOrNull;

    if (song != null && position != null && duration != null) {
      await _positionService.savePosition(
        song.id,
        position.inMilliseconds,
        duration.inMilliseconds,
      );
    }
  }

  void _clearPositionForCurrentSong() {
    final song = _currentSongController.valueOrNull;
    if (song != null) {
      _positionService.clearPosition(song.id);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _currentSongController.close();
    await _isPlayingController.close();
    await _positionController.close();
    await _durationController.close();
    await _isInitializedController.close();
  }
}
