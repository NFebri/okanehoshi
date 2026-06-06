import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/models/paginated_response.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import 'package:okanehoshi/features/transaction/domain/repositories/transaction_history_repository.dart';
import 'package:okanehoshi/features/transaction/presentation/bloc/transaction_history_bloc.dart';
import 'package:okanehoshi/features/transaction/presentation/bloc/transaction_history_event.dart';
import 'package:okanehoshi/features/transaction/presentation/bloc/transaction_history_state.dart';

class MockTransactionHistoryRepository extends Mock implements TransactionHistoryRepository {}

void main() {
  late TransactionHistoryBloc transactionHistoryBloc;
  late MockTransactionHistoryRepository mockTransactionHistoryRepository;

  setUp(() {
    mockTransactionHistoryRepository = MockTransactionHistoryRepository();
    transactionHistoryBloc = TransactionHistoryBloc(mockTransactionHistoryRepository);
  });

  tearDown(() {
    transactionHistoryBloc.close();
  });

  test('initial state should be TransactionHistoryInitial', () {
    expect(transactionHistoryBloc.state, isA<TransactionHistoryInitial>());
  });

  group('FetchTransactionHistory', () {
    final dummyTransaction = Transaction(
      id: 1,
      amount: 50000,
      type: 'topup',
      referenceNo: 'REF12345',
      note: 'Topup',
      createdAt: DateTime.now(),
    );

    final paginatedResponse = PaginatedResponse<Transaction>(
      success: true,
      data: [dummyTransaction],
      meta: PaginationMeta(
        currentPage: 1,
        lastPage: 2,
        perPage: 10,
        total: 15,
      ),
    );

    test('emits [TransactionHistoryLoading, TransactionHistorySuccess] when fetch is successful', () async {
      when(() => mockTransactionHistoryRepository.getTransactions(
            type: any(named: 'type'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => paginatedResponse);

      final expectedStates = [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistorySuccess>()
            .having((s) => s.transactions, 'transactions', [dummyTransaction])
            .having((s) => s.currentPage, 'currentPage', 1)
            .having((s) => s.hasReachedMax, 'hasReachedMax', false),
      ];

      final future = expectLater(transactionHistoryBloc.stream, emitsInOrder(expectedStates));

      transactionHistoryBloc.add(const FetchTransactionHistory());

      await future;
    });

    test('emits [TransactionHistoryLoading, TransactionHistoryFailure] when api exception occurs', () async {
      when(() => mockTransactionHistoryRepository.getTransactions(
            type: any(named: 'type'),
            page: any(named: 'page'),
          )).thenThrow(UnknownException('Koneksi bermasalah'));

      final expectedStates = [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryFailure>().having((s) => s.message, 'message', 'Koneksi bermasalah'),
      ];

      final future = expectLater(transactionHistoryBloc.stream, emitsInOrder(expectedStates));

      transactionHistoryBloc.add(const FetchTransactionHistory());

      await future;
    });
  });
}
