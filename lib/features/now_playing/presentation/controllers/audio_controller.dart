import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/core/audio/audio_player_service.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

final audioServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

final currentSongProvider = StreamProvider<SongModel?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.currentSongStream;
});

final isPlayingProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.isPlayingStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

final durationProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});

final isAudioInitializedProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.isInitializedStream;
});

final hasNextProvider = Provider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  ref.watch(currentSongProvider);
  return audioService.hasNext;
});

final hasPreviousProvider = Provider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  ref.watch(currentSongProvider);
  return audioService.hasPrevious;
});

final audioControllerProvider = StateNotifierProvider<AudioController, AsyncValue<void>>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioController(audioService);
});

class AudioController extends StateNotifier<AsyncValue<void>> {
  final AudioPlayerService _audioService;

  AudioController(this._audioService) : super(const AsyncValue.data(null));

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      await _audioService.initialize();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Gets the saved position for a song.
  /// Returns null if no position exists.
  Duration? getSavedPosition(String songId) {
    return _audioService.getSavedPosition(songId);
  }

  bool get hasNext => _audioService.hasNext;
  bool get hasPrevious => _audioService.hasPrevious;

  Future<void> playSong(SongModel song, {Duration? startPosition, List<SongModel>? queue, int? queueIndex}) async {
    state = const AsyncValue.loading();
    try {
      await _audioService.playSong(song, startPosition: startPosition, queue: queue, queueIndex: queueIndex);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> playNext() async {
    state = const AsyncValue.loading();
    try {
      await _audioService.playNext();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> playPrevious() async {
    state = const AsyncValue.loading();
    try {
      await _audioService.playPrevious();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> play() async {
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Future<void> seek(double progress) async {
    await _audioService.seekToPosition(progress);
  }

  Future<void> seekForward10Seconds() async {
    await _audioService.seekForward(const Duration(seconds: 10));
  }

  Future<void> seekBackward10Seconds() async {
    await _audioService.seekBackward(const Duration(seconds: 10));
  }

  Future<void> stop() async {
    await _audioService.stop();
  }
}
