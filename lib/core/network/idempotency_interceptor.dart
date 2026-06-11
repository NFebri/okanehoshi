import 'dart:math';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class IdempotencyInterceptor extends Interceptor {
  // Daftar path yang memerlukan idempotency key
  static const _mutationPaths = [
    ApiConstants.topUp,     // '/topup'
    ApiConstants.transfer,  // '/transfer'
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'POST' && _isMutationPath(options.path)) {
      // Reuse key dari retry, atau generate baru
      final existingKey = options.extra['idempotency_key'] as String?;
      final key = existingKey ?? _generateUuidV4();
      
      options.headers['X-Idempotency-Key'] = key;
      options.extra['idempotency_key'] = key;
    }
    handler.next(options);
  }

  bool _isMutationPath(String path) {
    return _mutationPaths.any((p) => path.endsWith(p));
  }

  String _generateUuidV4() {
    final random = Random.secure();
    const chars = '0123456789abcdef';
    
    String randomHex(int length) {
      return List.generate(length, (_) => chars[random.nextInt(16)]).join();
    }
    
    final yChars = ['8', '9', 'a', 'b'];
    final y = yChars[random.nextInt(4)];
    
    return '${randomHex(8)}-${randomHex(4)}-4${randomHex(3)}-$y${randomHex(3)}-${randomHex(12)}';
  }
}
