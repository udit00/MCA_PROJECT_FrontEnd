import 'package:dio/dio.dart';
import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/auth/data/models/login_request_model.dart';
import 'package:zymm/features/auth/data/models/registration_request_model.dart';
import 'package:zymm/features/auth/data/models/owner_registration_request_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.post('auth/login', request.toJson());
      CommonApiResponse resp = CommonApiResponse.fromJson(response);
      return resp;
    } on DioException {
      rethrow;
    }
  }

  Future<CommonApiResponse> register(RegistrationRequestModel request) async {
    try {
      final response = await _apiService.post(
          'auth/registration', request.toJson());
      return CommonApiResponse.fromJson(response);
    } on DioException {
      rethrow;
    }
  }

  Future<CommonApiResponse> registerOwner(OwnerRegistrationRequestModel request) async {
    try {
      final response = await _apiService.post(
          'auth/ownerRegistration', request.toJson());
      return CommonApiResponse.fromJson(response);
    } on DioException {
      rethrow;
    }
  }
}
