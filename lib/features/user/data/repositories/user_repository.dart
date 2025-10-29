import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
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
    final response = await _apiService.get('user/selfData');
    final apiResponse = CommonApiResponse.fromJson(response);
    return SelfDataModel.fromJson(apiResponse.data);
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
}
