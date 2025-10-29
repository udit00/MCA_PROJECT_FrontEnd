import 'package:flutter/material.dart';

class MembershipModel {
  final int membershipId;
  final int userId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String membershipStatus;
  final DateTime createdAt;

  MembershipModel({
    required this.membershipId,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.membershipStatus,
    required this.createdAt,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
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

