import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/book_database.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'package:login_test/user_data.dart';

class AutomaticLogin extends StatefulWidget {
  const AutomaticLogin({super.key});

  @override
  AutomaticLoginState createState() => AutomaticLoginState();
}

class AutomaticLoginState extends State<AutomaticLogin> {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _checkAndPerformAutomaticLogin();
  }

  Future<void> _checkAndPerformAutomaticLogin() async {
    // Check if a token exists in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (mounted) {
      if (storedToken != null) {
        // Use the stored token to attempt automatic login
        final loginSuccess = await _attemptAutomaticLogin(storedToken);
        if (mounted) {
          if (loginSuccess) {
            final provider = container.read(userProvider);
            final userData = await retrieveUserData();
            provider.setUser(userData);

            final databaseHelper = DatabaseHelper();
            await databaseHelper.syncBooksFromServer(userData.userId, userData.username);

            // Navigate to the authenticated part of your app
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyMainPage()),
              );
            }
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<bool> _attemptAutomaticLogin(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse('$_baseUrl/validateToken'), headers: headers);

      if (response.statusCode == 200) {
        return true; // Token is valid
      } else {
        return false; // Token validation failed
      }
    } catch (e) {
      return false; // Request or network error
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can display a loading indicator or any other UI element here
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Replace with your UI
      ),
    );
  }
}
