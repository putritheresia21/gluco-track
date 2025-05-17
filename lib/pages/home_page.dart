import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override  
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("This is Home Page")),
      body: Center(
        child: Text("HORAYY! You are logged in! Cukurukukk"),
      ),
    );
  }
}