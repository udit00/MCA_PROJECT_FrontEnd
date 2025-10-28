import 'package:flutter/material.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/auth/data/models/login_request_model.dart';
import 'package:zymm/features/auth/data/models/login_response_model.dart';
import 'package:zymm/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../../core/network/network_info.dart';

enum ViewState { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponseModel? _loginResponse;
  LoginResponseModel? get loginResponse => _loginResponse;



  Future<void> login(String emailOrMobile, String password, {String locationLat = "", String locationLong = ""}) async {
    if (emailOrMobile.isEmpty || password.isEmpty) {
      _state = ViewState.error;
      _errorMessage = 'Please enter both username and password.';
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final request = LoginRequestModel(
        emailOrMobile: emailOrMobile,
        password: password,
        locationLat: locationLat,
        locationLong: locationLong,
        ipAddress: await NetworkInfo.getLocalIpAddress(),
      );
      final response = await _repository.login(request);
      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'An unknown error occurred';
      } else {
        _loginResponse = LoginResponseModel.fromJson(response.data);
        if(_loginResponse != null && _loginResponse?.authToken?.isNotEmpty == true && _loginResponse?.displayName?.isNotEmpty == true) {
          StorageService.instance.saveAuthToken(_loginResponse!.authToken!);
          StorageService.instance.saveDisplayName(_loginResponse!.displayName!);
          _state = ViewState.success;
        } else {
          if(_loginResponse == null) {
            _errorMessage = 'Something went wrong with our server, please try again later.';
          } else if(_loginResponse?.authToken?.isEmpty == true) {
            _errorMessage = 'Error generating Auth Token, please try again later.';
          } else if(_loginResponse?.displayName?.isEmpty == true) {
            _errorMessage = 'Error while trying to log you in, please try again later.';
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
