import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    // Check if error is due to connection issues/timeouts
    final isTimeoutOrConnection =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    final isIdempotencyConflict = err.response?.statusCode == 409;

    final retryCount = requestOptions.extra['retry_count'] as int? ?? 0;

    if ((isTimeoutOrConnection || isIdempotencyConflict) && retryCount < maxRetries) {
      final nextRetryCount = retryCount + 1;
      requestOptions.extra['retry_count'] = nextRetryCount;

      final retryAfterHeader = err.response?.headers.value('retry-after');
      final retryAfterSeconds =
          retryAfterHeader != null ? int.tryParse(retryAfterHeader) : null;
      final delay = retryAfterSeconds != null
          ? Duration(seconds: retryAfterSeconds)
          : retryDelay;

      await Future<void>.delayed(delay);

      try {
        final response = await dio.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          cancelToken: requestOptions.cancelToken,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            responseType: requestOptions.responseType,
            contentType: requestOptions.contentType,
            validateStatus: requestOptions.validateStatus,
            receiveTimeout: requestOptions.receiveTimeout,
            sendTimeout: requestOptions.sendTimeout,
          ),
          onSendProgress: requestOptions.onSendProgress,
          onReceiveProgress: requestOptions.onReceiveProgress,
        );
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    return handler.next(err);
  }
}
