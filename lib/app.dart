import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/router/app_router.dart';
import 'package:okanehoshi/core/theme/app_theme.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:okanehoshi/features/topup/domain/repositories/top_up_repository.dart';
import 'package:okanehoshi/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:okanehoshi/features/transaction/domain/repositories/transaction_history_repository.dart';

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;
  final DashboardRepository dashboardRepository;
  final TopUpRepository topUpRepository;
  final TransferRepository transferRepository;
  final TransactionHistoryRepository transactionHistoryRepository;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.dashboardRepository,
    required this.topUpRepository,
    required this.transferRepository,
    required this.transactionHistoryRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      widget.authBloc,
      widget.dashboardRepository,
      widget.topUpRepository,
      widget.transferRepository,
      widget.transactionHistoryRepository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: MaterialApp.router(
        title: 'OkaneHoshi',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
