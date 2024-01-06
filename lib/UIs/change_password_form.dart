import 'package:flutter/material.dart';
import 'package:login_test/backend/password_backend.dart';
import '../user_data.dart';
import 'main_page.dart';

final provider = container.read(userProvider);
final username = provider.user?.username.toString();

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 4)));
            },
            tooltip: "Logout",
          )
        ],
      ),
      body: const ChangePasswordForm(),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ChangePasswordFormState createState() => ChangePasswordFormState();
}

class ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _validate = Validate();
  List<Widget> errorMessages = [];

  bool _isCurrentPasswordValid = false;

  void _checkPassword(String password) async {
    final result = await _validate.validatePassword(username!, password);
    _isCurrentPasswordValid = result['success'];
  }

  void _submit(String newPassword) async {
    final result = await _validate.changePassword(username!, newPassword);
    if (result['success'] && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 4,)),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (value) {
                errorMessages.clear(); // Clear previous error messages
                if (value!.isEmpty) {
                  errorMessages
                      .add(const Text('Please enter your current password'));
                }
                // Add the logic to validate the current password
                _checkPassword(_currentPasswordController.text);
                if (!_isCurrentPasswordValid) {
                  errorMessages.add(const Text('Incorrect current password'));
                }
                setState(() {});
                if (errorMessages.isEmpty) {
                  return null; // No errors
                }
                return ''; // Validation failed
              },
            ),
            Column(
              children: errorMessages,
            ),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a new password';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm New Password'),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match each other!';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Proceed with password change logic
                  final newPassword = _newPasswordController.text;
                  // Call a function to handle the password change process
                  _submit(newPassword);
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
