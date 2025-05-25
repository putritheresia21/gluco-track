import 'package:flutter/material.dart';

class GlucoseMeasuring extends StatelessWidget {
  const GlucoseMeasuring({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Measurement'),
      ),
      body: const Center(
        child: Text(
          'ini buat ngitung/calc glukosa yakk ZRILLLLLL',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
