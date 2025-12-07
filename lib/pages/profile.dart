import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //nanti boleh dipindah ngikut ke button logout
import 'package:glucotrack_app/pages/login_page.dart'; //ini juga. sementara aku taruh sini dlu buat testing
//Semangat cukurukuuukkkk

class Profile extends StatelessWidget {
  const Profile({super.key});

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Konfirmasi Logout"),
          content: Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Page',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => confirmLogout(context),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
