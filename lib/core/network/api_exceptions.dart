abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Sesi telah berakhir. Silakan login kembali.'])
      : super(message, 401);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  ValidationException(this.errors, [String message = 'Data yang dikirim tidak valid.'])
      : super(message, 422);
}

class ServerException extends ApiException {
  ServerException([String message = 'Terjadi kesalahan pada server.', int statusCode = 500])
      : super(message, statusCode);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource tidak ditemukan.'])
      : super(message, 404);
}

class RateLimitException extends ApiException {
  RateLimitException([String message = 'Terlalu banyak permintaan. Silakan coba lagi nanti.'])
      : super(message, 429);
}

class UnknownException extends ApiException {
  UnknownException(super.message, [super.statusCode]);
}

class ConflictException extends ApiException {
  ConflictException([String message = 'Request sedang diproses, silakan coba lagi.'])
      : super(message, 409);
}

class IdempotencyKeyReusedException extends ApiException {
  IdempotencyKeyReusedException([
    String message = 'Terjadi konflik data, silakan ulangi operasi.',
  ]) : super(message, 422);
}
