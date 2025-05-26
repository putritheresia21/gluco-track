import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/user_service.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';//nanti boleh dipindah ngikut ke button logout
import 'package:glucotrack_app/pages/login_page.dart';//ini juga. sementara aku taruh sini dlu buat testing
//Semangat cukurukuuukkkk

class HomePage extends StatefulWidget {
  final String userId;
  final String username;
  const HomePage({Key? key, required this.userId, required this.username}) : super(key: key);
  
  @override
  State<HomePage> createState() => HomePageState();
}

void logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false, 
  );
}

class HomePageState extends State<HomePage> {
  final UserService userService = UserService();
  bool? profileExists;

  //function untuk konfirmasi logout
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
  void initState() {
    super.initState();
    checkProfile();
  } 


  Future<void> checkProfile() async {
    bool exists = await userService.checkUserProfileExists(widget.userId);
    setState(() {
      profileExists = exists;
    });
  }

  @override 
  Widget build(BuildContext context) {
    if (profileExists == null) {
      return Scaffold(
        appBar: AppBar(title: Text("This is Home Page")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("This is Home Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Horray! You are logged in! Cukkurukuuukkk"),

            //button logout
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => confirmLogout(context),
              child: const Text("Logout"),
            ),
            //sampai sini
            
            if (!profileExists!)
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                  //checkProfile();
                },
                child: Text("Lengkapi Profile"),
              ),
          ],
        ),
      ),
    );
  }
}

