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

  @override
  void dispose() {
    pageController
        .dispose(); // Dispose of the PageController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        children: [
          HomePage(),
          // const BookPage(),
          const MyLibraryPage(),
          const UserInfoPage(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xff404040), // Màu của thanh điều hướng
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xff404040), // Màu của thanh điều hướng
          selectedItemColor: Colors.white, // Màu của mục được chọn
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
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
      ),
    );
  }
}