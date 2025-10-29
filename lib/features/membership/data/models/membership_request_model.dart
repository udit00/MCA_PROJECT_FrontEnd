import 'package:flutter/material.dart';

class MembershipRequestModel {
  final int membershipId;
  final int userId;
  final String userName;
  final String? userEmail;
  final String userMobile;
  final int planId;
  final String planName;
  final int planPrice;
  final int planDuration;
  final String membershipStatus;
  final DateTime requestedOn;
  final DateTime? approvedOn;
  final DateTime? startDate;
  final DateTime? endDate;

  MembershipRequestModel({
    required this.membershipId,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.userMobile,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.membershipStatus,
    required this.requestedOn,
    this.approvedOn,
    this.startDate,
    this.endDate,
  });

  factory MembershipRequestModel.fromJson(Map<String, dynamic> json) {
    return MembershipRequestModel(
      membershipId: json['membershipId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String?,
      userMobile: json['userMobile'] as String,
      planId: json['planId'] as int,
      planName: json['planName'] as String,
      planPrice: json['planPrice'] as int,
      planDuration: json['planDuration'] as int,
      membershipStatus: json['membershipStatus'] as String,
      requestedOn: DateTime.parse(json['requestedOn'] as String),
      approvedOn: json['approvedOn'] != null 
          ? DateTime.parse(json['approvedOn'] as String) 
          : null,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
    );
  }

  /// Check if request is pending
  bool get isPending => membershipStatus.toUpperCase() == 'P';

  /// Check if request is approved
  bool get isApproved => membershipStatus.toUpperCase() == 'A';

  /// Check if request is rejected
  bool get isRejected => membershipStatus.toUpperCase() == 'R';

  /// Get status display text
  String get statusText {
    switch (membershipStatus.toUpperCase()) {
      case 'P':
        return 'Pending';
      case 'A':
        return 'Approved';
      case 'R':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  /// Get status color
  Color get statusColor {
    switch (membershipStatus.toUpperCase()) {
      case 'P':
        return Colors.orange;
      case 'A':
        return Colors.green;
      case 'R':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class RequestPlanModel {
  final int planId;

  RequestPlanModel({required this.planId});

  Map<String, dynamic> toJson() {
    return {'planId': planId};
  }
}

class TakeActionRequestModel {
  final int membershipId;
  final String actionTaken;

  TakeActionRequestModel({
    required this.membershipId,
    required this.actionTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'membershipId': membershipId,
      'actionTaken': actionTaken,
    };
  }

  /// Create accept action
  factory TakeActionRequestModel.accept(int membershipId) {
    return TakeActionRequestModel(
      membershipId: membershipId,
      actionTaken: 'A',
    );
  }

  /// Create reject action
  factory TakeActionRequestModel.reject(int membershipId) {
    return TakeActionRequestModel(
      membershipId: membershipId,
      actionTaken: 'R',
    );
  }
}

