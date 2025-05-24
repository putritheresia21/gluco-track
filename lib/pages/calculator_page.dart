import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/user_service.dart';
import 'profile_page.dart';

class CalculatorPage extends StatefulWidget {
  @override
  State<CalculatorPage> createState() => HomePageState();
}

class HomePageState extends State<CalculatorPage> {


  @override 
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text("This is Home Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Horray! You are logged in! Cukkurukuuukkk"),
          ],
        ),
      ),
    );
  }
}

