import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/network/idempotency_interceptor.dart';

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late IdempotencyInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  setUp(() {
    interceptor = IdempotencyInterceptor();
    mockHandler = MockRequestInterceptorHandler();
  });

  group('IdempotencyInterceptor', () {
    test('injects X-Idempotency-Key with valid UUID v4 on POST topup', () {
      final options = RequestOptions(
        path: ApiConstants.topUp,
        method: 'POST',
      );

      when(() => mockHandler.next(options)).thenAnswer((_) {});

      interceptor.onRequest(options, mockHandler);

      final key = options.headers['X-Idempotency-Key'] as String?;
      expect(key, isNotNull);
      
      // Verify UUID v4 format
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidRegex.hasMatch(key!), isTrue);
      expect(options.extra['idempotency_key'], key);
      
      verify(() => mockHandler.next(options)).called(1);
    });

    test('injects X-Idempotency-Key with valid UUID v4 on POST transfer', () {
      final options = RequestOptions(
        path: ApiConstants.transfer,
        method: 'POST',
      );

      when(() => mockHandler.next(options)).thenAnswer((_) {});

      interceptor.onRequest(options, mockHandler);

      final key = options.headers['X-Idempotency-Key'] as String?;
      expect(key, isNotNull);
      
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidRegex.hasMatch(key!), isTrue);
      expect(options.extra['idempotency_key'], key);
      
      verify(() => mockHandler.next(options)).called(1);
    });

    test('does not inject X-Idempotency-Key on GET dashboard', () {
      final options = RequestOptions(
        path: ApiConstants.dashboard,
        method: 'GET',
      );

      when(() => mockHandler.next(options)).thenAnswer((_) {});

      interceptor.onRequest(options, mockHandler);

      expect(options.headers.containsKey('X-Idempotency-Key'), isFalse);
      expect(options.extra.containsKey('idempotency_key'), isFalse);
      
      verify(() => mockHandler.next(options)).called(1);
    });

    test('does not inject X-Idempotency-Key on POST auth login', () {
      final options = RequestOptions(
        path: ApiConstants.login,
        method: 'POST',
      );

      when(() => mockHandler.next(options)).thenAnswer((_) {});

      interceptor.onRequest(options, mockHandler);

      expect(options.headers.containsKey('X-Idempotency-Key'), isFalse);
      expect(options.extra.containsKey('idempotency_key'), isFalse);
      
      verify(() => mockHandler.next(options)).called(1);
    });

    test('reuses existing idempotency key in retry scenario', () {
      const existingKey = 'custom-existing-idempotency-key';
      final options = RequestOptions(
        path: ApiConstants.topUp,
        method: 'POST',
        extra: {'idempotency_key': existingKey},
      );

      when(() => mockHandler.next(options)).thenAnswer((_) {});

      interceptor.onRequest(options, mockHandler);

      expect(options.headers['X-Idempotency-Key'], existingKey);
      expect(options.extra['idempotency_key'], existingKey);
      
      verify(() => mockHandler.next(options)).called(1);
    });
  });
}
