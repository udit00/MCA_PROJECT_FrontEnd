class DeleteProfileRequestModel {
  final String password;

  DeleteProfileRequestModel({
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'password': password,
      };
}

