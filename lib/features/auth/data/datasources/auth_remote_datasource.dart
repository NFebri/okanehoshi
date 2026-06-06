import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_client.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final baseResponse = BaseResponse<AuthResponse>.fromJson(
      response.data!,
      (json) => AuthResponse.fromJson(json! as Map<String, dynamic>),
    );

    if (!baseResponse.success || baseResponse.data == null) {
      throw ServerException(baseResponse.message ?? 'Registrasi gagal.');
    }

    return baseResponse.data!;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final baseResponse = BaseResponse<AuthResponse>.fromJson(
      response.data!,
      (json) => AuthResponse.fromJson(json! as Map<String, dynamic>),
    );

    if (!baseResponse.success || baseResponse.data == null) {
      throw ServerException(baseResponse.message ?? 'Login gagal.');
    }

    return baseResponse.data!;
  }

  @override
  Future<void> logout() async {
    final response = await _apiClient.post<Map<String, dynamic>>(ApiConstants.logout);

    final baseResponse = BaseResponse<void>.fromJson(
      response.data!,
      (_) {},
    );

    if (!baseResponse.success) {
      throw ServerException(baseResponse.message ?? 'Logout gagal.');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiConstants.profile);

    final baseResponse = BaseResponse<UserModel>.fromJson(
      response.data!,
      (json) => UserModel.fromJson(json! as Map<String, dynamic>),
    );

    if (!baseResponse.success || baseResponse.data == null) {
      throw ServerException(baseResponse.message ?? 'Gagal mengambil data profil.');
    }

    return baseResponse.data!;
  }
}
