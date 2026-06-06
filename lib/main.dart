import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';

import 'package:okanehoshi/features/topup/data/datasources/top_up_remote_datasource.dart';
import 'package:okanehoshi/features/topup/data/repositories/top_up_repository_impl.dart';
import 'package:okanehoshi/features/transfer/data/datasources/transfer_remote_datasource.dart';
import 'package:okanehoshi/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:okanehoshi/features/transaction/data/datasources/transaction_history_remote_datasource.dart';
import 'package:okanehoshi/features/transaction/data/repositories/transaction_history_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  const secureStorage = FlutterSecureStorage();

  // Initialize network API client
  final apiClient = ApiClient(secureStorage: secureStorage);

  // Initialize auth data sources & repositories
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, secureStorage);

  // Initialize Auth BLoC
  final authBloc = AuthBloc(authRepository);

  // Initialize dashboard data sources & repositories
  final dashboardRemoteDataSource = DashboardRemoteDataSourceImpl(apiClient);
  final dashboardRepository = DashboardRepositoryImpl(dashboardRemoteDataSource);

  // Initialize topup data sources & repositories
  final topUpRemoteDataSource = TopUpRemoteDataSourceImpl(apiClient);
  final topUpRepository = TopUpRepositoryImpl(topUpRemoteDataSource);

  // Initialize transfer data sources & repositories
  final transferRemoteDataSource = TransferRemoteDataSourceImpl(apiClient);
  final transferRepository = TransferRepositoryImpl(transferRemoteDataSource);

  // Initialize transaction history data sources & repositories
  final transactionHistoryRemoteDataSource = TransactionHistoryRemoteDataSourceImpl(apiClient);
  final transactionHistoryRepository = TransactionHistoryRepositoryImpl(transactionHistoryRemoteDataSource);

  runApp(
    MyApp(
      authBloc: authBloc,
      dashboardRepository: dashboardRepository,
      topUpRepository: topUpRepository,
      transferRepository: transferRepository,
      transactionHistoryRepository: transactionHistoryRepository,
    ),
  );
}
