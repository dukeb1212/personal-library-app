import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_test/UIs/login_page.dart';
import 'package:login_test/backend/auth_backend.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  bool _isPasswordVisible = false;
  bool _passwordsMatch = true;
  bool _isValidEmail = true;

  bool _isTextValid() {
    bool isUsernameValid = _usernameController.text.isNotEmpty;
    bool isNameValid = _nameController.text.isNotEmpty;
    bool isAgeValid = _ageController.text.isNotEmpty;
    return isUsernameValid && _isValidEmail && isNameValid && isAgeValid && _passwordsMatch;
  }

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
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 5),
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
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _retypePasswordController,
                      decoration: const InputDecoration(labelText: 'Password Confirmation'),
                      obscureText: !_isPasswordVisible,
                      onChanged: (_) => _checkPasswordMatch(),
                    ),
                  ),
                ],
              ),
              if (!_passwordsMatch)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Passwords do not match each other!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _isValidEmail ? null : 'Invalid email format',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  if(value.isEmpty) {
                    print('yes');
                    setState(() {
                      _isValidEmail = true;
                    });
                    print(_isValidEmail);
                  } else {
                    setState(() {
                      _isValidEmail = _emailRegex.hasMatch(value);
                    });
                  }
                },
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isTextValid() ? _submit : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter information in all the field above!')),
                  );
                },
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
                  text: const TextSpan(
                    style: TextStyle (
                      fontSize: 14,
                      color: Color(0xff8e8e93),
                    ),
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                      ),
                      TextSpan(
                        text: 'Log in here',
                        style: TextStyle(
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
