import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/navbar.dart';
import '../services/Auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

Future<void> saveLoginData(String userId, String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setString('username', username);
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  void handleLogin() async {
    final user = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String username = "";

      if (userDoc.exists) {
        final userData = userDoc.data();
        username = (userData?['username'] as String?)?.trim() ?? "";
      }
      if (username.isEmpty){
        username = user.email ?? "User";
      }

      await saveLoginData(uid, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, $username!"))
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomBottomNav(
          userId: user.uid,
          username: username,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Don't have an account? Register here!"),
            ),
          ],
        ),
      ),
    );
  }
}