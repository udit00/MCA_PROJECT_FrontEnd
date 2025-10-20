
class LoginRequestModel {
  final String emailOrMobile;
  final String password;
  final String appVersion;
  final String userAgent;
  final String locationLat;
  final String locationLong;
  final String ipAddress;
  final String platform;

  LoginRequestModel({
    required this.emailOrMobile,
    required this.password,
    this.appVersion = "0.0.1",
    this.userAgent = "Android",
    this.locationLat = "",
    this.locationLong = "",
    this.ipAddress = "",
    this.platform = "Android",
  });

  Map<String, dynamic> toJson() => {
        "email_or_mobile": emailOrMobile,
        "password": password,
        "app_version": appVersion,
        "user_agent": userAgent,
        "location_lat": locationLat,
        "location_long": locationLong,
        "ip_address": ipAddress,
        "platform": platform,
      };
}
