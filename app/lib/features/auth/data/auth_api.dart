import '../../../core/network/api_call.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

/// Typed client for identity endpoints.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return apiCall(() async {
      final response = await _client.rawDio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSession.fromJson(response.data!);
    });
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    return apiCall(() async {
      final response = await _client.rawDio.post<Map<String, dynamic>>(
        '/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );
      return AuthSession.fromJson(response.data!);
    });
  }

  Future<AuthSession> refresh(String refreshToken) async {
    return apiCall(() async {
      final response = await _client.rawDio.post<Map<String, dynamic>>(
        '/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return AuthSession.fromJson(response.data!);
    });
  }

  Future<void> logout(String refreshToken) async {
    await apiCall(() async {
      await _client.rawDio.post<void>(
        '/v1/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    });
  }

  Future<AccountSnapshot> me() async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>('/v1/me');
      return AccountSnapshot.fromJson(response.data!);
    });
  }

  Future<AuthSession> selectProfile({
    required String profileId,
    required String refreshToken,
  }) async {
    return apiCall(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/profiles/$profileId/select',
        data: {'refresh_token': refreshToken},
      );
      return AuthSession.fromJson(response.data!);
    });
  }

  Future<Profile> createProfile({
    required String name,
    required bool isKids,
    required String avatarColor,
    String language = 'en',
  }) async {
    return apiCall(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/profiles',
        data: {
          'name': name,
          'is_kids': isKids,
          'avatar_color': avatarColor,
          'language': language,
        },
      );
      return Profile.fromJson(response.data!);
    });
  }

  Future<Profile> updateProfile({
    required String profileId,
    String? name,
    bool? isKids,
    String? avatarColor,
    String? language,
    bool? autoplayNext,
    bool? autoplayPreviews,
  }) async {
    return apiCall(() async {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        '/v1/profiles/$profileId',
        data: {
          if (name != null) 'name': name,
          if (isKids != null) 'is_kids': isKids,
          if (avatarColor != null) 'avatar_color': avatarColor,
          if (language != null) 'language': language,
          if (autoplayNext != null) 'autoplay_next': autoplayNext,
          if (autoplayPreviews != null) 'autoplay_previews': autoplayPreviews,
        },
      );
      return Profile.fromJson(response.data!);
    });
  }

  Future<void> deleteProfile(String profileId) async {
    await apiCall(() async {
      await _client.dio.delete<void>('/v1/profiles/$profileId');
    });
  }
}
