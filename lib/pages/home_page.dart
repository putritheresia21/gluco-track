import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/user_service.dart';
import 'profile_page.dart';
//Semangat cukurukuuukkkk

class HomePage extends StatefulWidget {
  final String userId;
  final String username;
  const HomePage({Key? key, required this.userId, required this.username})
      : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final UserService userService = UserService();
  bool? profileExists;

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
