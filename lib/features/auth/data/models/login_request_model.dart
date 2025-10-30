
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
    required this.appVersion,
    required this.userAgent,
    required this.locationLat,
    required this.locationLong,
    required this.ipAddress,
    required this.platform,
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
