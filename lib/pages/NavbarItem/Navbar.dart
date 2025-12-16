import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/HomePage.dart';
import 'package:glucotrack_app/pages/NavbarItem/GlucoseChartPage.dart';
import 'package:glucotrack_app/pages/glucose_measuring.dart';
import 'package:glucotrack_app/pages/SocialPage.dart';
import 'package:glucotrack_app/pages/profile.dart';

class CustomBottomNav extends StatefulWidget {
  final String userId;
  final String username;
  final int? initialSelectedIndex;
  final double? navbarHeight;

  const CustomBottomNav({
    Key? key,
    required this.userId,
    required this.username,
    this.initialSelectedIndex,
    this.navbarHeight,
  }) : super(key: key);

  @override
  CustomBottomNavState createState() => CustomBottomNavState();
}

class CustomBottomNavState extends State<CustomBottomNav> {
  late int selectedIndex;
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
    selectedIndex = widget.initialSelectedIndex ?? 0;
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
    final navHeight = widget.navbarHeight ?? 52;

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: SizedBox(
          height: navHeight,
          child: BottomAppBar(
            color: const Color(0xFFF5F5F5),
            padding: EdgeInsets.zero,
            child: Container(
              height: navHeight,
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) => buildNavItem(index)),
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[index],
              size: 24,
              color: isActive ? Color(0xFF2C7796) : Colors.grey,
            ),
            // SizedBox(height: 4),
            // Text(
            //   labels[index],
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: isActive ? Color(0xFF2C7796) : Colors.grey,
            //     fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
