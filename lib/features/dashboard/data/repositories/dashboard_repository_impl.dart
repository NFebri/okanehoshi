import 'package:okanehoshi/core/models/base_response.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<DashboardData>> getDashboardData() async {
    try {
      final response = await _remoteDataSource.getDashboardData();
      return BaseResponse<DashboardData>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        errors: response.errors,
      );
    } catch (e) {
      rethrow;
    }
  }
}
