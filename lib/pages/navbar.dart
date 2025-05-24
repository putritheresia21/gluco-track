import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/calculator_page.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import 'package:glucotrack_app/pages/login_page.dart';
import 'package:glucotrack_app/pages/profile_page.dart';
import 'package:glucotrack_app/pages/register_page.dart';

class CustomBottomNav extends StatefulWidget {
  final String userId;
  final String username;

  const CustomBottomNav({Key? key, required this.userId, required this.username}) : super(key: key);

  @override   
  CustomBottomNavState createState() => CustomBottomNavState();
}

class CustomBottomNavState extends State<CustomBottomNav> {
  
  int selectedIndex = 0;
  late final List<Widget> pages;

  List<String> labels = ["Home", "Search", "Cart", "Profile"];
  List<String> iconPaths = [
    'assets/navbar/home.png',
    'assets/navbar/search.png',
    'assets/navbar/cart.png',
    'assets/navbar/user.png',
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(userId: widget.userId, username: widget.username),
      LoginPage(),
      RegisterPage(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: Image.asset(
          'assets/navbar/shop.png',
          width: 28,
          height: 38,
          color: Colors.white,
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
              color: isActive ? Colors.deepPurple : Colors.grey,
            ),
            Text(
              labels[index],
              style: TextStyle( 
                fontSize: 12,
                color: isActive ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}