import 'package:okanehoshi/core/models/base_response.dart';
import '../entities/top_up_result.dart';

// The abstract repository interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TopUpRepository {
  Future<BaseResponse<TopUpResult>> topUp(int amount);
}
