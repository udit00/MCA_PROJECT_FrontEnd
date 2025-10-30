class EmployeeModel {
  final int employeeId;
  final int userId;
  final int gymId;
  final int createdBy;
  final DateTime startedWorking;

  EmployeeModel({
    required this.employeeId,
    required this.userId,
    required this.gymId,
    required this.createdBy,
    required this.startedWorking,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeId'] ?? 0,
      userId: json['userId'] ?? 0,
      gymId: json['gymId'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      startedWorking: DateTime.parse(json['startedWorking']),
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'userId': userId,
        'gymId': gymId,
        'createdBy': createdBy,
        'startedWorking': startedWorking.toIso8601String(),
      };

  String get formattedStartDate {
    return '${startedWorking.day}/${startedWorking.month}/${startedWorking.year}';
  }

  String get formattedStartDateTime {
    final hour = startedWorking.hour.toString().padLeft(2, '0');
    final minute = startedWorking.minute.toString().padLeft(2, '0');
    return '$formattedStartDate at $hour:$minute';
  }
}

