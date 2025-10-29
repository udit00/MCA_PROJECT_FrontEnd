/// Notification type enum that maps to backend notification type IDs
enum NotificationType {
  notificationZymm(1),
  notificationGeneralInfo(2),
  notificationGymBroadcast(3),
  notificationMembershipReq(4),
  notificationMembershipRes(5),
  notificationFeedbackReceived(6);

  final int id;
  const NotificationType(this.id);

  /// Get notification type from ID
  static NotificationType fromId(int id) {
    switch (id) {
      case 1:
        return NotificationType.notificationZymm;
      case 2:
        return NotificationType.notificationGeneralInfo;
      case 3:
        return NotificationType.notificationGymBroadcast;
      case 4:
        return NotificationType.notificationMembershipReq;
      case 5:
        return NotificationType.notificationMembershipRes;
      case 6:
        return NotificationType.notificationFeedbackReceived;
      default:
        return NotificationType.notificationGeneralInfo;
    }
  }

  /// Get notification type display name
  String get displayName {
    switch (this) {
      case NotificationType.notificationZymm:
        return 'Zymm';
      case NotificationType.notificationGeneralInfo:
        return 'General Info';
      case NotificationType.notificationGymBroadcast:
        return 'Gym Broadcast';
      case NotificationType.notificationMembershipReq:
        return 'Membership Request';
      case NotificationType.notificationMembershipRes:
        return 'Membership Response';
      case NotificationType.notificationFeedbackReceived:
        return 'Feedback Received';
    }
  }

  /// Get icon for notification type
  String get iconEmoji {
    switch (this) {
      case NotificationType.notificationZymm:
        return '🏋️';
      case NotificationType.notificationGeneralInfo:
        return 'ℹ️';
      case NotificationType.notificationGymBroadcast:
        return '📢';
      case NotificationType.notificationMembershipReq:
        return '📝';
      case NotificationType.notificationMembershipRes:
        return '✅';
      case NotificationType.notificationFeedbackReceived:
        return '💬';
    }
  }
}

