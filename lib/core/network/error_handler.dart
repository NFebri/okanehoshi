import 'api_exceptions.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
  }
}
