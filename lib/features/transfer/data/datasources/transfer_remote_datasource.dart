import 'package:okanehoshi/core/constants/api_constants.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_client.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import '../models/transfer_result_model.dart';

// The remote datasource interface is designed to be future-proof for additional endpoints.
// ignore_for_file: one_member_abstracts
abstract class TransferRemoteDataSource {
  Future<BaseResponse<TransferResultModel>> transfer({
    required String identifier,
    required int amount,
    String? note,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final ApiClient _apiClient;

  TransferRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<TransferResultModel>> transfer({
    required String identifier,
    required int amount,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.transfer,
        data: {
          'identifier': identifier,
          'amount': amount,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      final data = response.data;
      if (data == null) {
        throw UnknownException('Respon dari server kosong.');
      }

      return BaseResponse.fromJson(
        data,
        (json) => TransferResultModel.fromJson(json! as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Gagal memproses transfer: $e');
    }
  }
}
