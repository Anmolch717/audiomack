import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable()
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final String? coverImagePath;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  final String uploadedBy;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime uploadedAt;
  final bool isPremium;
  final int playCount;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    this.coverImagePath,
    required this.duration,
    required this.uploadedBy,
    required this.uploadedAt,
    this.isPremium = false,
    this.playCount = 0,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
  
  static Duration _durationFromJson(int microseconds) => Duration(microseconds: microseconds);
  static int _durationToJson(Duration duration) => duration.inMicroseconds;

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    String? coverImagePath,
    Duration? duration,
    String? uploadedBy,
    DateTime? uploadedAt,
    bool? isPremium,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      duration: duration ?? this.duration,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isPremium: isPremium ?? this.isPremium,
      playCount: playCount ?? this.playCount,
    );
  }
} 