import 'package:flutter/material.dart';
import 'package:zymm/features/notifications/data/models/mark_as_read_request_model.dart';
import 'package:zymm/features/notifications/data/models/notification_model.dart';
import 'package:zymm/features/notifications/data/repositories/notification_repository.dart';

enum NotificationViewState { idle, loading, success, error, markingAsRead }

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  NotificationViewState _state = NotificationViewState.idle;
  NotificationViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int _markingNotificationId = -1;

  /// Get unread notification count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Get only unread notifications
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  /// Get only read notifications
  List<NotificationModel> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  /// Check if a specific notification is being marked as read
  bool isMarkingAsRead(int notificationId) {
    return _state == NotificationViewState.markingAsRead && 
           _markingNotificationId == notificationId;
  }

  /// Fetch all notifications for the current user
  Future<void> fetchNotifications() async {
    _state = NotificationViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMyNotifications();

      if (response.hasError) {
        // Check if it's just "no data found" which means empty list
        final errorMsg = response.error?.toLowerCase() ?? '';
        if (errorMsg.contains('no') && (errorMsg.contains('data') || errorMsg.contains('notification') || errorMsg.contains('found'))) {
          // Treat "no data found" as empty list, not an error
          _notifications = [];
          _state = NotificationViewState.success;
        } else {
          _state = NotificationViewState.error;
          _errorMessage = response.error ?? 'Failed to fetch notifications';
        }
      } else {
        // Handle both null and empty list cases
        if (response.data == null) {
          _notifications = [];
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
          // Sort by createdOn, most recent first
          _notifications.sort((a, b) => b.createdOn.compareTo(a.createdOn));
        } else {
          _notifications = [];
        }
        _state = NotificationViewState.success;
      }
    } catch (e) {
      _state = NotificationViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    _state = NotificationViewState.markingAsRead;
    _markingNotificationId = notificationId;
    notifyListeners();

    try {
      final request = MarkAsReadRequestModel(notificationId: notificationId);
      final response = await _repository.markAsRead(request);

      if (response.hasError) {
        _state = NotificationViewState.error;
        _errorMessage = response.error ?? 'Failed to mark notification as read';
        notifyListeners();
      } else {
        // Update the local notification state
        final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
        _state = NotificationViewState.success;
        notifyListeners();
      }
    } catch (e) {
      _state = NotificationViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
    } finally {
      _markingNotificationId = -1;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    
    for (final notification in unreadNotifications) {
      await markAsRead(notification.notificationId);
    }
  }
}

