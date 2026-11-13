import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure.dart';
import '../../auth/presentation/session_controller.dart';
import '../domain/catalog_models.dart';

typedef SearchRequest = ({String query, String? genre});

/// Genres are public to signed-in profiles and cached for the session.
final genresProvider = FutureProvider.autoDispose<List<Genre>>((ref) {
  return ref.watch(catalogApiProvider).genres();
});

/// Refetches automatically when the active profile changes (kids filtering).
final titleDetailProvider = FutureProvider.autoDispose
    .family<TitleDetail, String>((ref, titleId) {
      ref.watch(sessionControllerProvider.select((s) => s.activeProfileId));
      return ref.watch(catalogApiProvider).detail(titleId);
    });

final similarTitlesProvider = FutureProvider.autoDispose
    .family<List<TitleCard>, String>((ref, titleId) {
      ref.watch(sessionControllerProvider.select((s) => s.activeProfileId));
      return ref.watch(catalogApiProvider).similar(titleId);
    });

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<TitleCard>, SearchRequest>((ref, request) {
      ref.watch(sessionControllerProvider.select((s) => s.activeProfileId));
      final api = ref.watch(catalogApiProvider);
      if (request.query.length >= 2) {
        return api.search(request.query);
      }
      if (request.genre != null) {
        return api
            .browse(genre: request.genre, pageSize: 30)
            .then((page) => page.items);
      }
      return Future.value(const <TitleCard>[]);
    });

/// "New & Hot" combines the newest arrivals with the best-rated catalogue.
final newHotProvider =
    FutureProvider.autoDispose<({BrowsePage newest, BrowsePage popular})>((
      ref,
    ) {
      ref.watch(sessionControllerProvider.select((s) => s.activeProfileId));
      final api = ref.watch(catalogApiProvider);
      return Future.wait([
        api.browse(sort: 'newest', pageSize: 24),
        api.browse(sort: 'rating', pageSize: 24),
      ]).then(
        (pages) => (
          newest: pages[0],
          popular: pages[1],
        ),
      );
    });
