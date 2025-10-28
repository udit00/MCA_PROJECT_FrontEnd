import 'package:flutter/material.dart';
import 'package:zymm/core/location/geocoding_service.dart';
import 'package:zymm/core/location/location_service.dart';
import 'package:zymm/features/attendance/data/models/attendance_model.dart';
import 'package:zymm/features/attendance/data/models/punch_request_model.dart';
import 'package:zymm/features/attendance/data/repositories/attendance_repository.dart';

enum ViewState { idle, loading, success, error, deleting, punchingIn, punchingOut }

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AttendanceModel> _attendanceList = [];
  List<AttendanceModel> get attendanceList => _attendanceList;

  bool get canPunchIn {
    if (_attendanceList.isEmpty) return true;
    return _attendanceList.first.isPunchedOut;
  }

  bool get canPunchOut {
    if (_attendanceList.isEmpty) return false;
    return !_attendanceList.first.isPunchedOut;
  }

  Future<void> fetchAllAttendance() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllAttendance();

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'Failed to fetch attendance records';
      } else {
        final List<dynamic> data = response.data as List<dynamic>;
        _attendanceList = data.map((json) => AttendanceModel.fromJson(json)).toList();
        _state = ViewState.success;
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> punchIn(BuildContext context) async {
    _state = ViewState.punchingIn;
    notifyListeners();

    try {
      // Get location
      final location = await LocationService.instance.getLocationWithErrorHandling(context);
      
      if (location == null) {
        _state = ViewState.error;
        _errorMessage = 'Location is required for punch in';
        notifyListeners();
        return;
      }

      // Get address from location
      final address = await GeocodingService.instance.getAddressFromLatLng(
        location.latitude,
        location.longitude,
      );

      final request = PunchInRequestModel(
        address: address,
        locationLat: location.latitude,
        locationLong: location.longitude,
      );

      final response = await _repository.punchIn(request);

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'Failed to punch in';
      } else {
        // Refresh attendance list
        await fetchAllAttendance();
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> punchOut(BuildContext context) async {
    _state = ViewState.punchingOut;
    notifyListeners();

    try {
      // Get location
      final location = await LocationService.instance.getLocationWithErrorHandling(context);
      
      if (location == null) {
        _state = ViewState.error;
        _errorMessage = 'Location is required for punch out';
        notifyListeners();
        return;
      }

      // Get address from location
      final address = await GeocodingService.instance.getAddressFromLatLng(
        location.latitude,
        location.longitude,
      );

      final request = PunchOutRequestModel(
        address: address,
        locationLat: location.latitude,
        locationLong: location.longitude,
      );

      final response = await _repository.punchOut(request);

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'Failed to punch out';
      } else {
        // Refresh attendance list
        await fetchAllAttendance();
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteAttendance(int attendanceId) async {
    _state = ViewState.deleting;
    notifyListeners();

    try {
      final request = DeleteAttendanceRequestModel(attendanceId: attendanceId);
      final response = await _repository.deleteAttendance(request);

      if (response.hasError) {
        _state = ViewState.error;
        _errorMessage = response.error ?? 'Failed to delete attendance';
        notifyListeners();
      } else {
        // Refresh attendance list
        await fetchAllAttendance();
      }
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }
}

