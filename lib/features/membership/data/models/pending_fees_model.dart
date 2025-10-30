class PendingFeesModel {
  final int userId;
  final String userName;
  final String mobile;
  final String? email;
  final String? profilePic;
  final int membershipId;
  final int planId;
  final String planName;
  final double planPrice;
  final DateTime startDate;
  final DateTime endDate;
  final int daysUntilExpiry; // Negative if expired
  final bool isExpired;
  final String membershipStatus;

  PendingFeesModel({
    required this.userId,
    required this.userName,
    required this.mobile,
    this.email,
    this.profilePic,
    required this.membershipId,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.startDate,
    required this.endDate,
    required this.daysUntilExpiry,
    required this.isExpired,
    required this.membershipStatus,
  });

  factory PendingFeesModel.fromJson(Map<String, dynamic> json) {
    return PendingFeesModel(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      profilePic: json['profilePic'] as String?,
      membershipId: json['membershipId'] as int,
      planId: json['planId'] as int,
      planName: json['planName'] as String,
      planPrice: (json['planPrice'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      daysUntilExpiry: json['daysUntilExpiry'] as int,
      isExpired: json['isExpired'] as bool,
      membershipStatus: json['membershipStatus'] as String,
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

  /// Get formatted price
  String get formattedPrice => '₹${planPrice.toStringAsFixed(0)}';

  /// Get expiry status message
  String get expiryMessage {
    if (isExpired) {
      final daysSinceExpiry = -daysUntilExpiry;
      return 'Expired $daysSinceExpiry ${daysSinceExpiry == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Expiring in $daysUntilExpiry ${daysUntilExpiry == 1 ? 'day' : 'days'}';
    }
  }
}

