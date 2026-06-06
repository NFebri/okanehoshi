import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';

class TopUpResult {
  final Transaction transaction;
  final int newBalance;

  const TopUpResult({
    required this.transaction,
    required this.newBalance,
  });
}
