import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_test/UIs/test.dart';
import 'home_page.dart';
import 'info_page.dart';
import 'my_library_page.dart';
import 'add_schedule_page.dart';

class MyMainPage extends StatefulWidget {
  final int initialTabIndex;
  const MyMainPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  MyMainPageState createState() => MyMainPageState();
}

class MyMainPageState extends State<MyMainPage> {
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
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
          children: const [
            HomePage(),
            // const BookPage(),
            MyLibraryPage(),
            NotificationPage(),
            UserInfoPage(),
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
      ),
    );
  }

  Future<bool> onWillPop() async {
    bool shouldPop = await showDialog(
      context: context,
      builder: (BuildContext context) {
        double baseWidth = 360;
        double fem = MediaQuery.of(context).size.width / baseWidth;
        return AlertDialog(
          insetPadding: EdgeInsets.all(25*fem),
          title: Text(
            'Confirm Exit',
            style: TextStyle(
              fontSize: 22*fem,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to exit?',
            style: TextStyle(
              fontSize: 18*fem,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Do not exit
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Exit
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (shouldPop == true) {
      if (const bool.fromEnvironment("dart.vm.product")) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
    return shouldPop;
  }
}