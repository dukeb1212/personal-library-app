import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  final String username;
  final String email;
  final String name;
  final int age;
  final int userId;

  UserData({
    required this.username,
    required this.email,
    required this.name,
    required this.age,
    required this.userId,
  });

  UserData copyWith(UserData newData) {
    return UserData(
      username: newData.username,
      email: newData.email,
      name: newData.name,
      age: newData.age,
      userId: newData.userId,
    );
  }
}

final container = ProviderContainer();
final userProvider = ChangeNotifierProvider<UserProvider>((ref) {
  return UserProvider();
});

class UserProvider extends ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  void setUser(UserData userData) {
    _user = userData;
    notifyListeners();
  }
}

Future<void> setSharedPrefs(UserData userData) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', userData.username);
  await prefs.setString('email', userData.email);
  await prefs.setString('name', userData.name);
  await prefs.setInt('age', userData.age);
  await prefs.setInt('userId', userData.userId);
}

Future<UserData> retrieveUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final storedUsername = prefs.getString('username') as String;
  final storedEmail = prefs.getString('email') as String;
  final storedName = prefs.getString('name') as String;
  final storedAge = prefs.getInt('age') as int;
  final storedId = prefs.getInt('userId') as int;
  final userData = UserData(username: storedUsername, email: storedEmail, name: storedName, age: storedAge, userId: storedId);
  return userData;
}
