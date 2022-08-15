import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/first_page.dart';
import 'package:flutter_complete_guide/screens/home_screen.dart';

class UserNavigationBar extends StatefulWidget {
  @override
  _UserNavigationBarState createState() => _UserNavigationBarState();
}

class _UserNavigationBarState extends State<UserNavigationBar> {
  int index = 0;
  final screens = [
    FirstPage(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            indicatorColor: Colors.amber[200],
            labelTextStyle: MaterialStateProperty.all(TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black))),
        child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: Duration(seconds: 2),
            height: 60,
            selectedIndex: index,
            onDestinationSelected: (index) =>
                setState(() => this.index = index),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
                selectedIcon: Icon(
                  Icons.home,
                ),
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                ),
                label: 'My Profile',
                selectedIcon: Icon(
                  Icons.person,
                ),
              ),
            ]),
      ),
    );
  }
}
