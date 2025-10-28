class PunchInRequestModel {
  final String address;
  final String locationLat;
  final String locationLong;

  PunchInRequestModel({
    required this.address,
    required this.locationLat,
    required this.locationLong,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'locationLat': locationLat,
        'locationLong': locationLong,
      };
}

class PunchOutRequestModel {
  final String address;
  final String locationLat;
  final String locationLong;

  PunchOutRequestModel({
    required this.address,
    required this.locationLat,
    required this.locationLong,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'locationLat': locationLat,
        'locationLong': locationLong,
      };
}

class DeleteAttendanceRequestModel {
  final int attendanceId;

  DeleteAttendanceRequestModel({required this.attendanceId});

  Map<String, dynamic> toJson() => {
        'attendanceId': attendanceId,
      };
}

