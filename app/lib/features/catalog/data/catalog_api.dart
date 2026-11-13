import '../../../core/network/api_call.dart';
import '../../../core/network/api_client.dart';
import '../../home/domain/home_models.dart';
import '../domain/catalog_models.dart';

/// Typed client for catalogue and home-feed endpoints.
class CatalogApi {
  const CatalogApi(this._client);

  final ApiClient _client;

  Future<HomeFeed> home() async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>('/v1/home');
      return HomeFeed.fromJson(response.data!);
    });
  }

  Future<TitleDetail> detail(String titleId) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/titles/$titleId',
      );
      return TitleDetail.fromJson(response.data!);
    });
  }

  Future<List<TitleCard>> similar(String titleId) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/titles/$titleId/similar',
      );
      return _items(response.data);
    });
  }

  Future<List<TitleCard>> search(String query) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/search',
        queryParameters: {'q': query},
      );
      return _items(response.data);
    });
  }

  Future<List<Genre>> genres() async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/genres',
      );
      final raw = response.data!['genres'] as List<dynamic>? ?? [];
      return raw
          .cast<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(growable: false);
    });
  }

  Future<BrowsePage> browse({
    String? kind,
    String? genre,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) async {
    return apiCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v1/titles',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (kind != null) 'kind': kind,
          if (genre != null) 'genre': genre,
          if (sort != null) 'sort': sort,
        },
      );
      return BrowsePage.fromJson(response.data!);
    });
  }

  List<TitleCard> _items(Map<String, dynamic>? data) {
    final raw = data?['items'] as List<dynamic>? ?? [];
    return raw
        .cast<Map<String, dynamic>>()
        .map(TitleCard.fromJson)
        .toList(growable: false);
  }
}
