class EmployeeRegistrationResponseModel {
  final String mobile;
  final String employeePassword;

  EmployeeRegistrationResponseModel({
    required this.mobile,
    required this.employeePassword,
  });

  factory EmployeeRegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeRegistrationResponseModel(
      mobile: json['Mobile'] ?? '',
      employeePassword: json['employeePassword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'Mobile': mobile,
        'employeePassword': employeePassword,
      };
}


