import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'info_page.dart';
import 'my_library_page.dart';

class MyMainPage extends StatefulWidget {
  final int initialTabIndex;
  const MyMainPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  late int selectedTabIndex;
  PageController pageController = PageController(
      initialPage: 0); // Initialize PageController

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
    pageController = PageController(initialPage: selectedTabIndex);// Initialize it here
  }
  Future<void> _logout() async {
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

  @override
  void dispose() {
    pageController
        .dispose(); // Dispose of the PageController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading App"),
        backgroundColor: Colors.blueAccent, // Set the app bar background color to black
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        children: [
          HomePage(),
          // const BookPage(),
          const BarcodeScannerPage(),
          const UserInfoPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        // Set the background color of the navigation bar to black
        selectedItemColor: Colors.lightBlue,
        // Set the selected icon color to white
        unselectedItemColor: Colors.black87,
        // Set the unselected icon color to white
        currentIndex: selectedTabIndex,
        onTap: (index) {
          setState(() {
            selectedTabIndex = index;
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'My Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Suggest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}