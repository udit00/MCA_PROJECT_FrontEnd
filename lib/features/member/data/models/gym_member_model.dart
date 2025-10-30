import 'package:intl/intl.dart';

/// Model representing a gym member with their active plan and feedback rating
class GymMemberModel {
  final int userId;
  final String userName;
  final String mobile;
  final String? email;
  final String gender;
  final String? profilePic;
  final int membershipId;
  final int planId;
  final String planName;
  final double planPrice;
  final int planDuration;
  final DateTime startDate;
  final DateTime endDate;
  final String membershipStatus;
  final int? feedbackId;
  final int? rating;
  final String? comments;
  final DateTime? feedbackDate;

  GymMemberModel({
    required this.userId,
    required this.userName,
    required this.mobile,
    this.email,
    required this.gender,
    this.profilePic,
    required this.membershipId,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.startDate,
    required this.endDate,
    required this.membershipStatus,
    this.feedbackId,
    this.rating,
    this.comments,
    this.feedbackDate,
  });

  factory GymMemberModel.fromJson(Map<String, dynamic> json) {
    return GymMemberModel(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      gender: json['gender'] as String,
      profilePic: json['profilePic'] as String?,
      membershipId: json['membershipId'] as int,
      planId: json['planId'] as int,
      planName: json['planName'] as String,
      planPrice: (json['planPrice'] as num).toDouble(),
      planDuration: json['planDuration'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      membershipStatus: json['membershipStatus'] as String,
      feedbackId: json['feedbackId'] as int?,
      rating: json['rating'] as int?,
      comments: json['comments'] as String?,
      feedbackDate: json['feedbackDate'] != null
          ? DateTime.parse(json['feedbackDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'mobile': mobile,
      'email': email,
      'gender': gender,
      'profilePic': profilePic,
      'membershipId': membershipId,
      'planId': planId,
      'planName': planName,
      'planPrice': planPrice,
      'planDuration': planDuration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'membershipStatus': membershipStatus,
      'feedbackId': feedbackId,
      'rating': rating,
      'comments': comments,
      'feedbackDate': feedbackDate?.toIso8601String(),
    };
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

  /// Formatted plan price
  String get formattedPrice => '₹${NumberFormat('#,##0').format(planPrice)}';

  /// Formatted membership duration
  String get formattedDuration {
    if (planDuration < 30) {
      return '$planDuration days';
    } else if (planDuration < 365) {
      final months = (planDuration / 30).round();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (planDuration / 365).round();
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  /// Check if member has given feedback
  bool get hasFeedback => feedbackId != null && rating != null;

  /// Days until membership expiry
  int get daysUntilExpiry => endDate.difference(DateTime.now()).inDays;

  /// Is membership expiring soon (within 10 days)
  bool get isExpiringSoon => daysUntilExpiry <= 10 && daysUntilExpiry > 0;

  /// Is membership expired
  bool get isExpired => daysUntilExpiry < 0;
}

