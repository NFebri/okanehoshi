import 'package:okanehoshi/core/models/base_response.dart';
import '../entities/dashboard_data.dart';

// The abstract repository interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class DashboardRepository {
  Future<BaseResponse<DashboardData>> getDashboardData();
}
