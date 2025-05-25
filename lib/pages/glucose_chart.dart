import 'package:flutter/material.dart';

class GlucoseChart extends StatelessWidget {
  const GlucoseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Chart'),
      ),
      body: const Center(
        child: Text(
          'enih buat grapik ok cig',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
