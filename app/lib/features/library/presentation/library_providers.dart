import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure.dart';
import '../../auth/presentation/session_controller.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../home/presentation/home_providers.dart';

/// The active profile's saved titles. Guests get an empty list rather than a
/// 401, because the library is account-scoped.
final watchlistProvider = FutureProvider.autoDispose<List<TitleCard>>((ref) {
  final profileId = ref.watch(
    sessionControllerProvider.select((s) => s.activeProfileId),
  );
  if (profileId == null) return const <TitleCard>[];
  return ref.watch(libraryApiProvider).watchlist();
});

/// Mutations that keep every dependent view in sync.
class LibraryController {
  LibraryController(this._ref);

  final Ref _ref;

  Future<bool> toggleWatchlist(String titleId, {required bool saved}) async {
    final api = _ref.read(libraryApiProvider);
    if (saved) {
      await api.removeFromWatchlist(titleId);
    } else {
      await api.addToWatchlist(titleId);
    }
    _ref.invalidate(watchlistProvider);
    _ref.invalidate(homeFeedProvider);
    _ref.invalidate(titleDetailProvider(titleId));
    return !saved;
  }

  Future<void> addToWatchlist(String titleId) async {
    await _ref.read(libraryApiProvider).addToWatchlist(titleId);
    _ref.invalidate(watchlistProvider);
    _ref.invalidate(homeFeedProvider);
    _ref.invalidate(titleDetailProvider(titleId));
  }

  Future<void> removeFromWatchlist(String titleId) async {
    await _ref.read(libraryApiProvider).removeFromWatchlist(titleId);
    _ref.invalidate(watchlistProvider);
    _ref.invalidate(homeFeedProvider);
    _ref.invalidate(titleDetailProvider(titleId));
  }
}

final libraryControllerProvider = Provider<LibraryController>(
  LibraryController.new,
);
