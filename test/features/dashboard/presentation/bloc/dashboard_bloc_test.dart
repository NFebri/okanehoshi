import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import 'package:okanehoshi/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late DashboardBloc dashboardBloc;
  late MockDashboardRepository mockDashboardRepository;

  setUp(() {
    mockDashboardRepository = MockDashboardRepository();
    dashboardBloc = DashboardBloc(mockDashboardRepository);
  });

  tearDown(() {
    dashboardBloc.close();
  });

  test('initial state should be DashboardInitial', () {
    expect(dashboardBloc.state, isA<DashboardInitial>());
  });

  group('FetchDashboardData', () {
    final recentTransactions = [
      Transaction(
        id: 1,
        amount: 50000,
        type: 'topup',
        referenceNo: 'REF123',
        note: 'Top up',
        createdAt: DateTime.parse('2026-06-04T00:00:00Z'),
      )
    ];

    final dashboardData = DashboardData(
      balance: 150000,
      recentTransactions: recentTransactions,
    );

    test('emits [DashboardLoading, DashboardLoaded] when fetch is successful', () async {
      when(() => mockDashboardRepository.getDashboardData()).thenAnswer(
        (_) async => BaseResponse<DashboardData>(
          success: true,
          message: 'Berhasil',
          data: dashboardData,
        ),
      );

      final expectedStates = [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>().having((s) => s.dashboardData, 'dashboardData', dashboardData),
      ];

      final future = expectLater(dashboardBloc.stream, emitsInOrder(expectedStates));
      dashboardBloc.add(const FetchDashboardData());
      await future;
    });

    test('emits [DashboardLoading, DashboardError] when success=false', () async {
      when(() => mockDashboardRepository.getDashboardData()).thenAnswer(
        (_) async => BaseResponse<DashboardData>(
          success: false,
          message: 'Gagal memuat data',
        ),
      );

      final expectedStates = [
        isA<DashboardLoading>(),
        isA<DashboardError>().having((s) => s.message, 'message', 'Gagal memuat data'),
      ];

      final future = expectLater(dashboardBloc.stream, emitsInOrder(expectedStates));
      dashboardBloc.add(const FetchDashboardData());
      await future;
    });

    test('emits [DashboardLoading, DashboardError] on ApiException', () async {
      when(() => mockDashboardRepository.getDashboardData()).thenThrow(
        ServerException('Koneksi terputus ke server', 500),
      );

      final expectedStates = [
        isA<DashboardLoading>(),
        isA<DashboardError>().having((s) => s.message, 'message', 'Koneksi terputus ke server'),
      ];

      final future = expectLater(dashboardBloc.stream, emitsInOrder(expectedStates));
      dashboardBloc.add(const FetchDashboardData());
      await future;
    });
  });
}
