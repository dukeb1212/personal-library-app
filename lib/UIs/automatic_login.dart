import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/login_backend.dart';
import '../database/book_database.dart';
import 'book.dart';
import 'main_page.dart';
import 'package:login_test/user_data.dart';

class AutomaticLogin extends StatefulWidget {
  final String? payload;
  const AutomaticLogin({super.key, required this.payload});

  @override
  AutomaticLoginState createState() => AutomaticLoginState();
}

class AutomaticLoginState extends State<AutomaticLogin> {

  @override
  void initState() {
    super.initState();
    _checkAndPerformAutomaticLogin();
  }

  Future<void> _checkAndPerformAutomaticLogin() async {
    // Check if a token exists in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final authBackend = AuthBackend();
    if (mounted) {
      if (storedToken != null) {
        // Use the stored token to attempt automatic login
        final loginSuccess = await authBackend.attemptAutomaticLogin(storedToken);
        if (mounted) {
          if (loginSuccess) {
            final provider = container.read(userProvider);
            final userData = await retrieveUserData();
            provider.setUser(userData);

            final databaseHelper = DatabaseHelper();
            await databaseHelper.syncBooksFromServer(userData.userId, userData.username);
            await databaseHelper.syncNotificationsFromServer(userData.userId);

            String? token = await FirebaseMessaging.instance.getToken();
            authBackend.sendTokenToServer(token!, userData.userId);

            // Navigate to the authenticated part of your app
            if(mounted) {
              if(widget.payload!.isNotEmpty) {
                final result = await databaseHelper.doesBookExist(widget.payload!);
                if(mounted) {
                  if (result['existed']) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BookScreen(book: result['book'], bookState: result['bookState'])),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyMainPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book does not existed!')),
                    );
                  }
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyMainPage()),
                );
              }
            }
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // You can display a loading indicator or any other UI element here
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Replace with your UI
      ),
    );
  }
}
