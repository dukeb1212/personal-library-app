import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/token_backend.dart';
import '../user_data.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'package:login_test/backend/auth_backend.dart';
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
  bool _isLoggingIn = false;

  Future<void> _submit() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final result = await _authBackend.loginUser(username, password);

    // if (token != null && _rememberMe) {
    //   // Store the token in shared preferences
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setString('token', token);
    // }

    // Navigate to the next page (or perform other actions based on login success)
    if (mounted) {
      if (_isLoggingIn) {
        setState(() {
          _isLoggingIn = false;
        });
      }
      if (result['success']) {
        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];

        // Store the tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        print(accessToken);

        // Get user data and store the data
        final userData = await _authBackend.fetchUserData(accessToken);
        setSharedPrefs(userData);
        final provider = container.read(userProvider);
        provider.setUser(userData);

        // Sync data from server to local
        final databaseHelper = DatabaseHelper();
        await databaseHelper.syncBooksFromServer(accessToken);

        final tokenManager = TokenManager();
        await tokenManager.init();

        // Navigate to Home page
        if(mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyMainPage()),
          );
        }
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
    if (!_isLoggingIn) {
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
                  onPressed: () async {
                    if (!_isLoggingIn) {
                      setState(() {
                        _isLoggingIn = true;
                      });
                    }
                    await _submit();
                  },
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
    } else {
      return const Scaffold(
        body: SizedBox(
            child: Center(
                child: CircularProgressIndicator()
            )
        ),
      );
    }
  }
}
