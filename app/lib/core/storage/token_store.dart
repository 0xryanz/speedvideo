import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the rotating token pair in the platform keystore/keychain.
///
/// Access tokens are short-lived and kept in memory as well as on disk so the
/// Dio interceptor can attach them synchronously. Refresh tokens never leave
/// secure storage except through the auth API.
///
/// Desktop debug builds signed ad-hoc cannot access the macOS keychain
/// without a provisioning profile; they may provide fallback preferences so
/// UI development still works. Fallbacks are disabled in production.
class TokenStore {
  TokenStore({
    FlutterSecureStorage? storage,
    SharedPreferences? fallback,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _fallback = fallback;

  static const _accessKey = 'speedvideo.access_token';
  static const _refreshKey = 'speedvideo.refresh_token';

  final FlutterSecureStorage _storage;
  final SharedPreferences? _fallback;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasSession => _refreshToken != null;

  Future<void> load() async {
    _accessToken = await _read(_accessKey);
    _refreshToken = await _read(_refreshKey);
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _write(_accessKey, accessToken);
    await _write(_refreshKey, refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _delete(_accessKey);
    await _delete(_refreshKey);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (error) {
      if (_fallback == null || !kDebugMode) rethrow;
      debugPrint(
        'Secure storage unavailable, using development fallback: $error',
      );
      return _fallback.getString(key);
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error) {
      if (_fallback == null || !kDebugMode) rethrow;
      debugPrint(
        'Secure storage unavailable, using development fallback: $error',
      );
      await _fallback.setString(key, value);
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error) {
      if (_fallback == null || !kDebugMode) rethrow;
      debugPrint(
        'Secure storage unavailable, using development fallback: $error',
      );
      await _fallback.remove(key);
    }
  }
}
