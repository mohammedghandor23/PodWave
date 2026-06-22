// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumModelAdapter extends TypeAdapter<AlbumModel> {
  @override
  final int typeId = 2;

  @override
  AlbumModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlbumModel(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      coverArtPath: fields[3] as String?,
      songCount: fields[5] as int,
      lastPlayed: fields[6] as DateTime?,
      playCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlbumModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.coverArtPath)
      ..writeByte(4)
      ..write(obj.accentColorValue)
      ..writeByte(5)
      ..write(obj.songCount)
      ..writeByte(6)
      ..write(obj.lastPlayed)
      ..writeByte(7)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
