import 'package:flutter/material.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/core/network/network_info.dart';
import 'package:zymm/features/auth/data/models/registration_request_model.dart';
import 'package:zymm/features/auth/data/models/registration_response_model.dart';
import 'package:zymm/features/auth/data/repositories/auth_repository_impl.dart';

enum ViewState { idle, loading, success, error }

class RegistrationViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RegistrationResponseModel? _registrationResponse;
  RegistrationResponseModel? get registrationResponse => _registrationResponse;

  Future<void> register({
    required String displayName,
    required String mobile,
    required String password,
    required String gender,
    String? email,
    String locationLat = "",
    String locationLong = "",
  }) async {
    // Validation
    if (displayName.isEmpty || mobile.isEmpty || password.isEmpty || gender.isEmpty) {
      _state = ViewState.error;
      _errorMessage = 'Please fill all required fields.';
      notifyListeners();
      return;
    }

    // Validate mobile number (basic validation)
    if (mobile.length < 10) {
      _state = ViewState.error;
      _errorMessage = 'Please enter a valid mobile number.';
      notifyListeners();
      return;
    }

    // Validate password length
    if (password.length < 6) {
      _state = ViewState.error;
      _errorMessage = 'Password must be at least 6 characters long.';
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final request = RegistrationRequestModel(
        displayName: displayName,
        mobile: mobile,
        password: password,
        gender: gender,
        email: email?.isNotEmpty == true ? email : null,
        locationLat: locationLat,
        locationLong: locationLong,
        ipAddress: await NetworkInfo.getLocalIpAddress(),
      );

      final response = await _repository.register(request);

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
}





