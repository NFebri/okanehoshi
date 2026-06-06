import '../../domain/entities/top_up_result.dart';

abstract class TopUpState {
  const TopUpState();
}

class TopUpInitial extends TopUpState {}

class TopUpLoading extends TopUpState {}

class TopUpSuccess extends TopUpState {
  final TopUpResult result;

  const TopUpSuccess(this.result);
}

class TopUpFailure extends TopUpState {
  final String message;
  final Map<String, List<String>>? errors;

  const TopUpFailure(this.message, {this.errors});
}
