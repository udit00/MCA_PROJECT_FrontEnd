import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/attendance/data/models/punch_request_model.dart';

class AttendanceRepository {
  final ApiService _apiService = ApiService();

  Future<CommonApiResponse> getAllAttendance() async {
    final response = await _apiService.get('attendance/getAllAttendance');
    return CommonApiResponse.fromJson(response);
  }

  Future<CommonApiResponse> punchIn(PunchInRequestModel request) async {
    final response = await _apiService.post('attendance/punchIn', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  Future<CommonApiResponse> punchOut(PunchOutRequestModel request) async {
    final response = await _apiService.post('attendance/punchOut', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  Future<CommonApiResponse> deleteAttendance(DeleteAttendanceRequestModel request) async {
    final response = await _apiService.post('attendance/deleteAttendance', request.toJson());
    return CommonApiResponse.fromJson(response);
  }
}

