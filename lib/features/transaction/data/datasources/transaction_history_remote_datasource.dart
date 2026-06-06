import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/models/paginated_response.dart';
import 'package:okanehoshi/core/network/api_client.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/dashboard/data/models/transaction_model.dart';

// The remote datasource interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TransactionHistoryRemoteDataSource {
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    String? type,
    int page = 1,
    int perPage = 10,
  });
}

class TransactionHistoryRemoteDataSourceImpl implements TransactionHistoryRemoteDataSource {
  final ApiClient _apiClient;

  TransactionHistoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    String? type,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.transactions,
        queryParameters: {
          if (type != null && type.isNotEmpty) 'type': type,
          'page': page,
          'per_page': perPage,
        },
      );

      final data = response.data;
      if (data == null) {
        throw UnknownException('Respon dari server kosong.');
      }

      return PaginatedResponse.fromJson(
        data,
        (json) => TransactionModel.fromJson(json! as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Gagal memuat riwayat transaksi: $e');
    }
  }
}
