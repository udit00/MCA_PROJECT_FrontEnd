
class RegistrationRequestModel {
  final String displayName;
  final String mobile;
  final String password;
  final String gender;
  final String? email;
  final String? displayPic;
  final String appVersion;
  final String userAgent;
  final String locationLat;
  final String locationLong;
  final String ipAddress;

  RegistrationRequestModel({
    required this.displayName,
    required this.mobile,
    required this.password,
    required this.gender,
    this.email,
    this.displayPic,
    this.appVersion = "0.0.1",
    this.userAgent = "Android",
    this.locationLat = "",
    this.locationLong = "",
    this.ipAddress = "",
  });

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "mobile": mobile,
        "password": password,
        "gender": gender,
        "email": email,
        "displayPic": displayPic,
        "appVersion": appVersion,
        "userAgent": userAgent,
        "locationLat": locationLat,
        "locationLong": locationLong,
        "ipAddress": ipAddress,
      };
}

