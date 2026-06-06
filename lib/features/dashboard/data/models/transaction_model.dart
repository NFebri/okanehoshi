import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.referenceNo,
    super.note,
    super.sender,
    super.receiver,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: json['amount'] as int,
      referenceNo: json['reference_no'] as String,
      note: json['note'] as String?,
      sender: json['sender'] != null
          ? TransactionUserModel.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      receiver: json['receiver'] != null
          ? TransactionUserModel.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TransactionUserModel extends TransactionUser {
  const TransactionUserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory TransactionUserModel.fromJson(Map<String, dynamic> json) {
    return TransactionUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
