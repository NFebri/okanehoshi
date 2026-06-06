import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc(this._dashboardRepository) : super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final response = await _dashboardRepository.getDashboardData();
      if (response.success && response.data != null) {
        emit(DashboardLoaded(response.data!));
      } else {
        emit(DashboardError(response.message ?? 'Gagal memuat data dashboard.'));
      }
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(DashboardError('Terjadi kesalahan tidak terduga: $e'));
    }
  }
}
