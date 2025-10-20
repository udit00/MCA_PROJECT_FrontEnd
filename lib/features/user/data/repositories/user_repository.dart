import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> getSelfData() async {
    final response = await _apiService.get('user/selfData');
    return CommonApiResponse.fromJson(response);
  }
}
