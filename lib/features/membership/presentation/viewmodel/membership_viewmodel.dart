import 'package:flutter/material.dart';
import 'package:zymm/features/membership/data/models/membership_model.dart';
import 'package:zymm/features/membership/data/models/membership_request_model.dart';
import 'package:zymm/features/membership/data/models/plan_history_model.dart';
import 'package:zymm/features/membership/data/models/plan_model.dart';
import 'package:zymm/features/membership/data/models/upsert_plan_request_model.dart';
import 'package:zymm/features/membership/data/repositories/membership_repository.dart';

enum MembershipViewState { idle, loading, success, error, submitting }

class MembershipViewModel extends ChangeNotifier {
  final MembershipRepository _repository = MembershipRepository();

  MembershipViewState _state = MembershipViewState.idle;
  MembershipViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PlanModel> _plans = [];
  List<PlanModel> get plans => _plans;

  PlanModel? _currentPlan;
  PlanModel? get currentPlan => _currentPlan;

  List<MembershipModel> _memberships = [];
  List<MembershipModel> get memberships => _memberships;

  PlanHistoryModel? _pendingPlanRequest;
  PlanHistoryModel? get pendingPlanRequest => _pendingPlanRequest;

  int _processingRequestId = -1;

  /// Check if a specific request is being processed
  bool isProcessingRequest(int membershipId) {
    return _state == MembershipViewState.submitting && 
           _processingRequestId == membershipId;
  }

  /// Create or update a plan
  Future<bool> upsertPlan(UpsertPlanRequestModel request) async {
    _state = MembershipViewState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.upsertPlan(request);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to save plan';
        notifyListeners();
        return false;
      } else {
        _state = MembershipViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get plan details by ID
  Future<void> getPlanDetails(int planId) async {
    _state = MembershipViewState.loading;
    _errorMessage = null;
    _currentPlan = null;
    notifyListeners();

    try {
      final response = await _repository.getPlanDetails(planId);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch plan details';
      } else {
        if (response.data != null) {
          _currentPlan = PlanModel.fromJson(response.data);
        }
        _state = MembershipViewState.success;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get all plans for a gym
  Future<void> getAllPlansByGymId(int gymId) async {
    _state = MembershipViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllPlansByGymId(gymId);

      if (response.hasError) {
        final errorMsg = response.error?.toLowerCase() ?? '';
        if (errorMsg.contains('no') && (errorMsg.contains('data') || errorMsg.contains('plan') || errorMsg.contains('found'))) {
          _plans = [];
          _state = MembershipViewState.success;
        } else {
          _state = MembershipViewState.error;
          _errorMessage = response.error ?? 'Failed to fetch plans';
        }
      } else {
        if (response.data == null) {
          _plans = [];
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _plans = data.map((json) => PlanModel.fromJson(json)).toList();
        } else {
          _plans = [];
        }
        _state = MembershipViewState.success;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Request a plan (for members)
  Future<bool> requestPlan(int planId) async {
    _state = MembershipViewState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RequestPlanModel(planId: planId);
      final response = await _repository.requestPlan(request);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to request plan';
        notifyListeners();
        return false;
      } else {
        _state = MembershipViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get all memberships by filter (backend handles filtering)
  /// filterBy: P (Pending), A (Approved), R (Rejected), ALL (All)
  Future<void> getAllMemberships(String filterBy) async {
    _state = MembershipViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllMemberships(filterBy);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch memberships';
      } else {
        if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _memberships = data.map((json) => MembershipModel.fromJson(json)).toList();
          // Sort by created date, newest first
          _memberships.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _memberships = [];
        }
        _state = MembershipViewState.success;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Approve a membership request
  Future<bool> approveMembershipRequest(int membershipId) async {
    _state = MembershipViewState.submitting;
    _processingRequestId = membershipId;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = TakeActionRequestModel.accept(membershipId);
      final response = await _repository.takeActionOnMembership(request);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to approve request';
        notifyListeners();
        return false;
      } else {
        // Update local membership status
        final index = _memberships.indexWhere((m) => m.membershipId == membershipId);
        if (index != -1) {
          // Remove from list or update status
          // We'll refresh the list after action
        }
        _state = MembershipViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _processingRequestId = -1;
    }
  }

  /// Reject a membership request
  Future<bool> rejectMembershipRequest(int membershipId) async {
    _state = MembershipViewState.submitting;
    _processingRequestId = membershipId;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = TakeActionRequestModel.reject(membershipId);
      final response = await _repository.takeActionOnMembership(request);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to reject request';
        notifyListeners();
        return false;
      } else {
        _state = MembershipViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _processingRequestId = -1;
    }
  }

  /// Get all memberships (backend already filters based on filterBy parameter)
  List<MembershipModel> get allMemberships => _memberships;

  /// Get active plans
  List<PlanModel> get activePlans =>
      _plans.where((p) => p.isActive).toList();

  /// Clear current plan
  void clearCurrentPlan() {
    _currentPlan = null;
    notifyListeners();
  }

  /// Get plan history (pending requests)
  Future<void> getPlanHistory() async {
    try {
      final response = await _repository.getPlanHistory('P');

      if (response.hasError) {
        // If no pending requests, that's fine
        _pendingPlanRequest = null;
      } else {
        if (response.data != null && response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          if (data.isNotEmpty) {
            _pendingPlanRequest = PlanHistoryModel.fromJson(data[0]);
          } else {
            _pendingPlanRequest = null;
          }
        } else {
          _pendingPlanRequest = null;
        }
      }
      notifyListeners();
    } catch (e) {
      _pendingPlanRequest = null;
      notifyListeners();
    }
  }

  /// Cancel membership request
  Future<bool> cancelMembershipRequest(int membershipId) async {
    _state = MembershipViewState.submitting;
    _processingRequestId = membershipId;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CancelMembershipRequestModel(membershipId: membershipId);
      final response = await _repository.cancelMembershipRequest(request);

      if (response.hasError) {
        _state = MembershipViewState.error;
        _errorMessage = response.error ?? 'Failed to cancel request';
        notifyListeners();
        return false;
      } else {
        // Clear pending request
        _pendingPlanRequest = null;
        _state = MembershipViewState.success;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _state = MembershipViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _processingRequestId = -1;
    }
  }

  /// Check if user has requested a specific plan
  bool hasRequestedPlan(int planId) {
    return _pendingPlanRequest?.planId == planId;
  }

  /// Check if user has any pending request
  bool get hasPendingRequest => _pendingPlanRequest != null;

  /// Reset state
  void resetState() {
    _state = MembershipViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

