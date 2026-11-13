import '../../../core/network/api_call.dart';
import '../../../core/network/api_client.dart';
import '../domain/playback_models.dart';

/// Typed client for signed playback sessions.
class PlaybackApi {
  const PlaybackApi(this._client);

  final ApiClient _client;

  Future<PlaybackInfo> create({
    required String titleId,
    String? episodeId,
  }) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/playback/$titleId',
        queryParameters: {
          if (episodeId != null && episodeId.isNotEmpty)
            'episode_id': episodeId,
        },
      );
      return PlaybackInfo.fromJson(response.data!);
    });
  }
}
