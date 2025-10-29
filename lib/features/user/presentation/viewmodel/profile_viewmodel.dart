import 'package:flutter/material.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/user/data/models/self_data_model.dart';
import 'package:zymm/features/user/data/repositories/user_repository.dart';

enum ViewState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final StorageService _storage = StorageService.instance;

  ViewState _state = ViewState.idle;
  String? _errorMessage;
  SelfDataModel? _userData;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  SelfDataModel? get userData => _userData;

  Future<void> fetchUserData() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _userData = await _repository.getSelfDataParsed();
      _state = ViewState.success;
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAllOnLogout();
  }

  Future<void> deleteAccount(String password) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProfile(password: password);
      await _storage.clearAllOnLogout();
      _state = ViewState.success;
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

