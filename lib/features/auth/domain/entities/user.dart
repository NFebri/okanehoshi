import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int balance;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.balance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, balance, createdAt];
}
