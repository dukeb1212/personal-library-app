import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Validate {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? '';

  Future<Map<String, dynamic>> validatePassword(String username, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/validatePassword"),
      body: json.encode({
        'username': username,
        'currentPassword': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': responseBody['success'] == true,
        'message': responseBody['message'] ?? 'Unknown error',
      };
    } else if (response.statusCode == 401 && responseBody['message'] == 'Invalid password') {
      return {'success': false, 'message': 'Invalid password'};
    }
    if (kDebugMode) {
      print(responseBody['message']);
    }
    return {'success': false, 'message': 'Server error'};
  }

  Future<Map<String, dynamic>> changePassword(String username, String newPassword) async {
    if (newPassword.length < 8) {
      return {
        'success': false,
        'message': 'Password should be at least 8 characters long.',
      };
    }
    final response = await http.post(
      Uri.parse("$_baseUrl/changePassword"),
      body: json.encode({
        'username': username,
        'newPassword': newPassword,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': responseBody['success'] == true,
        'message': responseBody['message'] ?? 'Unknown error',
      };
    } else if (response.statusCode == 501 && responseBody['message'] == 'User not found') {
    return {'success': false, 'message': 'User not found'};
    }
    return {'success': false, 'message': 'Server error'};
  }

  Future<Map<String, dynamic>> updateUserData(String? currentUsername,String newUsername, String email, String name, int age) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/updateUser"),
      body: json.encode({
        'currentUsername': currentUsername,
        'newUsername': newUsername,
        'email': email,
        'name': name,
        'age': age,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': responseBody['success'] == true,
        'message': responseBody['message'] ?? 'Unknown error',
      };
    } else if (response.statusCode == 400 && responseBody['message'] == 'Username already exists') {
      return {'success': false, 'message': 'Username already exists'};
    }
    return {'success': false, 'message': 'Server error'};
  }
}