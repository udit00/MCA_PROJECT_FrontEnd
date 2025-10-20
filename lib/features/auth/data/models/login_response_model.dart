class LoginResponseModel {
  final String? displayName;
  final String? authToken;

  LoginResponseModel({this.displayName, this.authToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      displayName: json['displayName'] as String?,
      authToken: json['authCheckSum'] as String?,
    );
  }
}
