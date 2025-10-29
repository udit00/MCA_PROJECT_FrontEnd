class MarkAsReadRequestModel {
  final int notificationId;

  MarkAsReadRequestModel({
    required this.notificationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
    };
  }
}

