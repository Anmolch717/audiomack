// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  album: json['album'] as String,
  filePath: json['filePath'] as String,
  coverImagePath: json['coverImagePath'] as String?,
  duration: Song._durationFromJson((json['duration'] as num).toInt()),
  uploadedBy: json['uploadedBy'] as String,
  uploadedAt: Song._dateTimeFromJson(json['uploadedAt'] as String),
  isPremium: json['isPremium'] as bool? ?? false,
  playCount: (json['playCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'album': instance.album,
  'filePath': instance.filePath,
  'coverImagePath': instance.coverImagePath,
  'duration': Song._durationToJson(instance.duration),
  'uploadedBy': instance.uploadedBy,
  'uploadedAt': Song._dateTimeToJson(instance.uploadedAt),
  'isPremium': instance.isPremium,
  'playCount': instance.playCount,
};
