import '../../../../common/models/common_api_response_model.dart';
import '../../../../core/network/api_service.dart';

class MemberRepository {
  final ApiService _apiService;

  MemberRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get all gym members with their active plans and ratings
  /// For owners/managers only - uses JWT for gym ID
  Future<CommonApiResponse> getGymMembers() async {
    final response = await _apiService.get('gym/getGymMembers');
    return CommonApiResponse.fromJson(response);
  }
}

