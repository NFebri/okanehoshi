import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';

class TransferResult {
  final Transaction transaction;
  final int newBalance;

  const TransferResult({
    required this.transaction,
    required this.newBalance,
  });
}
