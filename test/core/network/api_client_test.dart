import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/constants/app_constants.dart';
import 'package:okanehoshi/core/network/api_interceptor.dart';
import 'package:okanehoshi/core/network/session_expired_event.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late ApiInterceptor apiInterceptor;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    apiInterceptor = ApiInterceptor(mockSecureStorage);
  });

  group('ApiInterceptor', () {
    test('onRequest injects Accept and Authorization headers when token exists', () async {
      const token = 'my_secret_token';
      when(() => mockSecureStorage.read(key: AppConstants.tokenKey))
          .thenAnswer((_) async => token);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(options)).thenAnswer((_) {});

      await apiInterceptor.onRequest(options, handler);

      expect(options.headers['Accept'], 'application/json');
      expect(options.headers['Authorization'], 'Bearer $token');
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest injects Accept but no Authorization header when token is null', () async {
      when(() => mockSecureStorage.read(key: AppConstants.tokenKey))
          .thenAnswer((_) async => null);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(options)).thenAnswer((_) {});

      await apiInterceptor.onRequest(options, handler);

      expect(options.headers['Accept'], 'application/json');
      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });

    test('onError deletes token and triggers SessionExpiredEvent on 401 response', () async {
      when(() => mockSecureStorage.delete(key: AppConstants.tokenKey))
          .thenAnswer((_) async {});

      final requestOptions = RequestOptions(path: '/test');
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: response,
      );

      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(dioException)).thenAnswer((_) {});

      // Listen to the SessionExpiredEvent broadcast stream to verify trigger
      bool sessionExpiredTriggered = false;
      final subscription = SessionExpiredEvent.stream.listen((_) {
        sessionExpiredTriggered = true;
      });

      await apiInterceptor.onError(dioException, handler);

      await Future<void>.delayed(Duration.zero);

      expect(sessionExpiredTriggered, isTrue);
      verify(() => mockSecureStorage.delete(key: AppConstants.tokenKey)).called(1);
      verify(() => handler.next(dioException)).called(1);

      await subscription.cancel();
    });
  });
}
