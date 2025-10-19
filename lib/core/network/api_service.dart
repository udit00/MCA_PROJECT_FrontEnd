import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiService {
  final Dio _dio;

  static const String liveUrl = 'http://194.164.148.69:5000';
  static const String testUrl = 'http://localhost:5000';

  static const String envUrl = liveUrl;

  static const String _baseUrl = '$envUrl/zymm/';

  ApiService() : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Request was -> ${options.data.toString()}');
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
