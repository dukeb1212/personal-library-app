import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../notification_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationBackend {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? '';

  Future<void> sendTokenToServer(String fcmToken, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/updateFcmToken'), // Replace with your server endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': fcmToken, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('FCM token sent to server successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send FCM token to server. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error sending FCM token to server: $error');
      }
    }
  }

  Future<Map<String, dynamic>> addScheduleNotification(Notification notification, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scheduleNotification'), // Replace with your server endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': notification.id,
          'userId': userId,
          'bookId': notification.bookId,
          'notificationDateTime': notification.dateTime.toIso8601String(),
          'repeatType': notification.repeatType,
          'active': notification.active,
        }),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message']
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to schedule notification. ${responseBody['message']} (Status code: ${response.statusCode})'
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding schedule: $error');
      }
    }
    return {
      'success': false,
      'message': 'Failed to schedule notification'
    };
  }

  Future<Map<String, dynamic>> activateNotification(bool active, int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/activateNotification'), // Replace with your server endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'active': active,
          'id': id
        }),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message']
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to activate notification. ${responseBody['message']} (Status code: ${response.statusCode})'
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding notification: $error');
      }
    }
    return {
      'success': false,
      'message': 'Failed to activate notification'
    };
  }

  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/deleteNotification'), // Replace with your server endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id
        }),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message']
        };
      } else {
        return {
          'success': false,
          'message': '${responseBody['message']} (Status code: ${response.statusCode})'
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting notification: $error');
      }
    }
    return {
      'success': false,
      'message': 'Failed to delete notification'
    };
  }

  Future<Map<String, dynamic>> fetchNotification(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/notification/$userId"), // Replace with your server URL
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'],
          'notifications': responseBody['notifications']
        };
      } else {
        return {
          'success': false,
          'message': '${responseBody['message']} (Status code: ${response.statusCode})'
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching notification: $error');
      }
    }
    return {
      'success': false,
      'message': 'Failed to fetch notification'
    };
  }

  Future<Map<String, dynamic>> deleteAllNotifications(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/deleteAllNotifications'), // Replace with your server endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId
        }),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message']
        };
      } else {
        return {
          'success': false,
          'message': '${responseBody['message']} (Status code: ${response.statusCode})'
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting all notifications: $error');
      }
    }
    return {
      'success': false,
      'message': 'Failed to delete all notifications'
    };
  }

}


