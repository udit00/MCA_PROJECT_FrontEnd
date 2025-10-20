import 'package:flutter/foundation.dart';
import 'package:zymm/core/storage/storage_service.dart';

enum AuthState { loading, authenticated, unauthenticated }

class OnboardingViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;

  AuthState _state = AuthState.loading;
  AuthState get state => _state;

  Future<void> checkAuthStatus() async {
    final token = await _storageService.getAuthToken();

    if (token == null || token.isEmpty) {
      _state = AuthState.unauthenticated;
    } else {
      _state = AuthState.authenticated;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.clearAuthToken();
    _state = AuthState.unauthenticated;
    notifyListeners();
  }



}