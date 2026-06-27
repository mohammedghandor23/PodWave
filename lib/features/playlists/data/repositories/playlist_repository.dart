import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/core/storage/hive_initializer.dart';
import 'package:podwave/features/playlists/data/models/playlist_model.dart';

class PlaylistRepository {
  Box<PlaylistModel> get _box =>
      Hive.box<PlaylistModel>(HiveBoxNames.playlists);

  List<PlaylistModel> getAllPlaylists() {
    return _box.values.toList();
  }

  PlaylistModel? getPlaylist(String id) {
    return _box.get(id);
  }

  Future<void> savePlaylist(PlaylistModel playlist) async {
    await _box.put(playlist.id, playlist);
  }

  Future<void> deletePlaylist(String id) async {
    await _box.delete(id);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = _box.get(playlistId);
    if (playlist == null) return;
    if (playlist.songIds.contains(songId)) return;
    final updated = playlist.copyWith(
      songIds: [...playlist.songIds, songId],
    );
    await _box.put(playlistId, updated);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _box.get(playlistId);
    if (playlist == null) return;
    final updated = playlist.copyWith(
      songIds: playlist.songIds.where((id) => id != songId).toList(),
    );
    await _box.put(playlistId, updated);
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlist = _box.get(playlistId);
    if (playlist == null) return;
    final updated = playlist.copyWith(name: newName);
    await _box.put(playlistId, updated);
  }
}
