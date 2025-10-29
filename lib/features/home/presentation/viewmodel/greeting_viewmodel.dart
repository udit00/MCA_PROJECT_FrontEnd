import 'package:flutter/material.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/features/user/data/repositories/user_repository.dart';

enum GreetingState { loading, success, error }

class GreetingViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  GreetingState _state = GreetingState.loading;
  GreetingState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserRole _userRole = UserRole.member; // Default to member
  UserRole get userRole => _userRole;

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
        // Extract roleId from response
        if (response.data != null && response.data is Map<String, dynamic>) {
          final roleId = response.data['roleId'] as int?;
          if (roleId != null) {
            _userRole = UserRole.fromId(roleId);
          }
        }
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
