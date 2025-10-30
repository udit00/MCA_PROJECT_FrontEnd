import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:zymm/features/member/data/models/gym_member_model.dart';
import 'package:zymm/features/member/data/repositories/member_repository.dart';

enum MemberViewState { initial, loading, loaded, error }

class MemberViewModel extends ChangeNotifier {
  final MemberRepository _repository;

  MemberViewState _state = MemberViewState.initial;
  List<GymMemberModel> _members = [];
  String? _errorMessage;

  MemberViewModel({MemberRepository? repository})
      : _repository = repository ?? MemberRepository();

  // Getters
  MemberViewState get state => _state;
  List<GymMemberModel> get members => _members;
  String? get errorMessage => _errorMessage;

  /// Fetch all gym members with their active plans and ratings
  Future<void> getGymMembers() async {
    _state = MemberViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      developer.log('🔄 Fetching gym members...');
      final response = await _repository.getGymMembers();

      if (response.hasError) {
        developer.log('❌ Error fetching members: ${response.error}');
        _state = MemberViewState.error;
        _errorMessage = response.error ?? 'Failed to load members';
      } else {
        developer.log('✅ Successfully fetched members');
        final data = response.data;

        if (data is List) {
          _members = data
              .map((json) => GymMemberModel.fromJson(json as Map<String, dynamic>))
              .toList();
          developer.log('📋 Total members: ${_members.length}');
        } else {
          _members = [];
        }

        _state = MemberViewState.loaded;
      }
    } catch (e) {
      developer.log('❌ Exception fetching members: $e');
      _state = MemberViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Get members with feedback
  List<GymMemberModel> get membersWithFeedback =>
      _members.where((member) => member.hasFeedback).toList();

  /// Get members without feedback
  List<GymMemberModel> get membersWithoutFeedback =>
      _members.where((member) => !member.hasFeedback).toList();

  /// Get members with expiring memberships (within 10 days)
  List<GymMemberModel> get membersWithExpiringSoon =>
      _members.where((member) => member.isExpiringSoon).toList();

  /// Clear state
  void clear() {
    _state = MemberViewState.initial;
    _members = [];
    _errorMessage = null;
    notifyListeners();
  }
}

