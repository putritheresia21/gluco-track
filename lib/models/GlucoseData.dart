import 'package:flutter/material.dart';

class GlucoseData {
  final double glucosePredict;
  final String confidence;
  final DateTime createdAt;

  GlucoseData({
    required this.glucosePredict,
    required this.confidence,
    required this.createdAt,
  });

  factory GlucoseData.fromJson(Map<String, dynamic> json) {
    return GlucoseData(
      glucosePredict: (json['glucose_predict'] as num).toDouble(),
      confidence: json['confidence'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Color getGlucoseColor() {
    if (glucosePredict < 70) return Colors.blue;
    if (glucosePredict >= 70 && glucosePredict <= 99) return Colors.green;
    if (glucosePredict >= 100 && glucosePredict <= 125) return Colors.orange;
    return Colors.red;
  }

   String getGlucoseStatus() {
    if (glucosePredict < 70) return 'Rendah';
    if (glucosePredict >= 70 && glucosePredict <= 99) return 'Normal';
    if (glucosePredict >= 100 && glucosePredict <= 125) return 'Prediabetes';
    return 'Tinggi';
  }

  Color getConfidenceColor() {
    switch (confidence.toUpperCase()) {
      case 'HIGH':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}