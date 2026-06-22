import 'package:flutter/material.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

class FolderModel {
  final String id;
  final String name;
  final String? artist;
  final String? path;
  final List<SongModel> songs;
  final Color? accentColor;
  final DateTime? lastPlayed;
  final int playCount;

  const FolderModel({
    required this.id,
    required this.name,
    this.artist,
    this.path,
    required this.songs,
    this.accentColor,
    this.lastPlayed,
    this.playCount = 0,
  });

  int get songCount => songs.length;

  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  FolderModel copyWith({
    String? id,
    String? name,
    String? artist,
    String? path,
    List<SongModel>? songs,
    Color? accentColor,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      path: path ?? this.path,
      songs: songs ?? this.songs,
      accentColor: accentColor ?? this.accentColor,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }
}
