import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/feedback/data/models/create_feedback_request_model.dart';

class FeedbackRepository {
  final ApiService _apiService = ApiService();

  /// Create a new feedback for a gym
  Future<CommonApiResponse> createFeedback(CreateFeedbackRequestModel request) async {
    final response = await _apiService.post('feedback/create', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  /// Get all feedbacks for a specific gym
  Future<CommonApiResponse> getAllByGymId(int gymId) async {
    final response = await _apiService.get('feedback/getAllByGymId?gymId=$gymId');
    return CommonApiResponse.fromJson(response);
  }

  /// Get a single feedback by ID
  Future<CommonApiResponse> getFeedbackById(int feedbackId) async {
    final response = await _apiService.get('feedback/get?feedbackId=$feedbackId');
    return CommonApiResponse.fromJson(response);
  }

  /// Get gym data by ID
  Future<CommonApiResponse> getGymData(int gymId) async {
    final response = await _apiService.get('gym/getGymData?gymId=$gymId');
    return CommonApiResponse.fromJson(response);
  }
}

