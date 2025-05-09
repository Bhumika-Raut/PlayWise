import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class ApiService {
  static const String _baseUrl =
      'https://sheshya-backend-f4gndddgadfhc3fy.eastus-01.azurewebsites.net';
  static const String _contentUrl =
      'https://ai-qna-gvhkarb0faf3fvhs.eastus-01.azurewebsites.net';

  String? _authToken;

  Future<bool> login() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loginByEmailOrPhone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": "testStudent@sheshya.in",
          "phone": "",
          "otp": "123456"
        }),
      );

      if (response.statusCode == 200) {
        _authToken = jsonDecode(response.body)['token'];
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<ApiResponse> getQuestions() async {
    try {
      final response = await http.post(
        Uri.parse('$_contentUrl/createCourseContent'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken'
        },
        body: jsonEncode({"className": "KG1"}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        return ApiResponse.withError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Questions error: $e');
      return ApiResponse.withError('Network error: ${e.toString()}');
    }
  }
}
