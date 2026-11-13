import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    @Default('') String displayName,
    @Default('standard') String plan,
    @Default('member') String role,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    @Default('#E50914') String avatarColor,
    @Default(false) bool isKids,
    @Default('en') String language,
    @Default(true) bool autoplayNext,
    @Default(true) bool autoplayPreviews,
    @Default('18+') String maturityRating,
    DateTime? createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    @Default('Bearer') String tokenType,
    @Default(0) int expiresIn,
    DateTime? expiresAt,
    required User user,
    @Default(<Profile>[]) List<Profile> profiles,
    String? activeProfileId,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

@freezed
abstract class AccountSnapshot with _$AccountSnapshot {
  const factory AccountSnapshot({
    required User user,
    @Default(<Profile>[]) List<Profile> profiles,
    String? activeProfileId,
  }) = _AccountSnapshot;

  factory AccountSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AccountSnapshotFromJson(json);
}
