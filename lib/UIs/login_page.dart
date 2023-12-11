import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_data.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'package:login_test/backend/login_backend.dart';
import 'package:login_test/database/book_database.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authBackend = AuthBackend();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

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
    if (token != null && mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()));         },
              child: const Text('Register Instead'),
            ),
          ],
        ),
      ),
    );
  }
}
