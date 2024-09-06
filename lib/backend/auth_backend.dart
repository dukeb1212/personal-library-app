import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../user_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthBackend {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? ''; // Adjust this to your server's address

  // Function to handle user login
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/account/login"),
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true) {
        return {
          'success': true,
          'accessToken': responseBody['accessToken'] as String?,
          'refreshToken': responseBody['refreshToken'] as String?
        };
      }
    }
    return {
      'success': false,
      'message': 'Login failed. Please try again later.'
    };
  }

  // Function to handle user registration
  Future<Map<String, dynamic>> registerUser(String username, String password, String email, String name, int? age) async {
    if (password.length < 8) {
      return {
        'success': false,
        'message': 'Password should be at least 8 characters long.',
      };
    }

    final response = await http.post(
      Uri.parse("$_baseUrl/account/register"),
      body: json.encode({
        'username': username,
        'password': password,
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

  Future<UserData> fetchUserData(String accessToken) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/account/profile"), // Replace with your server URL
      headers: {
        'Content-Type': 'application/json',
        'x_authorization': accessToken
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final userJson = responseBody['userData'];
      final userData = UserData(
        username: userJson['username'],
        email: userJson['email'],
        name: userJson['name'],
        age: userJson['age'],
        userId: userJson['id'],
      );
      return userData;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>> refreshAccessToken(String accessToken, String refreshToken) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/account/refresh'),
          body: json.encode({
            'refreshToken': refreshToken
          }),
          headers: {
            'Content-Type': 'application/json',
            'x_authorization': accessToken,
          }
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // Refresh successfully
        return {
          'success': true,
          'accessToken': responseBody['accessToken']
        };
      } else {
        return {
          'success': false,
          'message': 'Token error!'
        }; // Token validation failed
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      }; // Request or network error
    }
  }
}
