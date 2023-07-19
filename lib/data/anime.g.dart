// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeModelAdapter extends TypeAdapter<EpisodeModel> {
  @override
  final int typeId = 2;

  @override
  EpisodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpisodeModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EpisodeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.number)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.airDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimeModelAdapter extends TypeAdapter<AnimeModel> {
  @override
  final int typeId = 1;

  @override
  AnimeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeModel(
      fields[0] as String,
      fields[1] as int,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as String,
      fields[8] as String?,
      fields[9] as String,
      fields[10] as String,
      fields[11] as String,
      (fields[13] as List).cast<EpisodeModel>(),
      fields[18] as String,
      fields[14] as String,
      fields[15] as String,
      fields[16] as String,
      fields[17] as bool,
      fields[12] as bool,
      fields[19] as int?,
      fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnimeModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.aniId)
      ..writeByte(1)
      ..write(obj.malId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.desc)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.cover)
      ..writeByte(7)
      ..write(obj.releaseDate)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.geners)
      ..writeByte(10)
      ..write(obj.totalEpisodes)
      ..writeByte(11)
      ..write(obj.type)
      ..writeByte(12)
      ..write(obj.is_hentai)
      ..writeByte(13)
      ..write(obj.episodes)
      ..writeByte(14)
      ..write(obj.episodeTitle)
      ..writeByte(15)
      ..write(obj.titles)
      ..writeByte(16)
      ..write(obj.slug)
      ..writeByte(17)
      ..write(obj.is_censored)
      ..writeByte(18)
      ..write(obj.episodeNumber)
      ..writeByte(19)
      ..write(obj.nextAiringEpisode)
      ..writeByte(20)
      ..write(obj.subOrDub);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
