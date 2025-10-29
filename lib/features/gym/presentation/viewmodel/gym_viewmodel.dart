import 'package:flutter/material.dart';
import 'package:zymm/features/feedback/data/models/gym_model.dart';
import 'package:zymm/features/gym/data/repositories/gym_repository.dart';

enum GymViewState { idle, loading, success, error, searching }

class GymViewModel extends ChangeNotifier {
  final GymRepository _repository = GymRepository();

  GymViewState _state = GymViewState.idle;
  GymViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<GymModel> _gyms = [];
  List<GymModel> get gyms => _gyms;

  GymModel? _selectedGym;
  GymModel? get selectedGym => _selectedGym;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Search gyms by name, city, or state
  /// Empty query returns all gyms
  Future<void> searchGyms({String? query}) async {
    _searchQuery = query ?? '';
    _state = _searchQuery.isEmpty ? GymViewState.loading : GymViewState.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchGyms(query: query);

      if (response.hasError) {
        final errorMsg = response.error?.toLowerCase() ?? '';
        if (errorMsg.contains('no') && (errorMsg.contains('data') || errorMsg.contains('gym') || errorMsg.contains('found'))) {
          _gyms = [];
          _state = GymViewState.success;
        } else {
          _state = GymViewState.error;
          _errorMessage = response.error ?? 'Failed to fetch gyms';
        }
      } else {
        if (response.data == null) {
          _gyms = [];
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _gyms = data.map((json) => GymModel.fromJson(json)).toList();
        } else {
          _gyms = [];
        }
        _state = GymViewState.success;
      }
    } catch (e) {
      _state = GymViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get gym data by ID
  Future<void> getGymById(int gymId) async {
    _state = GymViewState.loading;
    _errorMessage = null;
    _selectedGym = null;
    notifyListeners();

    try {
      final response = await _repository.getGymData(gymId);

      if (response.hasError) {
        _state = GymViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch gym data';
      } else {
        if (response.data != null) {
          _selectedGym = GymModel.fromJson(response.data);
        }
        _state = GymViewState.success;
      }
    } catch (e) {
      _state = GymViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Clear selected gym
  void clearSelectedGym() {
    _selectedGym = null;
    notifyListeners();
  }

  /// Reset search query
  void clearSearch() {
    _searchQuery = '';
    searchGyms();
  }

  /// Get gyms filtered by city
  List<GymModel> getGymsByCity(String city) {
    return _gyms.where((gym) => gym.city.toLowerCase() == city.toLowerCase()).toList();
  }

  /// Get gyms filtered by state
  List<GymModel> getGymsByState(String state) {
    return _gyms.where((gym) => gym.state.toLowerCase() == state.toLowerCase()).toList();
  }

  /// Get unique cities from current gym list
  List<String> get uniqueCities {
    return _gyms.map((gym) => gym.city).toSet().toList()..sort();
  }

  /// Get unique states from current gym list
  List<String> get uniqueStates {
    return _gyms.map((gym) => gym.state).toSet().toList()..sort();
  }
}

