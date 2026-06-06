import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import 'package:okanehoshi/features/transfer/domain/entities/transfer_result.dart';
import 'package:okanehoshi/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:okanehoshi/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:okanehoshi/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:okanehoshi/features/transfer/presentation/bloc/transfer_state.dart';

class MockTransferRepository extends Mock implements TransferRepository {}

void main() {
  late TransferBloc transferBloc;
  late MockTransferRepository mockTransferRepository;

  setUp(() {
    mockTransferRepository = MockTransferRepository();
    transferBloc = TransferBloc(mockTransferRepository);
  });

  tearDown(() {
    transferBloc.close();
  });

  test('initial state should be TransferInitial', () {
    expect(transferBloc.state, isA<TransferInitial>());
  });

  group('TransferSubmitted', () {
    const identifier = 'receiver@example.com';
    const amount = 50000;
    const note = 'Uang saku';

    final dummyTransaction = Transaction(
      id: 2,
      amount: amount,
      type: 'transfer',
      referenceNo: 'REF54321',
      note: 'Transfer berhasil!',
      createdAt: DateTime.now(),
    );

    final transferResult = TransferResult(
      transaction: dummyTransaction,
      newBalance: 100000,
    );

    test('emits [TransferLoading, TransferSuccess] when transfer is successful', () async {
      when(() => mockTransferRepository.transfer(
            identifier: identifier,
            amount: amount,
            note: note,
          )).thenAnswer(
        (_) async => BaseResponse<TransferResult>(
          success: true,
          message: 'Transfer berhasil!',
          data: transferResult,
        ),
      );

      final expectedStates = [
        isA<TransferLoading>(),
        isA<TransferSuccess>().having((s) => s.result, 'result', transferResult),
      ];

      final future = expectLater(transferBloc.stream, emitsInOrder(expectedStates));

      transferBloc.add(const TransferSubmitted(
        identifier: identifier,
        amount: amount,
        note: note,
      ));

      await future;
    });

    test('emits [TransferLoading, TransferFailure] when repository returns unsuccessful response', () async {
      when(() => mockTransferRepository.transfer(
            identifier: identifier,
            amount: amount,
            note: note,
          )).thenAnswer(
        (_) async => BaseResponse<TransferResult>(
          success: false,
          message: 'Penerima tidak ditemukan.',
        ),
      );

      final expectedStates = [
        isA<TransferLoading>(),
        isA<TransferFailure>().having((s) => s.message, 'message', 'Penerima tidak ditemukan.'),
      ];

      final future = expectLater(transferBloc.stream, emitsInOrder(expectedStates));

      transferBloc.add(const TransferSubmitted(
        identifier: identifier,
        amount: amount,
        note: note,
      ));

      await future;
    });

    test('emits [TransferLoading, TransferFailure] on ApiException', () async {
      when(() => mockTransferRepository.transfer(
            identifier: identifier,
            amount: amount,
            note: note,
          )).thenThrow(
        UnknownException('Koneksi terputus'),
      );

      final expectedStates = [
        isA<TransferLoading>(),
        isA<TransferFailure>().having((s) => s.message, 'message', 'Koneksi terputus'),
      ];

      final future = expectLater(transferBloc.stream, emitsInOrder(expectedStates));

      transferBloc.add(const TransferSubmitted(
        identifier: identifier,
        amount: amount,
        note: note,
      ));

      await future;
    });
  });
}
