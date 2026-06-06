import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_client.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../models/dashboard_response.dart';

// The remote datasource interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class DashboardRemoteDataSource {
  Future<BaseResponse<DashboardResponse>> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<DashboardResponse>> getDashboardData() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.dashboard,
      );

      final data = response.data;
      if (data == null) {
        throw UnknownException('Respon dari server kosong.');
      }

      return BaseResponse.fromJson(
        data,
        (json) => DashboardResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Gagal memuat data dashboard: $e');
    }
  }
}
