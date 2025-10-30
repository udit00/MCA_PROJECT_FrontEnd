import 'package:flutter/material.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/core/network/network_info.dart';
import 'package:zymm/features/auth/data/models/owner_registration_request_model.dart';
import 'package:zymm/features/auth/data/models/registration_response_model.dart';
import 'package:zymm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zymm/utils/app_info.dart';

enum ViewState { idle, loading, success, error }

class OwnerRegistrationViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RegistrationResponseModel? _registrationResponse;
  RegistrationResponseModel? get registrationResponse => _registrationResponse;

  Future<void> registerOwner({
    required String displayName,
    required String mobile,
    required String password,
    required String gender,
    String? ownerPersonalEmail,
    required String gymName,
    required String state,
    required String city,
    required String gymAddress,
    required String gymOfficialContactNo,
    required String gymOfficialEmail,
    required String gymOfficialLocationLat,
    required String gymOfficialLocationLong,
  }) async {
    // Validation
    if (displayName.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        gender.isEmpty ||
        gymName.isEmpty ||
        state.isEmpty ||
        city.isEmpty ||
        gymAddress.isEmpty ||
        gymOfficialContactNo.isEmpty ||
        gymOfficialEmail.isEmpty) {
      _state = ViewState.error;
      _errorMessage = 'Please fill all required fields.';
      notifyListeners();
      return;
    }

    // Validate mobile number
    if (mobile.length < 10) {
      _state = ViewState.error;
      _errorMessage = 'Please enter a valid mobile number.';
      notifyListeners();
      return;
    }

    // Validate gym contact number
    if (gymOfficialContactNo.length < 10) {
      _state = ViewState.error;
      _errorMessage = 'Please enter a valid gym contact number.';
      notifyListeners();
      return;
    }

    // Validate password
    if (password.length < 6) {
      _state = ViewState.error;
      _errorMessage = 'Password must be at least 6 characters long.';
      notifyListeners();
      return;
    }

    // Validate email
    if (!gymOfficialEmail.contains('@') || !gymOfficialEmail.contains('.')) {
      _state = ViewState.error;
      _errorMessage = 'Please enter a valid gym official email.';
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final request = OwnerRegistrationRequestModel(
        displayName: displayName,
        mobile: mobile,
        password: password,
        gender: gender,
        ownerPersonalEmail: ownerPersonalEmail?.isNotEmpty == true ? ownerPersonalEmail : null,
        gymName: gymName,
        state: state,
        city: city,
        gymAddress: gymAddress,
        gymOfficialContactNo: gymOfficialContactNo,
        gymOfficialEmail: gymOfficialEmail,
        gymOfficialLocationLat: gymOfficialLocationLat,
        gymOfficialLocationLong: gymOfficialLocationLong,
        ipAddress: await NetworkInfo.getLocalIpAddress(),
        userAgent: AppInfo().platform,
        appVersion: AppInfo().version,
      );

      final response = await _repository.registerOwner(request);

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'An unknown error occurred';
      } else {
        _registrationResponse = RegistrationResponseModel.fromJson(response.data);

        if (_registrationResponse != null &&
            _registrationResponse?.authToken?.isNotEmpty == true &&
            _registrationResponse?.displayName?.isNotEmpty == true) {
          StorageService.instance.saveAuthToken(_registrationResponse!.authToken!);
          StorageService.instance.saveDisplayName(_registrationResponse!.displayName!);
          _state = ViewState.success;
        } else {
          if (_registrationResponse == null) {
            _errorMessage = 'Something went wrong with our server, please try again later.';
          } else if (_registrationResponse?.authToken?.isEmpty == true) {
            _errorMessage = 'Error generating Auth Token, please try again later.';
          } else if (_registrationResponse?.displayName?.isEmpty == true) {
            _errorMessage = 'Error while trying to register you, please try again later.';
          } else {
            _errorMessage = 'An unknown error occurred';
          }
          _state = ViewState.error;
        }
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Reset the viewmodel state to idle
  void resetState() {
    _state = ViewState.idle;
    _errorMessage = null;
    _registrationResponse = null;
    notifyListeners();
  }
}
