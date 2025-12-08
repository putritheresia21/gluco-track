import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import 'package:glucotrack_app/pages/glucose_chart.dart';
import 'package:glucotrack_app/pages/glucose_measuring.dart';
import 'package:glucotrack_app/pages/social_page.dart';
import 'package:glucotrack_app/pages/profile.dart';

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

  List<String> labels = ["Home", "Chart", "Measure", "Social", "Profile"];

  List<IconData> icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.favorite_rounded,
    Icons.group_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(),
      GlucoseChart(),
      GlucoseMeasuring(),
      SocialPage(),
      Profile(),
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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) => buildNavItem(index)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[index],
              size: 24,
              color: isActive ? Color(0xFF2C7796) : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Color(0xFF2C7796) : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
