import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';

abstract class TransactionHistoryState {
  const TransactionHistoryState();
}

class TransactionHistoryInitial extends TransactionHistoryState {}

class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistorySuccess extends TransactionHistoryState {
  final List<Transaction> transactions;
  final String? currentType;
  final int currentPage;
  final bool hasReachedMax;

  const TransactionHistorySuccess({
    required this.transactions,
    this.currentType,
    required this.currentPage,
    required this.hasReachedMax,
  });

  TransactionHistorySuccess copyWith({
    List<Transaction>? transactions,
    String? currentType,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return TransactionHistorySuccess(
      transactions: transactions ?? this.transactions,
      currentType: currentType ?? this.currentType,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class TransactionHistoryFailure extends TransactionHistoryState {
  final String message;

  const TransactionHistoryFailure(this.message);
}
