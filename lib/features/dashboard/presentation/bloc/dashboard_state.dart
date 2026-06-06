import '../../domain/entities/dashboard_data.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

  const DashboardLoaded(this.dashboardData);
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}
