import 'package:flutter/material.dart';
import 'package:login_test/database/book_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_data.dart';

import 'package:login_test/backend/profile_backend.dart';
import 'package:google_fonts/google_fonts.dart';

final provider = container.read(userProvider);

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  double baseWidth = 360;
  double fem = 0;

  String curUsername = '';
  int userId = 0;

  int totalBooks = 0;
  String totalReadHours = '';
  int totalCompletedBooks = 0;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final usernameController = TextEditingController();

  final validate = Validate();

  @override
  void initState() {
    super.initState();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
    prefs.remove('username');
    prefs.remove('email');
    prefs.remove('name');
    prefs.remove('age');
    if (mounted)
    {
      Navigator.pushReplacementNamed(context, '/login');
    } // This will navigate back to the previous screen, which is the login page
  }

  Future<void> submitInfo() async {
    final result = await validate.updateUserData(
      curUsername,
      usernameController.text,
      emailController.text,
      nameController.text,
      int.tryParse(ageController.text) ?? 0,
    );
    if(result['success'] && mounted){
      final editedUserInfo = UserData(
        name: nameController.text,
        email: emailController.text,
        age: int.tryParse(ageController.text) ?? 0,
        username: usernameController.text,
        userId: userId,
      );
      provider.setUser(editedUserInfo);
      setSharedPrefs(editedUserInfo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> updateAchievement(int userId) async {
    final databaseHelper = DatabaseHelper();
    final allBookStates = await databaseHelper.getAllBookStates(userId);
    setState(() {
      totalBooks = allBookStates.length;
      totalReadHours = allBookStates.fold(0.0, (sum, bookState) => sum + bookState.totalReadHours).toStringAsFixed(3);
      totalCompletedBooks = allBookStates.where(
              (bookState) => bookState.percentRead == 100.0).toList().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    fem = MediaQuery.of(context).size.width / baseWidth;
    final provider = container.read(userProvider);
    final userInfo = provider.user;

    if (userInfo == null) {
      return const CircularProgressIndicator(); // Loading indicator or error handling
    }

    WidgetsBinding.instance.addPostFrameCallback((_){
      curUsername = userInfo.username.toString();
      nameController.text = userInfo.name;
      emailController.text = userInfo.email;
      ageController.text = userInfo.age.toString();
      usernameController.text = userInfo.username;
      userId = userInfo.userId;
    });

    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height-40*fem),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userInfo.name,
                style: GoogleFonts.waterfall(
                  fontSize: 50*fem,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20 * fem),
              ProfileButton(
                label: 'Account',
                icon: Icons.manage_accounts,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Edit account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: 'Full name'),
                              ),
                              TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(labelText: 'Username'),
                              ),
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                controller: ageController,
                                decoration: const InputDecoration(labelText: 'Age'),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await submitInfo();
                              setState(() {});
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ProfileButton(
                label: 'Change Password',
                icon: Icons.lock,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordForm(); // Use your ChangePasswordForm here
                    },
                  );
                },
              ),
              ProfileButton(
                label: 'Achievement',
                icon: Icons.leaderboard_rounded,
                onPressed: () async {
                  await updateAchievement(userId);
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Achievement',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Total number of your book: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14 * fem,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: totalBooks.toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5*fem,),
                              RichText(
                                text: TextSpan(
                                  text: 'Total hours you have read: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14 * fem,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: totalReadHours.toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5*fem,),
                              RichText(
                                text: TextSpan(
                                  text: 'Total number of books you have completed: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14 * fem,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children:  <TextSpan>[
                                    TextSpan(
                                      text: totalCompletedBooks.toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              ProfileButton(
                label: 'About',
                icon: Icons.info_rounded,
                onPressed: () {
                  // Xử lý khi nhấn nút About
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: const Text(
                          'Developed by students of Hanoi University of Science and Technology.\nContact: github.com/dukeb1212 for more details.',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ProfileButton(
                label: 'Log Out',
                icon: Icons.logout_rounded,
                onPressed: () {
                  logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ChangePasswordFormState createState() => ChangePasswordFormState();
}

class ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final validate = Validate();
  final username = provider.user?.username.toString();

  bool isCurrentPasswordValid = false;
  bool checkCurrentPassword = true;

  bool isPasswordVisible = false;
  bool passwordsMatch = true;

  bool isChangePasswordSuccessful = true;
  String errorMessage = '';

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void checkPasswordMatch() {
    final password = _newPasswordController.text;
    final retypePassword = _confirmPasswordController.text;
    setState(() {
      passwordsMatch = password == retypePassword;
    });
  }

  Future<void> checkPassword(String password) async {
    final result = await validate.validatePassword(username!, password);
    isCurrentPasswordValid = result['success'];
  }

  Future<void> submit(String newPassword) async {
    final result = await validate.changePassword(username!, newPassword);
    if (result['success'] && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      setState(() {
        isChangePasswordSuccessful = false;
        errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    return Dialog(
      insetPadding: EdgeInsets.all(35*fem),
      child: Padding(
        padding: EdgeInsets.all(20.0*fem),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Text(
                      'Change password',
                      style: TextStyle(
                        fontSize: 22*fem,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      iconSize: 20*fem,
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ],
                ),
                TextField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                  obscureText: !isPasswordVisible,
                  onChanged: (_) {
                    if (!checkCurrentPassword) {
                      setState(() {
                        checkCurrentPassword = true;
                      });
                    }
                  },
                ),
                SizedBox(height: 5*fem),
                if (!checkCurrentPassword)
                  Padding(
                    padding: EdgeInsets.all(8.0*fem),
                    child: Text(
                      'Wrong current password!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0*fem,
                      ),
                    ),
                  ),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                  ),
                  obscureText: !isPasswordVisible,
                  onChanged: (_) {
                    if (!isChangePasswordSuccessful) {
                      setState(() {
                        isChangePasswordSuccessful = true;
                      });
                    }
                    checkPasswordMatch();
                  },
                ),
                SizedBox(height: 5*fem),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Reconfirm new password'),
                  obscureText: !isPasswordVisible,
                  onChanged: (_) => checkPasswordMatch(),
                ),
                if (!passwordsMatch)
                  Padding(
                    padding: EdgeInsets.all(8.0*fem),
                    child: Text(
                      'Password confirmation unmatched!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0*fem,
                      ),
                    ),
                  ),
                if (!isChangePasswordSuccessful)
                  Padding(
                    padding: EdgeInsets.all(8.0*fem),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0*fem,
                      ),
                    ),
                  ),
                SizedBox(height: 50*fem,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await checkPassword(_currentPasswordController.text);
                        // Proceed with password change logic
                        if (isCurrentPasswordValid) {
                          // Call a function to handle the password change process
                          submit(_newPasswordController.text);
                        } else {
                          setState(() {
                            checkCurrentPassword = false;
                          });
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                )
              ],
            ),
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ProfileButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;

    return Container(
      height: 50*fem,
      width: MediaQuery.of(context).size.width - 50 * fem,
      margin: EdgeInsets.fromLTRB(25 * fem, 0, 10 * fem, 25 * fem),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9 * fem),
          ),
          foregroundColor: Colors.black,
          backgroundColor: const Color(0xffeeeeee),
          padding: EdgeInsets.fromLTRB(25*fem, 10*fem, 25*fem, 10*fem),
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 16 * fem * 0.97,
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 10 * fem),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16*fem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
