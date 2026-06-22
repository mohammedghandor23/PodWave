import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class SongModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String artist;
  @HiveField(3)
  final String? album;
  @HiveField(4)
  final String? albumId;
  @HiveField(5)
  final String filePath;
  @HiveField(6)
  final int durationMillis;

  Duration get duration => Duration(milliseconds: durationMillis);
  @HiveField(7)
  final Color? accentColor;
  @HiveField(8)
  final DateTime? lastPlayed;
  @HiveField(9)
  final int playCount;
  @HiveField(10)
  final bool isFavorite;
  @HiveField(11)
  final DateTime? dateAdded;
  @HiveField(12)
  final String? albumArtPath;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumId,
    required this.filePath,
    required Duration duration,
    this.accentColor,
    this.lastPlayed,
    this.playCount = 0,
    this.isFavorite = false,
    this.dateAdded,
    this.albumArtPath,
  }) : durationMillis = duration.inMilliseconds;

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumId,
    String? filePath,
    Duration? duration,
    Color? accentColor,
    DateTime? lastPlayed,
    int? playCount,
    bool? isFavorite,
    DateTime? dateAdded,
    String? albumArtPath,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      accentColor: accentColor ?? this.accentColor,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      albumArtPath: albumArtPath ?? this.albumArtPath,
    );
  }
}
