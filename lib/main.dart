import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';
import '../pages/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  Future<Widget> getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');

    if (userId != null && username != null) {
      return CustomBottomNav(
        userId: userId,
        username: username,
      );
    } else {
      return const LoginPage();
    }
  }
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlucoTrack',
      home: FutureBuilder<Widget>(
        future: getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
