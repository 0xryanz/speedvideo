// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String? ?? '',
  plan: json['plan'] as String? ?? 'standard',
  role: json['role'] as String? ?? 'member',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'plan': instance.plan,
  'role': instance.role,
  'created_at': ?instance.createdAt?.toIso8601String(),
};

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarColor: json['avatar_color'] as String? ?? '#E50914',
  isKids: json['is_kids'] as bool? ?? false,
  language: json['language'] as String? ?? 'en',
  autoplayNext: json['autoplay_next'] as bool? ?? true,
  autoplayPreviews: json['autoplay_previews'] as bool? ?? true,
  maturityRating: json['maturity_rating'] as String? ?? '18+',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_color': instance.avatarColor,
  'is_kids': instance.isKids,
  'language': instance.language,
  'autoplay_next': instance.autoplayNext,
  'autoplay_previews': instance.autoplayPreviews,
  'maturity_rating': instance.maturityRating,
  'created_at': ?instance.createdAt?.toIso8601String(),
};

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String? ?? 'Bearer',
  expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  profiles:
      (json['profiles'] as List<dynamic>?)
          ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Profile>[],
  activeProfileId: json['active_profile_id'] as String?,
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'expires_at': ?instance.expiresAt?.toIso8601String(),
      'user': instance.user.toJson(),
      'profiles': instance.profiles.map((e) => e.toJson()).toList(),
      'active_profile_id': ?instance.activeProfileId,
    };

_AccountSnapshot _$AccountSnapshotFromJson(Map<String, dynamic> json) =>
    _AccountSnapshot(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      profiles:
          (json['profiles'] as List<dynamic>?)
              ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Profile>[],
      activeProfileId: json['active_profile_id'] as String?,
    );

Map<String, dynamic> _$AccountSnapshotToJson(_AccountSnapshot instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'profiles': instance.profiles.map((e) => e.toJson()).toList(),
      'active_profile_id': ?instance.activeProfileId,
    };
