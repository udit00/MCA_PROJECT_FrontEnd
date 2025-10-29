import 'package:flutter/material.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/user/data/repositories/user_repository.dart';

enum ViewState { idle, loading, success, error }

class ChangePasswordViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final StorageService _storage = StorageService.instance;

  ViewState _state = ViewState.idle;
  String? _errorMessage;
  String? _successMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void resetState() {
    _state = ViewState.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _state = ViewState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Save the new auth token
      await _storage.saveAuthToken(response.authToken);

      _state = ViewState.success;
      _successMessage = 'Password changed successfully!';
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

