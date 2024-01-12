import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_test/backend/notification_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_data.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'package:login_test/backend/login_backend.dart';
import 'package:login_test/database/book_database.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _authBackend = AuthBackend();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  void _submit() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final token = await _authBackend.loginUser(username, password);

    if (token != null && _rememberMe) {
      // Store the token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    }

    // Navigate to the next page (or perform other actions based on login success)
    if (mounted) {
      if (token != null) {
        final userData = await _authBackend.fetchUserData(username);
        setSharedPrefs(userData);
        final provider = container.read(userProvider);
        provider.setUser(userData);

        final databaseHelper = DatabaseHelper();
        await databaseHelper.syncBooksFromServer(userData.userId, username);

        if(mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyMainPage()),
          );
        }
        // Navigate to the desired page after successful login
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Try again.')),
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              Container(
                margin: const EdgeInsets.all(25.0),
                width: 157,
                height: 145,
                child: Image.asset(
                  'assets/page-1/images/alpha-bookstorelogodark-ver-uUy.png',
                  fit: BoxFit.cover,
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: !_isPasswordVisible,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xffffffff),
                  backgroundColor: const Color(0xff404040),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Chuyển đến trang đăng ký
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle (
                      fontSize: 14,
                      color: Color(0xff8e8e93),
                    ),
                    children: [
                      TextSpan(
                        text: 'Don’t have an account yet? ',
                      ),
                      TextSpan(
                        text: 'Sign up here',
                        style: TextStyle (
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff8e8e93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
