import 'package:flutter/material.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/auth/data/models/login_request_model.dart';
import 'package:zymm/features/auth/data/models/login_response_model.dart';
import 'package:zymm/features/auth/data/repositories/auth_repository_impl.dart';

enum ViewState { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponseModel? _loginResponse;
  LoginResponseModel? get loginResponse => _loginResponse;

  Future<void> login(String emailOrMobile, String password) async {
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
      );
      final response = await _repository.login(request);

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'An unknown error occurred';
      } else {
        _loginResponse = LoginResponseModel.fromJson(response.data);
        // Set auth token for subsequent API calls
        ApiService().setAuthToken(_loginResponse?.authToken);
        _state = ViewState.success;
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
