import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_test/backend/login_backend.dart';

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
    if (mounted && success) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _retypePasswordController,
                    decoration: const InputDecoration(labelText: 'Retype Password'),
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
                  'Passwords do not match',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
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
                  } catch (e) {}
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
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
