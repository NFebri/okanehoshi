import 'package:okanehoshi/core/models/base_response.dart';
import '../../domain/entities/top_up_result.dart';
import '../../domain/repositories/top_up_repository.dart';
import '../datasources/top_up_remote_datasource.dart';

class TopUpRepositoryImpl implements TopUpRepository {
  final TopUpRemoteDataSource _remoteDataSource;

  TopUpRepositoryImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<TopUpResult>> topUp(int amount) async {
    try {
      final response = await _remoteDataSource.topUp(amount);
      return BaseResponse<TopUpResult>(
        success: response.success,
        message: response.message,
        data: response.data,
        errors: response.errors,
      );
    } catch (e) {
      rethrow;
    }
  }
}
