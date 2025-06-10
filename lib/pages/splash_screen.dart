import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glucotrack_app/pages/started_page.dart';
import 'package:glucotrack_app/pages/home_page.dart';

import 'navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    print("[SplashScreen] Delay started...");
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('is_first_open') ?? true;
    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3));
    print("[SplashScreen] Delay ended. Mounted: $mounted");

    if (!mounted) return;

    if (isFirstOpen) {
      print("[SplashScreen] First open. Navigating to GetStartedPage");
      await prefs.setBool('is_first_open', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
    } else if (user != null) {
      print("[SplashScreen] User logged in. Navigating to HomePage");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomBottomNav(
            userId: user.uid,
            username: user.displayName ?? 'User',
          ),
        ),
      );
    } else {
      print(
          "[SplashScreen] Not first open. User not logged in. Navigating to GetStartedPage");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    print("SplashScreen build called");
    return Scaffold(
      backgroundColor: const Color(0xFF2C7796),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Gluc',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Image.asset(
                'assets/Logo.png',
                width: 27,
                height: 30,
              ),
            ),
            const Text(
              'Track',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
