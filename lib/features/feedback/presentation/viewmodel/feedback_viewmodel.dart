import 'package:flutter/material.dart';
import 'package:zymm/features/feedback/data/models/create_feedback_request_model.dart';
import 'package:zymm/features/feedback/data/models/feedback_model.dart';
import 'package:zymm/features/feedback/data/models/gym_model.dart';
import 'package:zymm/features/feedback/data/repositories/feedback_repository.dart';

enum FeedbackViewState { idle, loading, success, error, submitting }

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();

  FeedbackViewState _state = FeedbackViewState.idle;
  FeedbackViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<FeedbackModel> _feedbacks = [];
  List<FeedbackModel> get feedbacks => _feedbacks;

  FeedbackModel? _currentFeedback;
  FeedbackModel? get currentFeedback => _currentFeedback;

  GymModel? _currentGym;
  GymModel? get currentGym => _currentGym;

  /// Create a new feedback
  Future<bool> createFeedback(CreateFeedbackRequestModel request) async {
    if (!request.isValidRating) {
      _state = FeedbackViewState.error;
      _errorMessage = 'Rating must be between 1 and 5';
      notifyListeners();
      return false;
    }

    _state = FeedbackViewState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.createFeedback(request);

      if (response.hasError) {
        _state = FeedbackViewState.error;
        _errorMessage = response.error ?? 'Failed to submit feedback';
        notifyListeners();
        return false;
      } else {
        _state = FeedbackViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = FeedbackViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get all feedbacks for a gym
  Future<void> getAllFeedbacksByGymId(int gymId) async {
    _state = FeedbackViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllByGymId(gymId);

      if (response.hasError) {
        final errorMsg = response.error?.toLowerCase() ?? '';
        if (errorMsg.contains('no') && (errorMsg.contains('data') || errorMsg.contains('feedback') || errorMsg.contains('found'))) {
          _feedbacks = [];
          _state = FeedbackViewState.success;
        } else {
          _state = FeedbackViewState.error;
          _errorMessage = response.error ?? 'Failed to fetch feedbacks';
        }
      } else {
        if (response.data == null) {
          _feedbacks = [];
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _feedbacks = data.map((json) => FeedbackModel.fromJson(json)).toList();
          // Sort by createdAt, most recent first
          _feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _feedbacks = [];
        }
        _state = FeedbackViewState.success;
      }
    } catch (e) {
      _state = FeedbackViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get a single feedback by ID
  Future<void> getFeedbackById(int feedbackId) async {
    _state = FeedbackViewState.loading;
    _errorMessage = null;
    _currentFeedback = null;
    notifyListeners();

    try {
      final response = await _repository.getFeedbackById(feedbackId);

      if (response.hasError) {
        _state = FeedbackViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch feedback';
      } else {
        if (response.data != null) {
          _currentFeedback = FeedbackModel.fromJson(response.data);
        }
        _state = FeedbackViewState.success;
      }
    } catch (e) {
      _state = FeedbackViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get gym data by ID
  Future<void> getGymData(int gymId) async {
    _state = FeedbackViewState.loading;
    _errorMessage = null;
    _currentGym = null;
    notifyListeners();

    try {
      final response = await _repository.getGymData(gymId);

      if (response.hasError) {
        _state = FeedbackViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch gym data';
      } else {
        if (response.data != null) {
          _currentGym = GymModel.fromJson(response.data);
        }
        _state = FeedbackViewState.success;
      }
    } catch (e) {
      _state = FeedbackViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get average rating from feedbacks list
  double get averageRating {
    if (_feedbacks.isEmpty) return 0.0;
    final sum = _feedbacks.fold<int>(0, (sum, feedback) => sum + feedback.rating);
    return sum / _feedbacks.length;
  }

  /// Get rating distribution (count of each rating 1-5)
  Map<int, int> get ratingDistribution {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final feedback in _feedbacks) {
      distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
    }
    return distribution;
  }

  /// Clear current feedback
  void clearCurrentFeedback() {
    _currentFeedback = null;
    notifyListeners();
  }

  /// Clear current gym
  void clearCurrentGym() {
    _currentGym = null;
    notifyListeners();
  }

  /// Reset state
  void resetState() {
    _state = FeedbackViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

