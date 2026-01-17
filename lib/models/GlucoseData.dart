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
    // Parse String to DateTime
    // Supabase usually returns '2025-01-01T12:00:00+00:00' or similar
    // We ensure it is treated as UTC first if no offset is detected, then convert to Local
    String dateStr = json['created_at'];
    if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
       dateStr += 'Z'; // Force UTC if ambiguous
    }
    
    return GlucoseData(
      glucosePredict: (json['glucose_predict'] as num).toDouble(),
      confidence: json['confidence'] as String,
      createdAt: DateTime.parse(dateStr).toLocal(), // ALWAYS convert to device local time
    );
  }

  Color getGlucoseColor() {
    if (glucosePredict < 70) return Colors.blue;
    if (glucosePredict >= 70 && glucosePredict <= 99) return Colors.green;
    if (glucosePredict >= 100 && glucosePredict <= 125) return Colors.orange;
    return Colors.red;
  }

  String getGlucoseStatus() {
    if (glucosePredict < 70) return 'Low';
    if (glucosePredict >= 70 && glucosePredict <= 99) return 'Normal';
    if (glucosePredict >= 100 && glucosePredict <= 125) return 'High';
    return 'Very High';
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