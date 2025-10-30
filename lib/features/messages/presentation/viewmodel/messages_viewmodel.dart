import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:zymm/features/messages/data/models/chat_participant_model.dart';
import 'package:zymm/features/messages/data/models/chat_message_model.dart';
import 'package:zymm/features/messages/data/models/chat_user_model.dart';
import 'package:zymm/features/messages/data/repositories/messages_repository.dart';

enum MessagesViewState { initial, loading, loaded, error, sending }

class MessagesViewModel extends ChangeNotifier {
  final MessagesRepository _repository;

  MessagesViewState _state = MessagesViewState.initial;
  List<ChatParticipantModel> _participants = [];
  List<ChatMessageModel> _currentChatMessages = [];
  List<ChatUser> _availableChatUsers = [];
  int _unreadCount = 0;
  String? _errorMessage;

  MessagesViewModel({MessagesRepository? repository})
      : _repository = repository ?? MessagesRepository();

  // Getters
  MessagesViewState get state => _state;
  List<ChatParticipantModel> get participants => _participants;
  List<ChatMessageModel> get currentChatMessages => _currentChatMessages;
  List<ChatUser> get availableChatUsers => _availableChatUsers;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;

  /// Get all chat participants (users you've chatted with)
  Future<void> getChatParticipants() async {
    _state = MessagesViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      developer.log('🔄 Fetching chat participants...');
      final response = await _repository.getChatParticipants();

      if (response.hasError) {
        developer.log('❌ Error fetching participants: ${response.error}');
        _state = MessagesViewState.error;
        _errorMessage = response.error ?? 'Failed to load chat participants';
      } else {
        developer.log('✅ Successfully fetched participants');
        final data = response.data;

        if (data is List) {
          _participants = data
              .map((json) => ChatParticipantModel.fromJson(json as Map<String, dynamic>))
              .toList();
          developer.log('📋 Total participants: ${_participants.length}');
        } else {
          _participants = [];
        }

        _state = MessagesViewState.loaded;
      }
    } catch (e) {
      developer.log('❌ Exception fetching participants: $e');
      _state = MessagesViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get chat messages with a specific user (automatically marks as read)
  Future<void> getChatMessages(int userId, {bool silent = false}) async {
    if (!silent) {
      _state = MessagesViewState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      developer.log('🔄 Fetching chat messages with user $userId...');
      final response = await _repository.getChatMessages(userId);

      if (response.hasError) {
        developer.log('❌ Error fetching messages: ${response.error}');
        if (!silent) {
          _state = MessagesViewState.error;
          _errorMessage = response.error ?? 'Failed to load messages';
        }
      } else {
        developer.log('✅ Successfully fetched messages');
        final data = response.data;

        if (data is List) {
          _currentChatMessages = data
              .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
              .toList();
          developer.log('📋 Total messages: ${_currentChatMessages.length}');
        } else {
          _currentChatMessages = [];
        }

        if (!silent) {
          _state = MessagesViewState.loaded;
        }
      }
    } catch (e) {
      developer.log('❌ Exception fetching messages: $e');
      if (!silent) {
        _state = MessagesViewState.error;
        _errorMessage = 'Error: ${e.toString()}';
      }
    } finally {
      notifyListeners();
    }
  }

  /// Send a new message
  Future<bool> sendMessage({
    required int messageForUserId,
    required String comment,
  }) async {
    _state = MessagesViewState.sending;
    _errorMessage = null;
    notifyListeners();

    try {
      developer.log('📤 Sending message to user $messageForUserId...');
      final response = await _repository.createMessage(
        messageForUserId: messageForUserId,
        comment: comment,
      );

      if (response.hasError) {
        developer.log('❌ Error sending message: ${response.error}');
        _state = MessagesViewState.error;
        _errorMessage = response.error ?? 'Failed to send message';
        notifyListeners();
        return false;
      } else {
        developer.log('✅ Message sent successfully');
        
        // Refresh chat messages to include the new message
        await getChatMessages(messageForUserId, silent: true);
        
        _state = MessagesViewState.loaded;
        notifyListeners();
        return true;
      }
    } catch (e) {
      developer.log('❌ Exception sending message: $e');
      _state = MessagesViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get total unread message count
  Future<void> getUnreadCount() async {
    try {
      developer.log('🔄 Fetching unread count...');
      final response = await _repository.getUnreadCount();

      if (response.hasError) {
        developer.log('❌ Error fetching unread count: ${response.error}');
      } else {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          _unreadCount = data['unreadCount'] as int? ?? 0;
          developer.log('📬 Unread count: $_unreadCount');
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log('❌ Exception fetching unread count: $e');
    }
  }

  /// Clear current chat messages
  void clearCurrentChat() {
    _currentChatMessages = [];
    _state = MessagesViewState.initial;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get available chat users (members for trainers, trainers for members)
  Future<void> getAvailableChatUsers() async {
    _state = MessagesViewState.loading;
    _errorMessage = null;
    _availableChatUsers = [];
    notifyListeners();

    try {
      developer.log('🔄 Fetching available chat users...');
      
      final response = await _repository.getAvailableChatUsers();
      
      if (response.hasError) {
        developer.log('❌ Error fetching chat users: ${response.error}');
        _state = MessagesViewState.error;
        _errorMessage = response.error ?? 'Failed to load chat users';
      } else {
        final data = response.data;
        if (data is List) {
          _availableChatUsers = data
              .map((json) => ChatUser.fromJson(json as Map<String, dynamic>))
              .toList();
          developer.log('✅ Loaded ${_availableChatUsers.length} chat users');
        }
        _state = MessagesViewState.loaded;
      }
    } catch (e) {
      developer.log('❌ Exception fetching available chat users: $e');
      _state = MessagesViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }
}

