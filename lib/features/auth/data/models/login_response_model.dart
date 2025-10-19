class LoginResponseModel {
  final String displayName;
  final String authToken;

  LoginResponseModel({required this.displayName, required this.authToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      displayName: json['displayName'],
      authToken: json['authCheckSum'],
    );
  }
}
