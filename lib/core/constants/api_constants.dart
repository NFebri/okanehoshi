class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.8:8000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';

  // Dashboard endpoints
  static const String dashboard = '/dashboard';

  // Transactions endpoints
  static const String transactions = '/transactions';
  static const String topUp = '/topup';
  static const String transfer = '/transfer';
}
