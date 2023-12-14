import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_test/UIs/login_page.dart';
import 'package:login_test/backend/login_backend.dart';

import '../utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _passwordsMatch = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final retypePassword = _retypePasswordController.text;
    setState(() {
      _passwordsMatch = password == retypePassword;
    });
  }

  void _submit() async {
    final age = int.tryParse(_ageController.text);
    final result = await AuthBackend().registerUser(
      _usernameController.text,
      _passwordController.text,
      _emailController.text,
      _nameController.text,
      age,
    );

    bool success = result['success'];
    String message = result['message'];
    if (mounted) {
      if (success) {
        // Navigate back to the login page or show a success message
        Navigator.pop(
            context); // This will navigate back to the previous screen (i.e., LoginPage)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
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
              const SizedBox(height: 120),
              SizedBox(
                width: 125,
                height: 120,
                child: Image.asset(
                  'assets/page-1/images/alpha-bookstorelogodark-ver-uUy.png',
                  fit: BoxFit.cover,
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tài khoản'),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                      ),
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
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _retypePasswordController,
                      decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
                      obscureText: true,
                      onChanged: (_) => _checkPasswordMatch(),
                    ),
                  ),
                ],
              ),
              if (!_passwordsMatch)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Mật khẩu xác thực không khớp!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction(
                          (TextEditingValue oldValue, TextEditingValue newValue) {
                        try {
                          final intValue = int.parse(newValue.text);
                          if (intValue > 0) {
                            return newValue;
                          }
                        } catch (e) {
                          print("Error");
                        }
                        return oldValue;
                      }),
                ],
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _passwordsMatch ? _submit : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xffffffff),
                  backgroundColor: const Color(0xff404040),
                ),
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  // Chuyển đến trang đăng nhập
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: safeGoogleFont (
                      'Inter',
                      fontSize: 14,
                      color: const Color(0xff8e8e93),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Already have an account? ',
                      ),
                      TextSpan(
                        text: 'Log in here',
                        style: safeGoogleFont(
                          'Inter',
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff8e8e93),
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
