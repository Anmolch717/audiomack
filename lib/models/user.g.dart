// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  role: json['role'] as String? ?? 'user',
  isPremium: json['isPremium'] as bool? ?? false,
  createdAt: User._dateTimeFromJsonNonNull(json['createdAt'] as String),
  lastLogin: User._dateTimeFromJson(json['lastLogin'] as String?),
  favoriteSongIds:
      (json['favoriteSongIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'createdAt': User._dateTimeToJsonNonNull(instance.createdAt),
  'lastLogin': User._dateTimeToJson(instance.lastLogin),
  'favoriteSongIds': instance.favoriteSongIds,
  'isPremium': instance.isPremium,
};
