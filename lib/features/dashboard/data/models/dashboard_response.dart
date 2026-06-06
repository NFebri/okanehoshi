import '../../domain/entities/dashboard_data.dart';
import 'transaction_model.dart';

class DashboardResponse {
  final int balance;
  final List<TransactionModel> recentTransactions;

  const DashboardResponse({
    required this.balance,
    required this.recentTransactions,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final list = json['recent_transactions'] as List<dynamic>? ?? [];
    return DashboardResponse(
      balance: json['balance'] as int? ?? 0,
      recentTransactions: list
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardData toEntity() {
    return DashboardData(
      balance: balance,
      recentTransactions: recentTransactions,
    );
  }
}
