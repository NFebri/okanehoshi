import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_client.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../models/top_up_result_model.dart';

// The remote datasource interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TopUpRemoteDataSource {
  Future<BaseResponse<TopUpResultModel>> topUp(int amount);
}

class TopUpRemoteDataSourceImpl implements TopUpRemoteDataSource {
  final ApiClient _apiClient;

  TopUpRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<TopUpResultModel>> topUp(int amount) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.topUp,
        data: {'amount': amount},
      );

      final data = response.data;
      if (data == null) {
        throw UnknownException('Respon dari server kosong.');
      }

      return BaseResponse.fromJson(
        data,
        (json) => TopUpResultModel.fromJson(json! as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Gagal memproses top up: $e');
    }
  }
}
