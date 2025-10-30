
import '../../../../common/models/common_api_response_model.dart';
import '../../../../core/network/api_service.dart';

class MessagesRepository {
  final ApiService _apiService;

  MessagesRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Create a new message
  Future<CommonApiResponse> createMessage({
    required int messageForUserId,
    required String comment,
  }) async {
    final response = await _apiService.post('messages/create', {
      'messageForUserId': messageForUserId,
      'comment': comment,
    });
    return CommonApiResponse.fromJson(response);
  }

  /// Update an existing message
  Future<CommonApiResponse> updateMessage({
    required int messageId,
    required String comment,
  }) async {
    final response = await _apiService.post('messages/update', {
      'messageId': messageId,
      'comment': comment,
    });
    return CommonApiResponse.fromJson(response);
  }

  /// Delete a message (soft delete)
  Future<CommonApiResponse> deleteMessage(int messageId) async {
    final response = await _apiService.post('messages/delete', {
      'messageId': messageId,
    });
    return CommonApiResponse.fromJson(response);
  }

  /// Get all chat participants (users you've chatted with)
  Future<CommonApiResponse> getChatParticipants() async {
    final response = await _apiService.get('messages/getChatParticipants');
    return CommonApiResponse.fromJson(response);
  }

  /// Get chat messages with a specific user (automatically marks as read)
  Future<CommonApiResponse> getChatMessages(int userId) async {
    final response = await _apiService.get('messages/getChatMessages?userId=$userId');
    return CommonApiResponse.fromJson(response);
  }

  /// Get total unread message count
  Future<CommonApiResponse> getUnreadCount() async {
    final response = await _apiService.get('messages/getUnreadCount');
    return CommonApiResponse.fromJson(response);
  }

  /// Get available chat users (trainers get members, members get trainers)
  Future<CommonApiResponse> getAvailableChatUsers() async {
    final response = await _apiService.get('messages/getAvailableChatUsers');
    return CommonApiResponse.fromJson(response);
  }
}

