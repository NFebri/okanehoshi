import 'package:okanehoshi/features/dashboard/data/models/transaction_model.dart';
import '../../domain/entities/top_up_result.dart';

class TopUpResultModel extends TopUpResult {
  const TopUpResultModel({
    required super.transaction,
    required super.newBalance,
  });

  factory TopUpResultModel.fromJson(Map<String, dynamic> json) {
    return TopUpResultModel(
      transaction: TransactionModel.fromJson(json['transaction'] as Map<String, dynamic>),
      newBalance: json['new_balance'] as int,
    );
  }
}
