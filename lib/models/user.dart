import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role;
  @JsonKey(name: 'isPremium')
  bool _isPremium;
  @JsonKey(fromJson: _dateTimeFromJsonNonNull, toJson: _dateTimeToJsonNonNull)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastLogin;
  final List<String> favoriteSongIds;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.role = 'user',
    bool isPremium = false,
    required this.createdAt,
    this.lastLogin,
    List<String> favoriteSongIds = const [],
  }) : _isPremium = isPremium,
       favoriteSongIds = List<String>.from(favoriteSongIds);

  bool get isPremium => _isPremium;
  set isPremium(bool value) => _isPremium = value;

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? role,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? favoriteSongIds,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isPremium: isPremium ?? this._isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      favoriteSongIds: favoriteSongIds ?? this.favoriteSongIds,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  static DateTime _dateTimeFromJsonNonNull(String date) => DateTime.parse(date);
  static String _dateTimeToJsonNonNull(DateTime date) => date.toIso8601String();
  static DateTime? _dateTimeFromJson(String? date) => date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();
} 