import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/core/storage/hive_initializer.dart';

/// Service for managing playback positions per song.
///
/// Key: song file path (unique identifier)
/// Value: last playback position in milliseconds
class PlaybackPositionService {
  static final PlaybackPositionService _instance = PlaybackPositionService._internal();
  factory PlaybackPositionService() => _instance;
  PlaybackPositionService._internal();

  Box<dynamic>? _box;

  Box<dynamic> get _positionsBox {
    _box ??= Hive.box(HiveBoxNames.playbackPositions);
    return _box!;
  }

  /// Minimum duration before saving position (10 seconds)
  static const int _minPositionMs = 10000;

  /// Maximum duration from end to skip saving (30 seconds from end)
  static const int _maxRemainingMs = 30000;

  /// Saves the playback position for a song.
  /// Only saves if:
  /// - Position is greater than min threshold (10s)
  /// - Remaining time is greater than threshold (30s from end)
  Future<void> savePosition(String songId, int positionMs, int totalDurationMs) async {
    if (positionMs < _minPositionMs) {
      return;
    }

    final remainingMs = totalDurationMs - positionMs;
    if (remainingMs < _maxRemainingMs) {
      await _positionsBox.delete(songId);
      return;
    }

    await _positionsBox.put(songId, positionMs);
  }

  /// Gets the saved position for a song.
  /// Returns null if no position saved or position was cleared.
  int? getPosition(String songId) {
    final position = _positionsBox.get(songId);
    if (position == null) return null;
    if (position is int) return position;
    return null;
  }

  /// Clears the saved position for a song.
  /// Called when song completes naturally.
  Future<void> clearPosition(String songId) async {
    await _positionsBox.delete(songId);
  }

  /// Clears all saved positions.
  Future<void> clearAllPositions() async {
    await _positionsBox.clear();
  }
}
