import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../../domain/repositories/top_up_repository.dart';
import 'top_up_event.dart';
import 'top_up_state.dart';

class TopUpBloc extends Bloc<TopUpEvent, TopUpState> {
  final TopUpRepository _topUpRepository;

  TopUpBloc(this._topUpRepository) : super(TopUpInitial()) {
    on<TopUpSubmitted>(_onTopUpSubmitted);
  }

  Future<void> _onTopUpSubmitted(
    TopUpSubmitted event,
    Emitter<TopUpState> emit,
  ) async {
    emit(TopUpLoading());
    try {
      final response = await _topUpRepository.topUp(event.amount);
      if (response.success && response.data != null) {
        emit(TopUpSuccess(response.data!));
      } else {
        emit(TopUpFailure(response.message ?? 'Gagal memproses top up.'));
      }
    } on ValidationException catch (e) {
      emit(TopUpFailure(e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(TopUpFailure(e.message));
    } catch (e) {
      emit(TopUpFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }
}
