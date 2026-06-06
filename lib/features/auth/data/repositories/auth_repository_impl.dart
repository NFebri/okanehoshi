import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:okanehoshi/core/constants/app_constants.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<BaseResponse<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final authResponse = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await saveToken(authResponse.token);

      return BaseResponse<User>(
        success: true,
        message: 'Registrasi berhasil.',
        data: authResponse.user,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await saveToken(authResponse.token);

      return BaseResponse<User>(
        success: true,
        message: 'Login berhasil.',
        data: authResponse.user,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponse<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await deleteToken();

      return BaseResponse<void>(
        success: true,
        message: 'Logout berhasil.',
      );
    } catch (e) {
      await deleteToken();
      rethrow;
    }
  }

  @override
  Future<BaseResponse<User>> getProfile() async {
    try {
      final user = await _remoteDataSource.getProfile();

      return BaseResponse<User>(
        success: true,
        message: 'Ambil profil berhasil.',
        data: user,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }
}
