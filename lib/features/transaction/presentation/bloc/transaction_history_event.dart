abstract class TransactionHistoryEvent {
  const TransactionHistoryEvent();
}

class FetchTransactionHistory extends TransactionHistoryEvent {
  final String? type;
  final bool isRefresh;

  const FetchTransactionHistory({this.type, this.isRefresh = false});
}

class LoadMoreTransactionHistory extends TransactionHistoryEvent {
  const LoadMoreTransactionHistory();
}
