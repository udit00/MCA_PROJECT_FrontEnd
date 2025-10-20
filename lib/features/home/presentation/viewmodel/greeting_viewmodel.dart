import 'package:flutter/material.dart';
import 'package:zymm/features/user/data/repositories/user_repository.dart';

enum GreetingState { loading, success, error }

class GreetingViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  GreetingState _state = GreetingState.loading;
  GreetingState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSelfData() async {
    _state = GreetingState.loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _repository.getSelfData();
      if (response.hasError) {
        _state = GreetingState.error;
        _errorMessage = response.error ?? 'An unknown error occurred.';
      } else {
        _state = GreetingState.success;
      }
    } catch (e) {
      _state = GreetingState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
