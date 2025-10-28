class AttendanceModel {
  final int attendanceId;
  final int userId;
  final DateTime punchInTime;
  final DateTime? punchOutTime;
  final String punchInAddress;
  final String punchInLat;
  final String punchInLong;
  final String? punchOutAddress;
  final String? punchOutLat;
  final String? punchOutLong;

  AttendanceModel({
    required this.attendanceId,
    required this.userId,
    required this.punchInTime,
    this.punchOutTime,
    required this.punchInAddress,
    required this.punchInLat,
    required this.punchInLong,
    this.punchOutAddress,
    this.punchOutLat,
    this.punchOutLong,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'] as int,
      userId: json['userId'] as int,
      punchInTime: DateTime.parse(json['punchInTime'] as String),
      punchOutTime: json['punchOutTime'] != null 
          ? DateTime.parse(json['punchOutTime'] as String) 
          : null,
      punchInAddress: json['punchInAddress'] as String,
      punchInLat: json['punchInLat'] as String,
      punchInLong: json['punchInLong'] as String,
      punchOutAddress: json['punchOutAddress'] as String?,
      punchOutLat: json['punchOutLat'] as String?,
      punchOutLong: json['punchOutLong'] as String?,
    );
  }

  bool get isPunchedOut => punchOutTime != null;
  
  Duration? get workDuration {
    if (punchOutTime != null) {
      return punchOutTime!.difference(punchInTime);
    }
    return null;
  }
}

