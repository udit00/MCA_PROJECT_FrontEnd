class OwnerRegistrationRequestModel {
  final String displayName;
  final String mobile;
  final String password;
  final String gender;
  final String? ownerPersonalEmail;
  final String? displayPic;
  final String appVersion;
  final String userAgent;
  final String ipAddress;
  
  // Gym details
  final String gymName;
  final String state;
  final String city;
  final String gymAddress;
  final String gymOfficialContactNo;
  final String gymOfficialEmail;
  final String gymOfficialLocationLat;
  final String gymOfficialLocationLong;

  OwnerRegistrationRequestModel({
    required this.displayName,
    required this.mobile,
    required this.password,
    required this.gender,
    this.ownerPersonalEmail,
    this.displayPic,
    this.appVersion = "0.0.1",
    this.userAgent = "Android",
    this.ipAddress = "",
    required this.gymName,
    required this.state,
    required this.city,
    required this.gymAddress,
    required this.gymOfficialContactNo,
    required this.gymOfficialEmail,
    this.gymOfficialLocationLat = "",
    this.gymOfficialLocationLong = "",
  });

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "mobile": mobile,
        "password": password,
        "gender": gender,
        "ownerPersonalEmail": ownerPersonalEmail,
        "displayPic": displayPic,
        "appVersion": appVersion,
        "userAgent": userAgent,
        "ipAddress": ipAddress,
        "gymName": gymName,
        "state": state,
        "city": city,
        "gymAddress": gymAddress,
        "gymOfficialContactNo": gymOfficialContactNo,
        "gymOfficialEmail": gymOfficialEmail,
        "gymOfficialLocationLat": gymOfficialLocationLat,
        "gymOfficialLocationLong": gymOfficialLocationLong,
      };
}

