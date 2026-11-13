import '../../../core/network/api_call.dart';
import '../../../core/network/api_client.dart';
import '../../catalog/domain/catalog_models.dart';

/// Typed client for the profile-scoped library endpoints.
class LibraryApi {
  const LibraryApi(this._client);

  final ApiClient _client;

  Future<List<TitleCard>> watchlist() async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/watchlist',
      );
      final raw = response.data?['items'] as List<dynamic>? ?? [];
      return raw
          .cast<Map<String, dynamic>>()
          .map(TitleCard.fromJson)
          .toList(growable: false);
    });
  }

  Future<void> addToWatchlist(String titleId) async {
    await apiCall(() async {
      await _client.dio.put<void>('/v1/watchlist/$titleId');
    });
  }

  Future<void> removeFromWatchlist(String titleId) async {
    await apiCall(() async {
      await _client.dio.delete<void>('/v1/watchlist/$titleId');
    });
  }

  Future<void> saveProgress({
    required String titleId,
    String? episodeId,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    await apiCall(() async {
      await _client.dio.put<void>(
        '/v1/progress/$titleId',
        data: {
          if (episodeId != null && episodeId.isNotEmpty)
            'episode_id': episodeId,
          'position_seconds': positionSeconds,
          'duration_seconds': durationSeconds,
        },
      );
    });
  }
}
