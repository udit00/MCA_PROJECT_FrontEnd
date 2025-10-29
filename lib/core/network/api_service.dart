import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:zymm/core/storage/storage_service.dart';

class ApiService {
  final Dio _dio;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }

  static const String liveUrl = 'http://194.164.148.69:5000';
  static const String testUrl = 'http://10.0.2.2:5000';  // Use 10.0.3.2 for Genymotion Emulator (or use 192.168.0.100 if this doesn't work)

  static const String envUrl = testUrl;

  static const String _baseUrl = '$envUrl/zymm/v1/';

  ApiService._internal() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.getAuthToken();
          if (token?.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('➡️ Request: ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          if(options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          handler.next(options);
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
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      } else {
        rethrow;
      }
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      } else {
        rethrow;
      }
    }
  }
}
