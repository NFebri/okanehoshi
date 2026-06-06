import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../../domain/repositories/transaction_history_repository.dart';
import 'transaction_history_event.dart';
import 'transaction_history_state.dart';

class TransactionHistoryBloc extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final TransactionHistoryRepository _repository;

  TransactionHistoryBloc(this._repository) : super(TransactionHistoryInitial()) {
    on<FetchTransactionHistory>(_onFetchTransactionHistory);
    on<LoadMoreTransactionHistory>(_onLoadMoreTransactionHistory);
  }

  Future<void> _onFetchTransactionHistory(
    FetchTransactionHistory event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(TransactionHistoryLoading());
    }

    try {
      final response = await _repository.getTransactions(
        type: event.type,
        page: 1,
      );

      emit(TransactionHistorySuccess(
        transactions: response.data,
        currentType: event.type,
        currentPage: response.meta.currentPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      ));
    } on ApiException catch (e) {
      emit(TransactionHistoryFailure(e.message));
    } catch (e) {
      emit(TransactionHistoryFailure('Gagal memuat riwayat transaksi: $e'));
    }
  }

  Future<void> _onLoadMoreTransactionHistory(
    LoadMoreTransactionHistory event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionHistorySuccess || currentState.hasReachedMax) return;

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getTransactions(
        type: currentState.currentType,
        page: nextPage,
      );

      emit(currentState.copyWith(
        transactions: List.of(currentState.transactions)..addAll(response.data),
        currentPage: response.meta.currentPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      ));
    } on ApiException catch (e) {
      emit(TransactionHistoryFailure(e.message));
    } catch (e) {
      emit(TransactionHistoryFailure('Gagal memuat riwayat transaksi tambahan: $e'));
    }
  }
}
