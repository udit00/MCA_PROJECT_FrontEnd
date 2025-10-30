class EmployeeRegistrationRequestModel {
  final String? displayPic;
  final String displayName;
  final String mobile;
  final String? email;
  final String password;
  final String gender;
  final int roleId;
  final String locationLat;
  final String locationLong;
  final String appVersion;
  final String userAgent;
  final String ipAddress;

  EmployeeRegistrationRequestModel({
    this.displayPic,
    required this.displayName,
    required this.mobile,
    this.email,
    required this.password,
    required this.gender,
    required this.roleId,
    required this.locationLat,
    required this.locationLong,
    required this.appVersion,
    required this.userAgent,
    required this.ipAddress,
  });

  Map<String, dynamic> toJson() => {
        'displayPic': displayPic,
        'displayName': displayName,
        'mobile': mobile,
        'email': email,
        'password': password,
        'gender': gender,
        'roleId': roleId,
        'locationLat': locationLat,
        'locationLong': locationLong,
        'appVersion': appVersion,
        'userAgent': userAgent,
        'ipAddress': ipAddress,
      };
}

