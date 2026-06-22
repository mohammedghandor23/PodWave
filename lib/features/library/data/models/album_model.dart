import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/core/theme/app_colors.dart';

part 'album_model.g.dart';

@HiveType(typeId: 2)
class AlbumModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String artist;
  @HiveField(3)
  final String? coverArtPath;
  @HiveField(4)
  final int accentColorValue;
  @HiveField(5)
  final int songCount;
  @HiveField(6)
  final DateTime? lastPlayed;
  @HiveField(7)
  final int playCount;

  Color get accentColor => Color(accentColorValue);

  AlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    this.coverArtPath,
    Color? accentColor,
    this.songCount = 0,
    this.lastPlayed,
    this.playCount = 0,
  }) : accentColorValue = (accentColor ?? AppColors.primary).value;

  AlbumModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverArtPath,
    Color? accentColor,
    int? songCount,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      accentColor: accentColor ?? Color(accentColorValue),
      songCount: songCount ?? this.songCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }
}
