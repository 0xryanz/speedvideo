import '../../../core/network/api_call.dart';
import '../../../core/network/api_client.dart';
import '../domain/download_models.dart';

/// Typed client for signed offline-download grants.
class DownloadApi {
  const DownloadApi(this._client);

  final ApiClient _client;

  Future<DownloadSession> create({
    required String titleId,
    String? episodeId,
  }) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/downloads/$titleId',
        queryParameters: {
          if (episodeId != null && episodeId.isNotEmpty)
            'episode_id': episodeId,
        },
      );
      return DownloadSession.fromJson(response.data!);
    });
  }
}
