import 'transaction.dart';

class DashboardData {
  final int balance;
  final List<Transaction> recentTransactions;

  const DashboardData({
    required this.balance,
    required this.recentTransactions,
  });
}
