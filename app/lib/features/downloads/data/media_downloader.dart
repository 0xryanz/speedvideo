import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

/// Streams a signed grant to a local file. Kept behind an interface so the
/// downloads controller can be tested without network access.
abstract class MediaDownloader {
  Future<void> download({
    required String url,
    required String path,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  });
}

class DioMediaDownloader implements MediaDownloader {
  const DioMediaDownloader(this._client);

  final ApiClient _client;

  @override
  Future<void> download({
    required String url,
    required String path,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    await _client.rawDio.download(
      url,
      path,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        headers: const {'Accept': '*/*'},
      ),
    );
  }
}
