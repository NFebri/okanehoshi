import 'package:okanehoshi/core/models/paginated_response.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import '../../domain/repositories/transaction_history_repository.dart';
import '../datasources/transaction_history_remote_datasource.dart';

class TransactionHistoryRepositoryImpl implements TransactionHistoryRepository {
  final TransactionHistoryRemoteDataSource _remoteDataSource;

  TransactionHistoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<Transaction>> getTransactions({
    String? type,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getTransactions(
        type: type,
        page: page,
        perPage: perPage,
      );
      return PaginatedResponse<Transaction>(
        success: response.success,
        message: response.message,
        data: response.data,
        meta: response.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
