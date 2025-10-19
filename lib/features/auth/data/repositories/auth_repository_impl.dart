import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/auth/data/models/login_request_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    return await _apiService.post('v1/auth/login', request.toJson());
  }
}
