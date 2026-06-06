import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import 'package:okanehoshi/features/topup/domain/entities/top_up_result.dart';
import 'package:okanehoshi/features/topup/domain/repositories/top_up_repository.dart';
import 'package:okanehoshi/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:okanehoshi/features/topup/presentation/bloc/top_up_event.dart';
import 'package:okanehoshi/features/topup/presentation/bloc/top_up_state.dart';

class MockTopUpRepository extends Mock implements TopUpRepository {}

void main() {
  late TopUpBloc topUpBloc;
  late MockTopUpRepository mockTopUpRepository;

  setUp(() {
    mockTopUpRepository = MockTopUpRepository();
    topUpBloc = TopUpBloc(mockTopUpRepository);
  });

  tearDown(() {
    topUpBloc.close();
  });

  test('initial state should be TopUpInitial', () {
    expect(topUpBloc.state, isA<TopUpInitial>());
  });

  group('TopUpSubmitted', () {
    const amount = 50000;
    final dummyTransaction = Transaction(
      id: 1,
      amount: amount,
      type: 'topup',
      referenceNo: 'REF12345',
      note: 'Top up berhasil!',
      createdAt: DateTime.now(),
    );
    final topUpResult = TopUpResult(
      transaction: dummyTransaction,
      newBalance: 150000,
    );

    test('emits [TopUpLoading, TopUpSuccess] when top up is successful', () async {
      when(() => mockTopUpRepository.topUp(amount)).thenAnswer(
        (_) async => BaseResponse<TopUpResult>(
          success: true,
          message: 'Top-up berhasil!',
          data: topUpResult,
        ),
      );

      final expectedStates = [
        isA<TopUpLoading>(),
        isA<TopUpSuccess>().having((s) => s.result, 'result', topUpResult),
      ];

      final future = expectLater(topUpBloc.stream, emitsInOrder(expectedStates));

      topUpBloc.add(const TopUpSubmitted(amount));

      await future;
    });

    test('emits [TopUpLoading, TopUpFailure] when repository returns unsuccessful response', () async {
      when(() => mockTopUpRepository.topUp(amount)).thenAnswer(
        (_) async => BaseResponse<TopUpResult>(
          success: false,
          message: 'Gagal memproses top up.',
        ),
      );

      final expectedStates = [
        isA<TopUpLoading>(),
        isA<TopUpFailure>().having((s) => s.message, 'message', 'Gagal memproses top up.'),
      ];

      final future = expectLater(topUpBloc.stream, emitsInOrder(expectedStates));

      topUpBloc.add(const TopUpSubmitted(amount));

      await future;
    });

    test('emits [TopUpLoading, TopUpFailure] on ApiException', () async {
      when(() => mockTopUpRepository.topUp(amount)).thenThrow(
        UnknownException('Koneksi terputus'),
      );

      final expectedStates = [
        isA<TopUpLoading>(),
        isA<TopUpFailure>().having((s) => s.message, 'message', 'Koneksi terputus'),
      ];

      final future = expectLater(topUpBloc.stream, emitsInOrder(expectedStates));

      topUpBloc.add(const TopUpSubmitted(amount));

      await future;
    });
  });
}
