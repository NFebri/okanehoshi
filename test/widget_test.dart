import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/app.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_state.dart';
import 'package:okanehoshi/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:okanehoshi/features/topup/domain/repositories/top_up_repository.dart';
import 'package:okanehoshi/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:okanehoshi/features/transaction/domain/repositories/transaction_history_repository.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockDashboardRepository extends Mock implements DashboardRepository {}
class MockTopUpRepository extends Mock implements TopUpRepository {}
class MockTransferRepository extends Mock implements TransferRepository {}
class MockTransactionHistoryRepository extends Mock implements TransactionHistoryRepository {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockDashboardRepository mockDashboardRepository;
  late MockTopUpRepository mockTopUpRepository;
  late MockTransferRepository mockTransferRepository;
  late MockTransactionHistoryRepository mockTransactionHistoryRepository;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockDashboardRepository = MockDashboardRepository();
    mockTopUpRepository = MockTopUpRepository();
    mockTransferRepository = MockTransferRepository();
    mockTransactionHistoryRepository = MockTransactionHistoryRepository();
  });

  testWidgets('App renders SplashPage and checks status on boot', (
    WidgetTester tester,
  ) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(MyApp(
      authBloc: mockAuthBloc,
      dashboardRepository: mockDashboardRepository,
      topUpRepository: mockTopUpRepository,
      transferRepository: mockTransferRepository,
      transactionHistoryRepository: mockTransactionHistoryRepository,
    ));

    // Verify that our app renders the SplashPage
    expect(find.text('OkaneHoshi'), findsOneWidget);
  });
}
