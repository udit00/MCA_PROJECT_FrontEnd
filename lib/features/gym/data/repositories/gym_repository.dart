import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';

class GymRepository {
  final ApiService _apiService = ApiService();

  /// Search gyms by name, city, or state
  /// If query is empty, returns all gyms
  Future<CommonApiResponse> searchGyms({String? query}) async {
    final endpoint = query != null && query.isNotEmpty
        ? 'gym/searchGyms?query=$query'
        : 'gym/searchGyms';
    final response = await _apiService.get(endpoint);
    return CommonApiResponse.fromJson(response);
  }

  /// Get gym data by ID with additional statistics
  Future<CommonApiResponse> getGymData(int gymId) async {
    final response = await _apiService.get('gym/getGymData?gymId=$gymId');
    return CommonApiResponse.fromJson(response);
  }
}

