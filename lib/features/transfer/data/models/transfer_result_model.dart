import 'package:okanehoshi/features/dashboard/data/models/transaction_model.dart';
import '../../domain/entities/transfer_result.dart';

class TransferResultModel extends TransferResult {
  const TransferResultModel({
    required super.transaction,
    required super.newBalance,
  });

  factory TransferResultModel.fromJson(Map<String, dynamic> json) {
    return TransferResultModel(
      transaction: TransactionModel.fromJson(json['transaction'] as Map<String, dynamic>),
      newBalance: json['new_balance'] as int,
    );
  }
}
