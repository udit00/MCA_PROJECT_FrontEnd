import 'package:intl/intl.dart';

/// Model representing a user you've chatted with
class ChatParticipantModel {
  final int userId;
  final String userName;
  final String? profilePic;
  final int roleId;
  final String lastMessageText;
  final DateTime lastMessageTime;
  final int lastMessageSentBy;
  final int unreadCount;

  ChatParticipantModel({
    required this.userId,
    required this.userName,
    this.profilePic,
    required this.roleId,
    required this.lastMessageText,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.unreadCount,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      profilePic: json['profilePic'] as String?,
      roleId: json['roleId'] as int,
      lastMessageText: json['lastMessageText'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      lastMessageSentBy: json['lastMessageSentBy'] as int,
      unreadCount: json['unreadCount'] as int,
    );
  }

  /// Get user initials for avatar
  String get initials {
    if (userName.isEmpty) return '?';
    final names = userName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }

  /// Formatted time display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime);

    if (diff.inDays == 0) {
      // Today - show time
      return DateFormat.jm().format(lastMessageTime); // e.g., "3:45 PM"
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(lastMessageTime); // e.g., "Mon"
    } else {
      return DateFormat.MMMd().format(lastMessageTime); // e.g., "Oct 30"
    }
  }

  /// Check if there are unread messages
  bool get hasUnread => unreadCount > 0;
}

