import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiService {
  final Dio _dio;
  String? _authToken;

  // Singleton setup
  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }

  static const String liveUrl = 'http://194.164.148.69:5000';
  static const String testUrl = 'http://localhost:5000';

  static const String envUrl = liveUrl;

  // Corrected base URL
  static const String _baseUrl = '$envUrl/zymm/v1/';

  // Method to set the token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  ApiService._internal() : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Request was -> ${options.data.toString()}');
          // Add auth token to header if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response != null) {
            debugPrint('error was -> ${error.response.toString()}');
          } else {
            debugPrint('error was -> ${error.message}');
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          debugPrint('Response was -> ${response.data.toString()}');
          return handler.next(response);
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        logPrint: (o) {
          debugPrint(o.toString());
        },
      ),
    );
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException {
      rethrow;
    }
  }
}
