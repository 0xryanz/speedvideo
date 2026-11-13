import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'session_sync.dart';

/// Creates the configured Dio clients and owns authentication interception.
class ApiClient {
  ApiClient({
    required TokenStore tokens,
    required SessionSync sync,
    String? baseUrl,
  }) : _tokens = tokens,
       _sync = sync {
    final options = BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    rawDio = Dio(options);
    dio = Dio(options);
    dio.interceptors.add(
      _AuthInterceptor(
        dio: dio,
        rawDio: rawDio,
        tokens: _tokens,
        sync: _sync,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(_RequestLogger());
      rawDio.interceptors.add(_RequestLogger());
    }
  }

  final TokenStore _tokens;
  final SessionSync _sync;

  late final Dio dio;
  late final Dio rawDio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.dio,
    required this.rawDio,
    required TokenStore tokens,
    required SessionSync sync,
  }) : _tokens = tokens,
       _sync = sync;

  final Dio dio;
  final Dio rawDio;
  final TokenStore _tokens;
  final SessionSync _sync;
  Future<bool>? _refreshInFlight;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final isAuthPath = err.requestOptions.path.contains('/v1/auth/');
    final alreadyRetried = err.requestOptions.extra['auth_retry'] == true;

    if (status != 401 || isAuthPath || alreadyRetried) {
      handler.next(err);
      return;
    }
    if (_tokens.refreshToken == null) {
      handler.next(err);
      return;
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final request = err.requestOptions;
    request.extra['auth_retry'] = true;
    request.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
    try {
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _performRefresh();
    _refreshInFlight = future;
    return future.whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _performRefresh() async {
    final refreshToken = _tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await rawDio.post<Map<String, dynamic>>(
        '/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data == null) return false;
      await _tokens.save(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      _sync.onSessionRefreshed?.call(data);
      return true;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clear();
        _sync.onExpired?.call();
      }
      return false;
    }
  }
}

/// Logs requests without ever printing credentials.
class _RequestLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['started_at'] = DateTime.now().microsecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }

  void _log(RequestOptions options, int? status) {
    final started = options.extra['started_at'] as int?;
    final elapsed = started == null
        ? ''
        : ' ${((DateTime.now().microsecondsSinceEpoch - started) / 1000).round()}ms';
    developer.log(
      '${options.method} ${options.uri.path}$elapsed -> ${status ?? 'ERR'}',
      name: 'api',
    );
  }
}
