import 'package:flutter/material.dart';
import 'package:login_test/UIs/main_page.dart';
import '../user_data.dart';
import 'change_password_form.dart';
import 'package:login_test/backend/password_backend.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final userInfo = provider.user;
    final curUsername = userInfo?.username.toString();

    if (userInfo == null) {
      return const CircularProgressIndicator(); // Loading indicator or error handling
    }

    final nameController = TextEditingController(text: userInfo.name);
    final emailController = TextEditingController(text: userInfo.email);
    final ageController = TextEditingController(text: userInfo.age.toString());
    final usernameController = TextEditingController(text: userInfo.username);

    final validate = Validate();

    void submit() async {
      final result = await validate.updateUserData(
          curUsername,
          usernameController.text,
          emailController.text,
          nameController.text,
          int.tryParse(ageController.text) ?? 0,
      );
      if(result['success']){
        final editedUserInfo = UserData(
          name: nameController.text,
          email: emailController.text,
          age: int.tryParse(ageController.text) ?? 0,
          username: usernameController.text,
          userId: userInfo.userId,
        );
        provider.setUser(editedUserInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),

            ElevatedButton(
              onPressed: () {
                submit();
              },
              child: const Text('Save Changes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
