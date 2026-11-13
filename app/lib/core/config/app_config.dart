/// Compile-time application configuration.
///
/// Override the API endpoint at build/run time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';

  /// Resolves a server-relative asset path (posters, backdrops) against the
  /// configured API origin. Absolute URLs are returned untouched so the client
  /// can be pointed at a CDN without a code change.
  static String assetUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$apiBaseUrl$path';
  }
}
