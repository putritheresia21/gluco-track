import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/register_page.dart';
import 'package:glucotrack_app/services/user_service.dart';
import 'profile_page.dart';
import 'package:glucotrack_app/pages/SocialMedia/Feeds.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text('Social'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PublicFeedPage()));
                },
                child: Text("Social Media Feed")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text("Register Page")),
            ElevatedButton(onPressed: () {}, child: Text("Koneksi IOT")),
            ElevatedButton(onPressed: () {}, child: Text("testing sosmed")),
          ],
        ),
      ),
    );
  }
}
