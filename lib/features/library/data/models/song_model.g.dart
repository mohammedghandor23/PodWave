// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 1;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String?,
      albumId: fields[4] as String?,
      filePath: fields[5] as String,
      duration: Duration(milliseconds: fields[6] as int),
      accentColor: fields[7] as Color?,
      lastPlayed: fields[8] as DateTime?,
      playCount: fields[9] as int,
      isFavorite: fields[10] as bool,
      dateAdded: fields[11] as DateTime?,
      albumArtPath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.albumId)
      ..writeByte(5)
      ..write(obj.filePath)
      ..writeByte(6)
      ..write(obj.durationMillis)
      ..writeByte(7)
      ..write(obj.accentColor)
      ..writeByte(8)
      ..write(obj.lastPlayed)
      ..writeByte(9)
      ..write(obj.playCount)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.dateAdded)
      ..writeByte(12)
      ..write(obj.albumArtPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
