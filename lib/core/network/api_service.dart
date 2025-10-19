
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://194.164.148.69:5000/zymm/v1/';

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      // Handle exceptions
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
      return _processResponse(response);
    } catch (e) {
      // Handle exceptions
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    print("response ${response.body}");
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      // Add other status code handling as needed
      default:
        throw Exception('Error occurred with status code: ${response.statusCode}');
    }
  }
}
