import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/api_response.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('HEADERS: $headers');
    return headers;
  }

  Future<ApiResponse<dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();

      // COMPREHENSIVE DEBUG LOGGING
      print(' ========== API CALL START ==========');
      print('ENDPOINT: $baseUrl$endpoint');
      print('REQUEST DATA: ${json.encode(data)}');
      print('HEADERS: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      // LOG RESPONSE DETAILS
      print('========== API RESPONSE ==========');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('========== API CALL END ==========');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check for success indicators in response body
        final bool success = responseBody['success'] == true ||
            responseBody['status'] == 'success' ||
            (responseBody['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('success') ??
                false);

        if (success) {
          return ApiResponse.success(
            responseBody,
            message: responseBody['message'] ?? 'Request successful',
          );
        } else {
          return ApiResponse.error(
            responseBody['message'] ?? 'API returned error',
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          responseBody['message'] ??
              'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' ========== API ERROR ==========');
      print(' ERROR: $e');
      print(' ========== API CALL END ==========');
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();

      print('========== API CALL START ==========');
      print('ENDPOINT: $baseUrl$endpoint');
      print('HEADERS: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      print(' ========== API RESPONSE ==========');
      print(' STATUS CODE: ${response.statusCode}');
      print(' RESPONSE BODY: ${response.body}');
      print(' ========== API CALL END ==========');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          responseBody,
          message: 'Request successful',
        );
      } else {
        return ApiResponse.error(
          responseBody['message'] ??
              'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' ========== API ERROR ==========');
      print(' ERROR: $e');
      print(' ========== API CALL END ==========');
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse<dynamic>> login(String email, String password) async {
    // ADD THESE DEBUG LINES
    final fullUrl = '$baseUrl${ApiConstants.login}';
    print('LOGIN DEBUG:');
    print('Full URL: $fullUrl');
    print('Endpoint: ${ApiConstants.login}');
    print('Base URL: $baseUrl');

    final response = await post(ApiConstants.login, {
      'email': email,
      'password': password,
    });

    // Save token if login successful
    if (response.success) {
      final token = response.data['token'] ?? response.data['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.toString());
        print('AUTH TOKEN SAVED: $token');
      }
    }

    return response;
  }

  // FIXED: Signup method with 5 parameters
  Future<ApiResponse<dynamic>> signup(String firstName, String lastName,
      String email, String password, String confirmPassword) async {
    return post(ApiConstants.signup, {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });
  }

  // Patient methods
  Future<ApiResponse<dynamic>> registerPatient(
      Map<String, dynamic> patientData) async {
    return post(ApiConstants.registerPatient, patientData);
  }

  Future<ApiResponse<dynamic>> getPatients() async {
    return get(ApiConstants.listPatients);
  }

  // Vitals methods
  Future<ApiResponse<dynamic>> addVitals(
      Map<String, dynamic> vitalsData) async {
    return post(ApiConstants.addVitals, vitalsData);
  }

  // Visit methods
  Future<ApiResponse<dynamic>> addVisit(Map<String, dynamic> visitData) async {
    return post(ApiConstants.addVisit, visitData);
  }

  Future<ApiResponse<dynamic>> viewVisits(String visitDate) async {
    return post(ApiConstants.viewVisits, {'visit_date': visitDate});
  }

  // Test method to verify API connectivity
  Future<ApiResponse<dynamic>> testConnection() async {
    print('🧪 Testing API connection...');
    return get('patients/list'); // Simple endpoint to test
  }
}
