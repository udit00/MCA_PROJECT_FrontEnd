import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/notifications/data/models/mark_as_read_request_model.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> getMyNotifications() async {
    final response = await _apiService.get('notification/getMyNotifications');
    return CommonApiResponse.fromJson(response);
  }

  Future<CommonApiResponse> markAsRead(MarkAsReadRequestModel request) async {
    final response = await _apiService.post('notification/markAsRead', request.toJson());
    return CommonApiResponse.fromJson(response);
  }
}

