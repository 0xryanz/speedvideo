import 'package:dio/dio.dart';

/// A typed API failure carrying the API's stable error code.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code = 'internal_error',
    this.statusCode,
  });

  final String message;
  final String code;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final envelope = data['error'];
      if (envelope is Map<String, dynamic>) {
        return ApiException(
          message: envelope['message'] as String? ?? 'Something went wrong.',
          code: envelope['code'] as String? ?? 'internal_error',
          statusCode: response?.statusCode,
        );
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'The request timed out. Please try again.',
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Cannot reach SpeedVideo. Check your connection.',
          code: 'network_unavailable',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled.',
          code: 'cancelled',
        );
      default:
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: response?.statusCode,
        );
    }
  }

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
