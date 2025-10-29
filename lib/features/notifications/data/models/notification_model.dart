import 'package:zymm/common/enums/notification_type.dart';

class NotificationModel {
  final int notificationId;
  final NotificationType notificationType;
  final String notificationTitle;
  final String notificationDesc;
  final int userId;
  final int createdBy;
  final DateTime createdOn;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.notificationType,
    required this.notificationTitle,
    required this.notificationDesc,
    required this.userId,
    required this.createdBy,
    required this.createdOn,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as int,
      notificationType: NotificationType.fromId(json['notificationType'] as int),
      notificationTitle: json['notificationTitle'] as String,
      notificationDesc: json['notificationDesc'] as String,
      userId: json['userId'] as int,
      createdBy: json['createdBy'] as int,
      createdOn: DateTime.parse(json['createdOn'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'notificationType': notificationType.id,
      'notificationTitle': notificationTitle,
      'notificationDesc': notificationDesc,
      'userId': userId,
      'createdBy': createdBy,
      'createdOn': createdOn.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    int? notificationId,
    NotificationType? notificationType,
    String? notificationTitle,
    String? notificationDesc,
    int? userId,
    int? createdBy,
    DateTime? createdOn,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      notificationType: notificationType ?? this.notificationType,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationDesc: notificationDesc ?? this.notificationDesc,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      isRead: isRead ?? this.isRead,
    );
  }
}

