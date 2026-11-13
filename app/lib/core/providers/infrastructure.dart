import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_api.dart';
import '../../features/catalog/data/catalog_api.dart';
import '../../features/library/data/library_api.dart';
import '../../features/playback/data/playback_api.dart';
import '../network/api_client.dart';
import '../network/session_sync.dart';
import '../storage/token_store.dart';

/// Overridden in `main` after asynchronous platform bootstrap.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider was not overridden'),
);

/// Overridden in `main` after secure storage has been loaded.
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => throw UnimplementedError('tokenStoreProvider was not overridden'),
);

final sessionSyncProvider = Provider<SessionSync>((ref) => SessionSync());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokens: ref.watch(tokenStoreProvider),
    sync: ref.watch(sessionSyncProvider),
  );
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final catalogApiProvider = Provider<CatalogApi>(
  (ref) => CatalogApi(ref.watch(apiClientProvider)),
);

final libraryApiProvider = Provider<LibraryApi>(
  (ref) => LibraryApi(ref.watch(apiClientProvider)),
);

final playbackApiProvider = Provider<PlaybackApi>(
  (ref) => PlaybackApi(ref.watch(apiClientProvider)),
);
