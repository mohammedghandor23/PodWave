import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/data/models/album_model.dart';

/// Centralized Hive initialization and box management.
///
/// All Hive boxes must be registered here before use.
/// This class is the single source of truth for box names and initialization order.
abstract final class HiveBoxNames {
  /// Stores user preferences and app settings (theme, sort order, equalizer, etc.)
  static const String settings = 'settings';

  /// Will store playback position per track for resume functionality.
  /// Key: track file path, Value: last playback position in milliseconds.
  static const String playbackPositions = 'playback_positions';

  /// Will store the user's library scan paths and cached metadata.
  static const String library = 'library';

  /// Will store playlist definitions (name, track IDs, order).
  static const String playlists = 'playlists';

  /// Will store the current queue state for restoring between sessions.
  static const String queue = 'queue';
}

class HiveInitializer {
  const HiveInitializer._();

  /// Initializes Hive and opens all required boxes.
  ///
  /// Must be called before [runApp] in [main].
  /// Add new boxes here as the app grows.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    await _registerAdapters();
    await _openBoxes();
  }

  /// Register all Hive type adapters here before opening boxes.
  static Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SongModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AlbumModelAdapter());
    }
  }

  /// Opens all required Hive boxes.
  ///
  /// Boxes are opened once at startup and remain open for the app's lifetime.
  static Future<void> _openBoxes() async {
    await Hive.openBox<dynamic>(HiveBoxNames.settings);
    await Hive.openBox<dynamic>(HiveBoxNames.playbackPositions);
    await Hive.openBox<dynamic>(HiveBoxNames.library);
    await Hive.openBox<dynamic>(HiveBoxNames.playlists);
    await Hive.openBox<dynamic>(HiveBoxNames.queue);
  }

  /// Closes all open Hive boxes.
  ///
  /// Call this on app termination if needed.
  static Future<void> dispose() async {
    await Hive.close();
  }
}
