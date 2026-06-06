class Transaction {
  final int id;
  final String type;
  final int amount;
  final String referenceNo;
  final String? note;
  final TransactionUser? sender;
  final TransactionUser? receiver;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.referenceNo,
    this.note,
    this.sender,
    this.receiver,
    required this.createdAt,
  });
}

class TransactionUser {
  final int id;
  final String name;
  final String email;

  const TransactionUser({
    required this.id,
    required this.name,
    required this.email,
  });
}
