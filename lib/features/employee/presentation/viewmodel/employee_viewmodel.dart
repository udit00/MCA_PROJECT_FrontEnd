import 'package:flutter/material.dart';
import 'package:zymm/features/employee/data/models/employee_model.dart';
import 'package:zymm/features/employee/data/repositories/employee_repository.dart';

enum EmployeeViewState { idle, loading, success, error }

class EmployeeViewModel extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  EmployeeViewState _state = EmployeeViewState.idle;
  EmployeeViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> get employees => _employees;

  EmployeeModel? _currentEmployee;
  EmployeeModel? get currentEmployee => _currentEmployee;

  Future<void> getAllEmployeesByGymId(int gymId) async {
    _state = EmployeeViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _repository.getAllEmployeesByGymId(gymId);
      _state = EmployeeViewState.success;
      notifyListeners();
    } catch (e) {
      _state = EmployeeViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getEmployeeById(int employeeId) async {
    _state = EmployeeViewState.loading;
    _errorMessage = null;
    _currentEmployee = null;
    notifyListeners();

    try {
      _currentEmployee = await _repository.getEmployeeById(employeeId);
      _state = EmployeeViewState.success;
      notifyListeners();
    } catch (e) {
      _state = EmployeeViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deactivateEmployee(int employeeId) async {
    _state = EmployeeViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.deactivateEmployee(employeeId);
      if (response.hasError) {
        _state = EmployeeViewState.error;
        _errorMessage = response.error ?? 'Failed to deactivate employee';
        notifyListeners();
        return false;
      }
      _state = EmployeeViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = EmployeeViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateEmployee(int employeeId) async {
    _state = EmployeeViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.activateEmployee(employeeId);
      if (response.hasError) {
        _state = EmployeeViewState.error;
        _errorMessage = response.error ?? 'Failed to activate employee';
        notifyListeners();
        return false;
      }
      _state = EmployeeViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = EmployeeViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}


