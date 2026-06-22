import 'package:podwave/features/library/data/models/album_model.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

class LibraryLocalDatasource {
  Future<List<AlbumModel>> getAlbums() async {
    return [];
  }

  Future<List<SongModel>> getSongs() async {
    return [];
  }

  Future<void> saveAlbum(AlbumModel album) async {
  }

  Future<void> saveSong(SongModel song) async {
  }

  Future<void> deleteAlbum(String id) async {
  }

  Future<void> deleteSong(String id) async {
  }

  Future<void> updatePlayCount(String songId, int count) async {
  }

  Future<void> updateLastPlayed(String songId, DateTime time) async {
  }
}
