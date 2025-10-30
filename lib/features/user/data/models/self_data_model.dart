class SelfDataModel {
  final int userId;
  final String userName;
  final String mobile;
  final String? email;
  final String gender;
  final int roleId;
  final String? profilePic;
  final int? membershipId;
  final int? planId;
  final int? gymId;
  final bool visitedToday;
  final int unreadNotificationCount;
  final dynamic activeMembershipDetails;
  final dynamic planDetails;

  SelfDataModel({
    required this.userId,
    required this.userName,
    required this.mobile,
    this.email,
    required this.gender,
    required this.roleId,
    this.profilePic,
    this.membershipId,
    this.planId,
    this.gymId,
    required this.visitedToday,
    this.unreadNotificationCount = 0,
    this.activeMembershipDetails,
    this.planDetails,
  });

  factory SelfDataModel.fromJson(Map<String, dynamic> json) {
    return SelfDataModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      gender: json['gender'] ?? '',
      roleId: json['roleId'] ?? 5,
      profilePic: json['profilePic'],
      membershipId: json['membershipId'],
      planId: json['planId'],
      gymId: json['gymId'],
      visitedToday: json['visitedToday'] ?? false,
      unreadNotificationCount: json['unreadNotificationCount'] ?? 0,
      activeMembershipDetails: json['activeMembershipDetails'],
      planDetails: json['planDetails'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'mobile': mobile,
        'email': email,
        'gender': gender,
        'roleId': roleId,
        'profilePic': profilePic,
        'membershipId': membershipId,
        'planId': planId,
        'gymId': gymId,
        'visitedToday': visitedToday,
        'unreadNotificationCount': unreadNotificationCount,
        'activeMembershipDetails': activeMembershipDetails,
        'planDetails': planDetails,
      };

  String get genderDisplay {
    switch (gender.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return 'Not specified';
    }
  }
}

