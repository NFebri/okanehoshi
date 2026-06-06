import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'package:okanehoshi/core/network/session_expired_event.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  ApiInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';

    final token = await _secureStorage.read(key: AppConstants.tokenKey);
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
    if (err.response?.statusCode == 401) {
      // Clear token upon unauthorized response
      await _secureStorage.delete(key: AppConstants.tokenKey);
      SessionExpiredEvent.trigger();
    }
    handler.next(err);
  }
}
