import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/data/models/album_model.dart';
import 'package:podwave/features/library/data/services/audio_query_service.dart';

class LibraryRepository {
  static const String _songsBoxName = 'library_songs';
  static const String _albumsBoxName = 'library_albums';
  static const String _cacheKey = 'last_scan_timestamp';

  final AudioQueryService _audioQueryService = AudioQueryService();

  Box<SongModel>? _songsBox;
  Box<AlbumModel>? _albumsBox;
  Box<dynamic>? _metadataBox;

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SongModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AlbumModelAdapter());
    }

    _songsBox = await Hive.openBox<SongModel>(_songsBoxName);
    _albumsBox = await Hive.openBox<AlbumModel>(_albumsBoxName);
    _metadataBox = await Hive.openBox('library_metadata');
  }

  Future<List<SongModel>> getAllSongs({bool forceRefresh = false}) async {
    await _ensureInitialized();

    if (!forceRefresh && _songsBox!.isNotEmpty) {
      return _songsBox!.values.toList();
    }

    final hasPermission = await _audioQueryService.checkPermission();
    if (!hasPermission) {
      final granted = await _audioQueryService.requestPermission();
      if (!granted) {
        return _songsBox!.isNotEmpty ? _songsBox!.values.toList() : [];
      }
    }

    final songs = await _audioQueryService.querySongs();
    await _cacheSongs(songs);
    return songs;
  }

  Future<void> refreshLibrary() async {
    await _ensureInitialized();

    final hasPermission = await _audioQueryService.checkPermission();
    if (!hasPermission) {
      final granted = await _audioQueryService.requestPermission();
      if (!granted) return;
    }

    final songs = await _audioQueryService.querySongs();
    await _cacheSongs(songs);

    final albums = await _audioQueryService.queryAlbums();
    await _cacheAlbums(albums);

    await _metadataBox?.put(_cacheKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _cacheSongs(List<SongModel> songs) async {
    await _songsBox?.clear();
    final Map<String, SongModel> songMap = {};
    for (final song in songs) {
      songMap[song.id] = song;
    }
    await _songsBox?.putAll(songMap);
  }

  Future<void> _cacheAlbums(List<AlbumModel> albums) async {
    await _albumsBox?.clear();
    final Map<String, AlbumModel> albumMap = {};
    for (final album in albums) {
      albumMap[album.id] = album;
    }
    await _albumsBox?.putAll(albumMap);
  }

  List<SongModel> getCachedSongs() {
    if (_songsBox == null) return [];
    return _songsBox!.values.toList();
  }

  List<AlbumModel> getCachedAlbums() {
    if (_albumsBox == null) return [];
    return _albumsBox!.values.toList();
  }

  List<SongModel> getRecentlyPlayedSongs({int limit = 10}) {
    final songs = getCachedSongs()
        .where((s) => s.lastPlayed != null)
        .toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
    return songs.take(limit).toList();
  }

  List<SongModel> getRecentlyAddedSongs({int limit = 10}) {
    final songs = getCachedSongs()
        .where((s) => s.dateAdded != null)
        .toList()
      ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    if (songs.length >= limit) return songs.take(limit).toList();
    final all = getCachedSongs().toList()
      ..sort((a, b) => (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));
    return all.take(limit).toList();
  }

  List<SongModel> getMostPlayedSongs({int limit = 10}) {
    final songs = getCachedSongs()
        .where((s) => s.playCount > 0)
        .toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    return songs.take(limit).toList();
  }

  List<AlbumModel> getRecentlyPlayedAlbums({int limit = 10}) {
    final albums = getCachedAlbums()
        .where((a) => a.lastPlayed != null)
        .toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
    return albums.take(limit).toList();
  }

  List<AlbumModel> getMostPlayedAlbums({int limit = 10}) {
    final albums = getCachedAlbums()
        .where((a) => a.playCount > 0)
        .toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    return albums.take(limit).toList();
  }

  List<SongModel> searchSongs(String query) {
    final lowerQuery = query.toLowerCase();
    return getCachedSongs().where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<AlbumModel> searchAlbums(String query) {
    final lowerQuery = query.toLowerCase();
    return getCachedAlbums().where((album) {
      return album.title.toLowerCase().contains(lowerQuery) ||
          album.artist.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> updateSongPlayStats(String songId, {DateTime? playedAt}) async {
    final song = _songsBox?.get(songId);
    if (song != null) {
      final updatedSong = song.copyWith(
        lastPlayed: playedAt ?? DateTime.now(),
        playCount: song.playCount + 1,
      );
      await _songsBox?.put(songId, updatedSong);
    }

    final albumId = song?.albumId;
    if (albumId != null) {
      final album = _albumsBox?.get(albumId);
      if (album != null) {
        final updatedAlbum = album.copyWith(
          lastPlayed: playedAt ?? DateTime.now(),
          playCount: album.playCount + 1,
        );
        await _albumsBox?.put(albumId, updatedAlbum);
      }
    }
  }

  Future<void> toggleFavorite(String songId) async {
    final song = _songsBox?.get(songId);
    if (song != null) {
      final updatedSong = song.copyWith(isFavorite: !song.isFavorite);
      await _songsBox?.put(songId, updatedSong);
    }
  }

  List<SongModel> getFavoriteSongs() {
    return getCachedSongs().where((s) => s.isFavorite).toList();
  }

  Future<void> _ensureInitialized() async {
    if (_songsBox == null || !_songsBox!.isOpen) {
      await initialize();
    }
  }

  Future<void> close() async {
    await _songsBox?.close();
    await _albumsBox?.close();
    await _metadataBox?.close();
  }
}
