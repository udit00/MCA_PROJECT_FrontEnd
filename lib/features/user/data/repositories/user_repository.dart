import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/user/data/models/change_password_request_model.dart';
import 'package:zymm/features/user/data/models/change_password_response_model.dart';
import 'package:zymm/features/user/data/models/delete_profile_request_model.dart';
import 'package:zymm/features/user/data/models/self_data_model.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> getSelfData() async {
    final response = await _apiService.get('user/selfData');
    return CommonApiResponse.fromJson(response);
  }

  Future<SelfDataModel> getSelfDataParsed() async {
    try {
      final response = await _apiService.get('user/selfData');
      final apiResponse = CommonApiResponse.fromJson(response);
      return SelfDataModel.fromJson(apiResponse.data);
    } on DioException {
      rethrow;
    }
  }

  Future<ChangePasswordResponseModel> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final request = ChangePasswordRequestModel(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    final response = await _apiService.post('user/changePassword', request.toJson());
    final apiResponse = CommonApiResponse.fromJson(response);
    return ChangePasswordResponseModel.fromJson(apiResponse.data);
  }

  Future<void> deleteProfile({
    required String password,
  }) async {
    final request = DeleteProfileRequestModel(password: password);
    await _apiService.post('user/deleteProfile', request.toJson());
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final authToken = await StorageService.instance.getAuthToken();
    if (authToken == null || authToken.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse('${ApiService.baseUrl}user/uploadProfilePicture');
    
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add the file to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'profilePicture',
        imageFile.path,
      ),
    );

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final apiResponse = CommonApiResponse.fromJson(jsonResponse);
      
      if (apiResponse.hasError) {
        throw Exception(apiResponse.error ?? 'Upload failed');
      }
      
      // Return the profile picture URL from response
      return apiResponse.data['profilePic'] as String;
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
