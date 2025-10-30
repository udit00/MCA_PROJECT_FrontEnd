class EmployeeModel {
  final int employeeId;
  final int userId;
  final int gymId;
  final int createdBy;
  final DateTime startedWorking;
  final String userName;
  final String mobile;
  final String? email;
  final String gender;
  final String? profilePic;
  final int roleId;
  final bool isActive;

  EmployeeModel({
    required this.employeeId,
    required this.userId,
    required this.gymId,
    required this.createdBy,
    required this.startedWorking,
    required this.userName,
    required this.mobile,
    this.email,
    required this.gender,
    this.profilePic,
    required this.roleId,
    required this.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeId'] ?? 0,
      userId: json['userId'] ?? 0,
      gymId: json['gymId'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      startedWorking: DateTime.parse(json['startedWorking']),
      userName: json['userName'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      gender: json['gender'] ?? '',
      profilePic: json['profilePic'],
      roleId: json['roleId'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'userId': userId,
        'gymId': gymId,
        'createdBy': createdBy,
        'startedWorking': startedWorking.toIso8601String(),
        'userName': userName,
        'mobile': mobile,
        'email': email,
        'gender': gender,
        'profilePic': profilePic,
        'roleId': roleId,
        'isActive': isActive,
      };

  String get formattedStartDate {
    return '${startedWorking.day}/${startedWorking.month}/${startedWorking.year}';
  }

  String get formattedStartDateTime {
    final hour = startedWorking.hour.toString().padLeft(2, '0');
    final minute = startedWorking.minute.toString().padLeft(2, '0');
    return '$formattedStartDate at $hour:$minute';
  }

  String get initials {
    if (userName.isEmpty) return '?';
    final names = userName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }
}

