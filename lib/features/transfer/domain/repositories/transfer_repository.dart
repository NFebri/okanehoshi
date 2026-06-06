import 'package:okanehoshi/core/models/base_response.dart';
import '../entities/transfer_result.dart';

// The abstract repository interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TransferRepository {
  Future<BaseResponse<TransferResult>> transfer({
    required String identifier,
    required int amount,
    String? note,
  });
}
