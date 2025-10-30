import 'package:flutter/material.dart';
import 'package:zymm/features/employee/data/models/employee_registration_request_model.dart';
import 'package:zymm/features/employee/data/models/employee_registration_response_model.dart';
import 'package:zymm/features/employee/data/repositories/employee_repository.dart';

enum ViewState { idle, loading, success, error }

class EmployeeRegistrationViewModel extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeRegistrationResponseModel? _registrationResponse;
  EmployeeRegistrationResponseModel? get registrationResponse => _registrationResponse;

  void startEmployeeRegistrationProcess() {
    _state = ViewState.loading;
    notifyListeners();
  }

  Future<void> createEmployee({
    String? displayPic,
    required String displayName,
    required String mobile,
    String? email,
    required String password,
    required String gender,
    required int roleId,
    required double locationLat,
    required double locationLong,
    required String appVersion,
    required String userAgent,
    required String ipAddress,
  }) async {
    _state = ViewState.loading;
    _errorMessage = null;
    _registrationResponse = null;
    notifyListeners();

    try {
      final request = EmployeeRegistrationRequestModel(
        displayPic: displayPic,
        displayName: displayName,
        mobile: mobile,
        email: email,
        password: password,
        gender: gender,
        roleId: roleId,
        locationLat: locationLat.toString(),
        locationLong: locationLong.toString(),
        appVersion: appVersion,
        userAgent: userAgent,
        ipAddress: ipAddress,
      );

      _registrationResponse = await _repository.createEmployee(request);
      _state = ViewState.success;
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void resetState() {
    _state = ViewState.idle;
    // _errorMessage = null;
    _registrationResponse = null;
    notifyListeners();
  }
}

