import '../../domain/entities/transfer_result.dart';

abstract class TransferState {
  const TransferState();
}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class TransferSuccess extends TransferState {
  final TransferResult result;

  const TransferSuccess(this.result);
}

class TransferFailure extends TransferState {
  final String message;
  final Map<String, List<String>>? errors;

  const TransferFailure(this.message, {this.errors});
}
