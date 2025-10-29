class PlanHistoryModel {
  final int membershipId;
  final int userId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String membershipStatus;
  final DateTime createdAt;

  PlanHistoryModel({
    required this.membershipId,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.membershipStatus,
    required this.createdAt,
  });

  factory PlanHistoryModel.fromJson(Map<String, dynamic> json) {
    return PlanHistoryModel(
      membershipId: json['membershipId'] as int,
      userId: json['userId'] as int,
      planId: json['planId'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      membershipStatus: json['membershipStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Check if status is Pending
  bool get isPending => membershipStatus.toUpperCase() == 'P';

  /// Check if status is Approved
  bool get isApproved => membershipStatus.toUpperCase() == 'A';

  /// Check if status is Rejected
  bool get isRejected => membershipStatus.toUpperCase() == 'R';
}

class CancelMembershipRequestModel {
  final int membershipId;

  CancelMembershipRequestModel({required this.membershipId});

  Map<String, dynamic> toJson() {
    return {'membershipId': membershipId};
  }
}

