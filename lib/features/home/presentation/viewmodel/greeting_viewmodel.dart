import 'package:flutter/material.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
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

  int? _gymId;
  int? get gymId => _gymId;

  Future<void> fetchSelfData() async {
    _state = GreetingState.loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _repository.getSelfData();
      if (response.hasError) {
        // Clear all storage and mark as error
        await StorageService.instance.clearAllOnLogout();
        _state = GreetingState.error;
        _errorMessage = response.error ?? 'An unknown error occurred.';
      } else {
        // Extract roleId and gymId from response
        if (response.data != null && response.data is Map<String, dynamic>) {
          final roleId = response.data['roleId'] as int?;
          if (roleId != null) {
            _userRole = UserRole.fromId(roleId);
            await StorageService.instance.saveRoleId(roleId);
          }
          
          final gymId = response.data['gymId'] as int?;
          if (gymId != null) {
            _gymId = gymId;
            await StorageService.instance.saveGymId(gymId);
          }
        }
        _state = GreetingState.success;
      }
    } catch (e) {
      // Clear all storage on any exception
      await StorageService.instance.clearAllOnLogout();
      _state = GreetingState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
