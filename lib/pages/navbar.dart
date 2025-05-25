import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/calculator_page.dart';
import 'package:glucotrack_app/pages/glucose_chart.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import 'package:glucotrack_app/pages/login_page.dart';
import 'package:glucotrack_app/pages/notification_page.dart';
import 'package:glucotrack_app/pages/profile_page.dart';
import 'package:glucotrack_app/pages/register_page.dart';

import 'glucose_measuring.dart';

class CustomBottomNav extends StatefulWidget {
  final String userId;
  final String username;

  const CustomBottomNav(
      {Key? key, required this.userId, required this.username})
      : super(key: key);

  @override
  CustomBottomNavState createState() => CustomBottomNavState();
}

class CustomBottomNavState extends State<CustomBottomNav> {
  int selectedIndex = 0;
  late final List<Widget> pages;

  List<String> labels = ["Home", "Chart", "Notification", "Profile"];
  List<String> iconPaths = [
    'assets/navbar/newhome.png',
    'assets/navbar/newchart.png',
    'assets/navbar/notification.png',
    'assets/navbar/newprofile.png',
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(userId: widget.userId, username: widget.username),
      GlucoseChart(),
      NotificationPage(),
      ProfilePage(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2C7796)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GlucoseMeasuring()),
            );
          },
          child: Image.asset(
            'assets/navbar/calc2.png',
            width: 28,
            height: 38,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(2, (index) => buildNavItem(index)),
              ),
              Row(
                children: List.generate(2, (index) => buildNavItem(index + 2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(int index) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPaths[index],
              width: 24,
              height: 24,
              color: isActive ? Color(0xFF2C7796) : Colors.grey,
            ),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Color(0xFF2C7796) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
