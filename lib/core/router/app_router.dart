import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_state.dart';
import 'package:okanehoshi/features/auth/presentation/pages/login_page.dart';
import 'package:okanehoshi/features/auth/presentation/pages/register_page.dart';
import 'package:okanehoshi/features/auth/presentation/pages/splash_page.dart';
import 'package:okanehoshi/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:okanehoshi/features/topup/domain/repositories/top_up_repository.dart';
import 'package:okanehoshi/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:okanehoshi/features/topup/presentation/pages/topup_page.dart';
import 'package:okanehoshi/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:okanehoshi/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:okanehoshi/features/transfer/presentation/pages/transfer_page.dart';
import 'package:okanehoshi/features/transaction/domain/repositories/transaction_history_repository.dart';
import 'package:okanehoshi/features/transaction/presentation/bloc/transaction_history_bloc.dart';
import 'package:okanehoshi/features/transaction/presentation/bloc/transaction_history_event.dart';
import 'package:okanehoshi/features/transaction/presentation/pages/transaction_history_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  final DashboardRepository dashboardRepository;
  final TopUpRepository topUpRepository;
  final TransferRepository transferRepository;
  final TransactionHistoryRepository transactionHistoryRepository;

  AppRouter(
    this.authBloc,
    this.dashboardRepository,
    this.topUpRepository,
    this.transferRepository,
    this.transactionHistoryRepository,
  );

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      if (authState is AuthInitial) {
        if (!isSplash) return '/splash';
        return null;
      }

      if (authState is Unauthenticated) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }

      if (authState is Authenticated) {
        if (isLoggingIn || isRegistering || isSplash) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => BlocProvider(
          create: (context) => DashboardBloc(dashboardRepository)..add(const FetchDashboardData()),
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/topup',
        builder: (context, state) => BlocProvider(
          create: (context) => TopUpBloc(topUpRepository),
          child: const TopupPage(),
        ),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => BlocProvider(
          create: (context) => TransferBloc(transferRepository),
          child: const TransferPage(),
        ),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => BlocProvider(
          create: (context) => TransactionHistoryBloc(transactionHistoryRepository)
            ..add(const FetchTransactionHistory()),
          child: const TransactionHistoryPage(),
        ),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
