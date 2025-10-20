import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/auth/data/models/login_request_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> login(LoginRequestModel request) async {
    final response = await _apiService.post('auth/login', request.toJson());
    return CommonApiResponse.fromJson(response);
  }
}
