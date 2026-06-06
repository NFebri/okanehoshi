import 'package:okanehoshi/core/models/base_response.dart';
import '../../domain/entities/transfer_result.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource _remoteDataSource;

  TransferRepositoryImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<TransferResult>> transfer({
    required String identifier,
    required int amount,
    String? note,
  }) async {
    try {
      final response = await _remoteDataSource.transfer(
        identifier: identifier,
        amount: amount,
        note: note,
      );
      return BaseResponse<TransferResult>(
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
