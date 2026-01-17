import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class SupabaseService {
  final supabase = Supabase.instance.client;
  
  Future<Map<String, dynamic>?> sendMeasurementTrigger(String userId) async {
    try {
      print('🚀 Sending trigger to Supabase...');
      
      final response = await supabase.from('measurement_commands').insert({
        'user_id': userId,
        'processed': false,
        'status': 'triggered',
        'status_message': 'Waiting for sensor...',
        'progress': 0,
      }).select().single();
      
      return response; 
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getLatestMeasurement(String userId) async {
    try {
      final response = await supabase
          .from('measurements')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return response[0];
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Stream<Map<String, dynamic>?> pollForMeasurement(
    String userId,
    {int maxAttempts = 30}
  ) async* {
    int attempts = 0;
    Map<String, dynamic>? lastData;
    
    
    lastData = await getLatestMeasurement(userId);
    final lastId = lastData?['id'];
    
    while (attempts < maxAttempts) {
      attempts++;
      await Future.delayed(Duration(seconds: 1));
      
      
      final currentData = await getLatestMeasurement(userId);
      
      if (currentData != null && currentData['id'] != lastId) {
        yield currentData;
        break;
      }
      
      yield null;
    }
    
    if (attempts >= maxAttempts) {
    }
  }
  
  // Helper to get latest status log
  Future<Map<String, dynamic>?> getLatestStatusLog(String commandId) async {
    try {
      final response = await supabase
          .from('measurement_status')
          .select('status, message, created_at')
          .eq('command_id', commandId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('⚠️ Error in getLatestStatusLog: $e');
      return null;
    }
  }

  // Stream untuk realtime status updates dari ESP32
  Stream<Map<String, dynamic>> streamCommandStatus(String commandId, {String? userId}) async* {
    final int maxTime = 60; // Max 60 detik
    final startTime = DateTime.now();
    bool isCompleted = false;
    String lastStatus = '';
    
    // Track latest measurement ID if userId is provided
    String? initialMeasurementId;
    if (userId != null) {
      final latest = await getLatestMeasurement(userId);
      initialMeasurementId = latest?['id'];
    }
    
    print('🔄 Starting status stream for command $commandId using measurement_status table');
    
    while (DateTime.now().difference(startTime).inSeconds < maxTime) {
      await Future.delayed(Duration(milliseconds: 1000));
      
      try {
        // 1. Check for final result first (Priority)
        if (userId != null) {
           final currentLatest = await getLatestMeasurement(userId);
           final currentId = currentLatest?['id'];
           
           if (currentId != null && currentId != initialMeasurementId) {
             print('✅ New measurement detected directly!');
             yield {
              'status': 'completed',
              'status_message': 'Measurement received!',
              'progress': 100,
              'processed': true,
             };
             isCompleted = true;
             break;
           }
        }
        
        // 2. Check for intermediate status logs
        final log = await getLatestStatusLog(commandId);
        
        if (log != null) {
          final currentStatus = log['status'];
          // Only yield if status changed or it's the first time
          if (currentStatus != lastStatus) {
            lastStatus = currentStatus;
            
            // Map status string to progress % (approximate)
            int progress = 0;
            if (currentStatus == 'validating') progress = 20;
            else if (currentStatus == 'stabilizing') progress = 40;
            else if (currentStatus == 'sampling') progress = 60;
            else if (currentStatus == 'processing') progress = 80;
            else if (currentStatus == 'completed') progress = 100;
            
            print('📊 Log Status: $currentStatus | ${log['message']}');
            
            yield {
              'status': currentStatus,
              'status_message': log['message'] ?? '',
              'progress': progress,
              'processed': currentStatus == 'completed' || currentStatus == 'error',
            };
            
            if (currentStatus == 'completed' || currentStatus == 'error') {
              isCompleted = true;
              break;
            }
          }
        }
      } catch (e) {
        print('⚠️ Error polling status: $e');
      }
    }
    
    // Timeout
    if (!isCompleted) {
      print('❌ Timeout reached');
      yield {
        'status': 'timeout',
        'status_message': 'No response from sensor',
        'progress': 0,
        'processed': true,
      };
    }
  }
}