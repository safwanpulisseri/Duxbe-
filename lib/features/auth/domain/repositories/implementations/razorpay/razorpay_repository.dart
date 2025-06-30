// Models
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// API Client
class RazorpayApiClient {
  RazorpayApiClient() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(':'))}',
      'Content-Type': 'application/json',
    };

    // Add logging interceptor for development
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }
  final Dio _dio;
  final String _baseUrl = 'https://api.razorpay.com/v1';

  // Error handling wrapper
  Future<T> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw RazorpayException(
        message: 'An unexpected error occurred',
        code: 'unknown_error',
      );
    }
  }

  RazorpayException _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      return RazorpayException(
        message: data['error']['description']?.toString() ?? 'Unknown error occurred',
        code: data['error']['code']?.toString() ?? 'unknown_error',
      );
    }
    return RazorpayException(
      message: error.message ?? 'Network error occurred',
      code: 'network_error',
    );
  }
}

// Repository
class RazorpayRepository {
  RazorpayRepository({RazorpayApiClient? apiClient}) : _apiClient = apiClient ?? RazorpayApiClient();
  final RazorpayApiClient _apiClient;

  Future<Map<String, dynamic>> getPlan(String planId) async {
    return _apiClient._safeApiCall(() async {
      final response = await _apiClient._dio.get<Map<String, dynamic>>('/plans/$planId');
      return response.data!;
    });
  }

  Future<List<Map<String, dynamic>>> getAllPlans() async {
    return _apiClient._safeApiCall(() async {
      final response = await _apiClient._dio.get<Map<String, dynamic>>('/plans');
      final items = response.data!['items'] as List<Map<String, dynamic>>;
      return items.toList();
    });
  }
}

// Exception handling
class RazorpayException implements Exception {
  RazorpayException({required this.message, required this.code});
  final String message;
  final String code;

  @override
  String toString() => 'RazorpayException: $message (Code: $code)';
}
