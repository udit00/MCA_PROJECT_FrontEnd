import 'package:zymm/common/models/common_api_response_model.dart';
import 'package:zymm/core/network/api_service.dart';
import 'package:zymm/features/employee/data/models/employee_model.dart';
import 'package:zymm/features/employee/data/models/employee_registration_request_model.dart';
import 'package:zymm/features/employee/data/models/employee_registration_response_model.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<EmployeeRegistrationResponseModel> createEmployee(
    EmployeeRegistrationRequestModel request,
  ) async {
    final response = await _apiService.post('employee/create', request.toJson());
    final apiResponse = CommonApiResponse.fromJson(response);
    return EmployeeRegistrationResponseModel.fromJson(apiResponse.data);
  }

  Future<List<EmployeeModel>> getAllEmployeesByGymId(int gymId) async {
    final response = await _apiService.get('employee/getAllEmployeeByGymId?gymId=$gymId');
    final apiResponse = CommonApiResponse.fromJson(response);
    
    if (apiResponse.data is List) {
      return (apiResponse.data as List)
          .map((json) => EmployeeModel.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<EmployeeModel> getEmployeeById(int employeeId) async {
    final response = await _apiService.get('employee/getEmployeeById?employeeId=$employeeId');
    final apiResponse = CommonApiResponse.fromJson(response);
    return EmployeeModel.fromJson(apiResponse.data);
  }
}

