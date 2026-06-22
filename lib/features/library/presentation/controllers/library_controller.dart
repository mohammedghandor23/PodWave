import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/data/models/album_model.dart';
import 'package:podwave/features/library/data/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

final librarySongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  await repository.initialize();
  return await repository.getAllSongs();
});

final libraryRefreshProvider = FutureProvider.family<List<SongModel>, bool>((ref, forceRefresh) async {
  final repository = ref.watch(libraryRepositoryProvider);
  await repository.initialize();
  return await repository.getAllSongs(forceRefresh: forceRefresh);
});

final cachedSongsProvider = Provider<List<SongModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getCachedSongs();
});

final cachedAlbumsProvider = Provider<List<AlbumModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getCachedAlbums();
});

final recentlyPlayedSongsProvider = Provider<List<SongModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getRecentlyPlayedSongs(limit: 10);
});

final mostPlayedSongsProvider = Provider<List<SongModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getMostPlayedSongs(limit: 10);
});

final recentlyAddedSongsProvider = Provider<List<SongModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getRecentlyAddedSongs(limit: 10);
});

final recentlyPlayedAlbumsProvider = Provider<List<AlbumModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getRecentlyPlayedAlbums(limit: 10);
});

final mostPlayedAlbumsProvider = Provider<List<AlbumModel>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getMostPlayedAlbums(limit: 10);
});

final libraryLoadingProvider = StateProvider<bool>((ref) => false);

final libraryErrorProvider = StateProvider<String?>((ref) => null);

class LibraryController extends StateNotifier<AsyncValue<List<SongModel>>> {
  final LibraryRepository _repository;
  bool _isInitialized = false;

  LibraryController(this._repository) : super(const AsyncValue.loading());

  Future<void> loadSongs({bool forceRefresh = false}) async {
    if (!_isInitialized) {
      await _repository.initialize();
      _isInitialized = true;
    }

    final cachedSongs = _repository.getCachedSongs();

    if (forceRefresh) {
      state = const AsyncValue.loading();
    } else if (cachedSongs.isNotEmpty) {
      state = AsyncValue.data(cachedSongs);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final freshSongs = await _repository.getAllSongs(forceRefresh: true);

      final hasChanges = _detectChanges(cachedSongs, freshSongs);

      if (hasChanges || state is AsyncLoading) {
        state = AsyncValue.data(freshSongs);
      }
    } catch (e, stackTrace) {
      if (cachedSongs.isEmpty) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  bool _detectChanges(List<SongModel> cached, List<SongModel> fresh) {
    if (cached.length != fresh.length) return true;

    final cachedIds = cached.map((s) => s.id).toSet();
    final freshIds = fresh.map((s) => s.id).toSet();

    if (cachedIds.length != freshIds.length) return true;

    for (final id in freshIds) {
      if (!cachedIds.contains(id)) return true;
    }

    return false;
  }

  Future<void> refreshLibrary() async {
    state = const AsyncValue.loading();
    try {
      await _repository.refreshLibrary();
      final songs = _repository.getCachedSongs();
      state = AsyncValue.data(songs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePlayStats(String songId) async {
    await _repository.updateSongPlayStats(songId);
  }
}

final libraryControllerProvider = StateNotifierProvider<LibraryController, AsyncValue<List<SongModel>>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return LibraryController(repository);
});

final allSongsProvider = Provider<List<SongModel>>((ref) {
  final libraryState = ref.watch(libraryControllerProvider);
  return libraryState.when(
    data: (songs) => songs,
    loading: () => [],
    error: (_, __) => [],
  );
});
