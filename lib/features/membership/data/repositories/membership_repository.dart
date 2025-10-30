import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/membership/data/models/membership_request_model.dart';
import 'package:zymm/features/membership/data/models/plan_history_model.dart';
import 'package:zymm/features/membership/data/models/upsert_plan_request_model.dart';

class MembershipRepository {
  final ApiService _apiService = ApiService();

  /// Create or update a plan (upsert)
  Future<CommonApiResponse> upsertPlan(UpsertPlanRequestModel request) async {
    final response = await _apiService.post('membership/upsertPlan', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  /// Get plan details by ID
  Future<CommonApiResponse> getPlanDetails(int planId) async {
    final response = await _apiService.get('membership/getPlanDetails?planId=$planId');
    return CommonApiResponse.fromJson(response);
  }

  /// Get all plans for a gym
  Future<CommonApiResponse> getAllPlansByGymId(int gymId) async {
    final response = await _apiService.get('membership/getAllPlansByGymId?gymId=$gymId');
    return CommonApiResponse.fromJson(response);
  }

  /// Request a plan (for members)
  Future<CommonApiResponse> requestPlan(RequestPlanModel request) async {
    final response = await _apiService.post('membership/requestPlan', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  /// Get all memberships by filter (for owners/managers)
  /// filterBy: P (Pending), A (Approved), R (Rejected)
  Future<CommonApiResponse> getAllMemberships(String filterBy) async {
    final response = await _apiService.get('membership/getAllMemberships?filterBy=$filterBy');
    return CommonApiResponse.fromJson(response);
  }

  /// Take action on membership request (approve/reject)
  Future<CommonApiResponse> takeActionOnMembership(TakeActionRequestModel request) async {
    final response = await _apiService.post('membership/takeActionOnMembership', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  /// Get plan history (pending/approved/rejected requests)
  Future<CommonApiResponse> getPlanHistory(String filterBy) async {
    final response = await _apiService.get('membership/planHistory?filterBy=$filterBy');
    return CommonApiResponse.fromJson(response);
  }

  /// Cancel membership request
  Future<CommonApiResponse> cancelMembershipRequest(CancelMembershipRequestModel request) async {
    final response = await _apiService.post('membership/cancelMembershipRequest', request.toJson());
    return CommonApiResponse.fromJson(response);
  }

  /// Get all plans for management (owners/managers) - includes inactive plans
  /// Uses JWT to get gym ID automatically
  Future<CommonApiResponse> getAllPlansForManagement() async {
    final response = await _apiService.get('membership/getAllPlansForManagement');
    return CommonApiResponse.fromJson(response);
  }

  /// Deactivate a plan (owners/managers only)
  Future<CommonApiResponse> deactivatePlan(int planId) async {
    final response = await _apiService.post('membership/deactivatePlan', {
      'planId': planId,
    });
    return CommonApiResponse.fromJson(response);
  }

  /// Activate a plan (owners/managers only)
  Future<CommonApiResponse> activatePlan(int planId) async {
    final response = await _apiService.post('membership/activatePlan', {
      'planId': planId,
    });
    return CommonApiResponse.fromJson(response);
  }

  /// Get members with pending fees (expired or expiring within 10 days)
  /// For owners/managers only
  Future<CommonApiResponse> getMembersWithPendingFees() async {
    final response = await _apiService.get('membership/getMembersWithPendingFees');
    return CommonApiResponse.fromJson(response);
  }

  /// Send fee reminder notifications to specified users
  /// For owners/managers only
  Future<CommonApiResponse> sendFeeReminders(List<int> userIds) async {
    final response = await _apiService.post('membership/sendFeeReminders', {
      'userIds': userIds,
    });
    return CommonApiResponse.fromJson(response);
  }
}

