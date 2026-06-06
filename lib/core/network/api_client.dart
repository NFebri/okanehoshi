import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';
import 'api_interceptor.dart';
import 'retry_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(milliseconds: AppConstants.connectTimeoutMs)
      ..receiveTimeout = const Duration(milliseconds: AppConstants.receiveTimeoutMs);

    final storage = secureStorage ?? const FlutterSecureStorage();
    _dio.interceptors.addAll([
      ApiInterceptor(storage),
      RetryInterceptor(dio: _dio),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Koneksi internet bermasalah. Silakan coba lagi.');
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response == null) {
          return ServerException('Terjadi kesalahan pada server.');
        }
        final statusCode = response.statusCode;
        final data = response.data;

        String message = 'Terjadi kesalahan tidak terduga.';
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'] as String;
        }

        if (statusCode == 401) {
          return UnauthorizedException(message);
        } else if (statusCode == 404) {
          return NotFoundException(message);
        } else if (statusCode == 422) {
          Map<String, List<String>> errors = {};
          if (data is Map<String, dynamic> && data.containsKey('errors')) {
            final errs = data['errors'];
            if (errs is Map<String, dynamic>) {
              errors = errs.map((key, value) {
                if (value is List) {
                  return MapEntry(key, List<String>.from(value));
                } else {
                  return MapEntry(key, [value.toString()]);
                }
              });
            }
          }
          return ValidationException(errors, message);
        } else if (statusCode == 429) {
          return RateLimitException(message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message, statusCode);
        } else {
          return UnknownException(message, statusCode);
        }
      default:
        return UnknownException('Terjadi kesalahan koneksi: ${error.message}');
    }
  }
}
