import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Runs an API call and normalises transport failures into [ApiException].
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw ApiException.fromDio(error);
  }
}
