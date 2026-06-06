import 'package:okanehoshi/core/models/base_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<BaseResponse<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  Future<BaseResponse<User>> login({
    required String email,
    required String password,
  });

  Future<BaseResponse<void>> logout();

  Future<BaseResponse<User>> getProfile();

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> deleteToken();
}
