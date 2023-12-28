import 'package:flutter/material.dart';
import 'package:login_test/UIs/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/google_books_api.dart';
import '../book_data.dart';
import '../user_data.dart';
import 'change_password_form.dart';
import 'package:login_test/backend/password_backend.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
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

    Future<void> logout() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('username');
      prefs.remove('email');
      prefs.remove('name');
      prefs.remove('age');
      if (mounted)
      {
        Navigator.pushReplacementNamed(context, '/login');
      } // This will navigate back to the previous screen, which is the login page
    }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Thông tin người dùng'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Tuổi'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Tài khoản'),
            ),

            ElevatedButton(
              onPressed: () {
                submit();
              },
              child: const Text('Lưu thay đổi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              },
              child: const Text('Đổi mật khẩu'),
            ),
            ElevatedButton(
              onPressed: () async {
                logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
