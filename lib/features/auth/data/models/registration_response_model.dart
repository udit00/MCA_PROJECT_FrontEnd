class RegistrationResponseModel {
  final String? displayName;
  final String? authToken;

  RegistrationResponseModel({this.displayName, this.authToken});

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      displayName: json['displayName'] as String?,
      authToken: json['authCheckSum'] as String?,
    );
  }
}

