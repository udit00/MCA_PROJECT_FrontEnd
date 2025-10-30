import 'package:intl/intl.dart';

/// Model representing a message in a chat conversation
class ChatMessageModel {
  final int messageId;
  final int messageForUserId;
  final String comment;
  final bool isActive;
  final bool isRead;
  final int createdBy;
  final String createdByName;
  final String? createdByPic;
  final DateTime createdAt;
  final bool isSentByMe;

  ChatMessageModel({
    required this.messageId,
    required this.messageForUserId,
    required this.comment,
    required this.isActive,
    required this.isRead,
    required this.createdBy,
    required this.createdByName,
    this.createdByPic,
    required this.createdAt,
    required this.isSentByMe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'] as int,
      messageForUserId: json['messageForUserId'] as int,
      comment: json['comment'] as String,
      isActive: json['isActive'] as bool,
      isRead: json['isRead'] as bool,
      createdBy: json['createdBy'] as int,
      createdByName: json['createdByName'] as String,
      createdByPic: json['createdByPic'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSentByMe: json['isSentByMe'] as bool,
    );
  }

  /// Formatted time display
  String get formattedTime {
    return DateFormat.jm().format(createdAt); // e.g., "3:45 PM"
  }

  /// Formatted date display
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(createdAt); // e.g., "Oct 30, 2025"
    }
  }

  /// Get initials for sender avatar
  String get senderInitials {
    if (createdByName.isEmpty) return '?';
    final names = createdByName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }
}

