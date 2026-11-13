import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/core/network/api_exception.dart';

void main() {
  test('maps the API error envelope', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/v1/auth/login'),
      response: Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/v1/auth/login'),
        statusCode: 401,
        data: {
          'error': {
            'code': 'unauthorized',
            'message': 'invalid email or password',
          },
        },
      ),
    );

    final mapped = ApiException.fromDio(error);
    expect(mapped.code, 'unauthorized');
    expect(mapped.statusCode, 401);
    expect(mapped.message, 'invalid email or password');
    expect(mapped.isUnauthorized, isTrue);
  });

  test('maps connection failures to a network code', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/v1/home'),
      type: DioExceptionType.connectionError,
    );
    final mapped = ApiException.fromDio(error);
    expect(mapped.code, 'network_unavailable');
    expect(mapped.isNetworkError, isTrue);
  });
}
