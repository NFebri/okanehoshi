import 'package:okanehoshi/core/models/paginated_response.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';

// The repository interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TransactionHistoryRepository {
  Future<PaginatedResponse<Transaction>> getTransactions({
    String? type,
    int page = 1,
    int perPage = 10,
  });
}
