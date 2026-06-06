import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../../domain/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository _transferRepository;

  TransferBloc(this._transferRepository) : super(TransferInitial()) {
    on<TransferSubmitted>(_onTransferSubmitted);
  }

  Future<void> _onTransferSubmitted(
    TransferSubmitted event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransferLoading());
    try {
      final response = await _transferRepository.transfer(
        identifier: event.identifier,
        amount: event.amount,
        note: event.note,
      );
      if (response.success && response.data != null) {
        emit(TransferSuccess(response.data!));
      } else {
        emit(TransferFailure(response.message ?? 'Gagal memproses transfer.'));
      }
    } on ValidationException catch (e) {
      emit(TransferFailure(e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(TransferFailure(e.message));
    } catch (e) {
      emit(TransferFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }
}
