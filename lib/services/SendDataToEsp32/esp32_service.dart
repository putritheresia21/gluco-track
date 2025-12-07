import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class SupabaseService {
  final supabase = Supabase.instance.client;
  
  // Kirim trigger ke ESP32
  Future<bool> sendMeasurementTrigger(String userId) async {
    try {
      print('🚀 Sending trigger to Supabase...');
      
      await supabase.from('measurement_commands').insert({
        'user_id': userId,
        'processed': false,
      });
      
      print('✅ Trigger sent successfully!');
      return true;
    } catch (e) {
      print('❌ Error sending trigger: $e');
      return false;
    }
  }
  
  // Ambil hasil terbaru - SIMPLE, tanpa filter waktu
  Future<Map<String, dynamic>?> getLatestMeasurement(String userId) async {
    try {
      final response = await supabase
          .from('measurements')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        print('✅ Data found: ${response[0]['glucose_predict']} mg/dL');
        return response[0];
      }
      
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
  
  // Polling - langsung ambil data terbaru saja
  Stream<Map<String, dynamic>?> pollForMeasurement(
    String userId,
    {int maxAttempts = 30}
  ) async* {
    int attempts = 0;
    Map<String, dynamic>? lastData;
    
    print('🔄 Starting polling...');
    
    // Ambil data terakhir SEBELUM trigger (untuk perbandingan)
    lastData = await getLatestMeasurement(userId);
    final lastId = lastData?['id'];
    print('📌 Last data ID: $lastId');
    
    while (attempts < maxAttempts) {
      attempts++;
      await Future.delayed(Duration(seconds: 1));
      
      print('🔄 Attempt $attempts/$maxAttempts');
      
      final currentData = await getLatestMeasurement(userId);
      
      // Jika ada data baru (ID berbeda dari sebelumnya)
      if (currentData != null && currentData['id'] != lastId) {
        print('✅ NEW DATA FOUND!');
        yield currentData;
        break;
      }
      
      yield null;
    }
    
    if (attempts >= maxAttempts) {
      print('❌ Timeout');
    }
  }
}