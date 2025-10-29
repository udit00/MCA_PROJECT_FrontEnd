class ChangePasswordResponseModel {
  final String authToken;

  ChangePasswordResponseModel({
    required this.authToken,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      authToken: json['authToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'authToken': authToken,
      };
}

