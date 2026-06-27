import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/features/playlists/data/models/playlist_model.dart';
import 'package:podwave/features/playlists/data/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, List<PlaylistModel>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return PlaylistController(repo);
});

class PlaylistController extends StateNotifier<List<PlaylistModel>> {
  final PlaylistRepository _repo;
  PlaylistController(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAllPlaylists();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      isDefault: false,
    );
    await _repo.savePlaylist(playlist);
    _load();
  }

  Future<void> deletePlaylist(String id) async {
    await _repo.deletePlaylist(id);
    _load();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    await _repo.renamePlaylist(id, newName);
    _load();
  }

  Future<void> addSongsToPlaylist(String playlistId, List<String> songIds) async {
    for (final songId in songIds) {
      await _repo.addSongToPlaylist(playlistId, songId);
    }
    _load();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _repo.removeSongFromPlaylist(playlistId, songId);
    _load();
  }

  PlaylistModel? getPlaylist(String id) => _repo.getPlaylist(id);
}
