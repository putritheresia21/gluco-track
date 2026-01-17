import 'package:supabase_flutter/supabase_flutter.dart';

/// Model class for Glucose Reminder
class GlucoseReminder {
  final String id;
  final String userId;
  final DateTime reminderTime; // Time component only
  final List<int> daysOfWeek; // 0=Sunday, 1=Monday, ..., 6=Saturday
  final bool isActive;
  final String label;
  final DateTime createdAt;
  final DateTime updatedAt;

  GlucoseReminder({
    required this.id,
    required this.userId,
    required this.reminderTime,
    required this.daysOfWeek,
    required this.isActive,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GlucoseReminder.fromJson(Map<String, dynamic> json) {
    // Parse TIME format from PostgreSQL (e.g., "14:30:00")
    final timeString = json['reminder_time'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Create DateTime with today's date + reminder time
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);

    return GlucoseReminder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reminderTime: reminderTime,
      daysOfWeek: (json['days_of_week'] as List).cast<int>(),
      isActive: json['is_active'] as bool,
      label: json['label'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert DateTime to TIME format for PostgreSQL
    final timeString = '${reminderTime.hour.toString().padLeft(2, '0')}:'
        '${reminderTime.minute.toString().padLeft(2, '0')}:00';

    return {
      'user_id': userId,
      'reminder_time': timeString,
      'days_of_week': daysOfWeek,
      'is_active': isActive,
      'label': label,
    };
  }
}

/// Repository for managing glucose reminders
class ReminderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all reminders for the current user
  Future<List<GlucoseReminder>> getReminders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('glucose_reminders')
          .select()
          .eq('user_id', userId)
          .order('reminder_time', ascending: true);

      return (response as List)
          .map((json) => GlucoseReminder.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching reminders: $e');
      rethrow;
    }
  }

  /// Get only active reminders
  Future<List<GlucoseReminder>> getActiveReminders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('glucose_reminders')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('reminder_time', ascending: true);

      return (response as List)
          .map((json) => GlucoseReminder.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching active reminders: $e');
      rethrow;
    }
  }

  /// Create a new reminder
  Future<String> createReminder({
    required DateTime reminderTime,
    required List<int> daysOfWeek,
    String label = 'Glucose Reminder',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Validate days
      if (daysOfWeek.isEmpty) {
        throw Exception('At least one day must be selected');
      }
      if (daysOfWeek.any((day) => day < 0 || day > 6)) {
        throw Exception('Invalid day value (must be 0-6)');
      }

      final timeString = '${reminderTime.hour.toString().padLeft(2, '0')}:'
          '${reminderTime.minute.toString().padLeft(2, '0')}:00';

      final response = await _supabase
          .from('glucose_reminders')
          .insert({
            'user_id': userId,
            'reminder_time': timeString,
            'days_of_week': daysOfWeek,
            'label': label,
            'is_active': true,
          })
          .select('id')
          .single();

      print('✅ Reminder created: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      print('❌ Error creating reminder: $e');
      rethrow;
    }
  }

  /// Update an existing reminder
  Future<void> updateReminder({
    required String reminderId,
    DateTime? reminderTime,
    List<int>? daysOfWeek,
    String? label,
    bool? isActive,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      Map<String, dynamic> updates = {};

      if (reminderTime != null) {
        final timeString = '${reminderTime.hour.toString().padLeft(2, '0')}:'
            '${reminderTime.minute.toString().padLeft(2, '0')}:00';
        updates['reminder_time'] = timeString;
      }

      if (daysOfWeek != null) {
        if (daysOfWeek.isEmpty) {
          throw Exception('At least one day must be selected');
        }
        updates['days_of_week'] = daysOfWeek;
      }

      if (label != null) updates['label'] = label;
      if (isActive != null) updates['is_active'] = isActive;

      if (updates.isEmpty) return;

      await _supabase
          .from('glucose_reminders')
          .update(updates)
          .eq('id', reminderId)
          .eq('user_id', userId); // Ensure user owns this reminder

      print('✅ Reminder updated: $reminderId');
    } catch (e) {
      print('❌ Error updating reminder: $e');
      rethrow;
    }
  }

  /// Toggle reminder active status
  Future<void> toggleReminder(String reminderId, bool isActive) async {
    await updateReminder(reminderId: reminderId, isActive: isActive);
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _supabase
          .from('glucose_reminders')
          .delete()
          .eq('id', reminderId)
          .eq('user_id', userId); // Ensure user owns this reminder

      print('✅ Reminder deleted: $reminderId');
    } catch (e) {
      print('❌ Error deleting reminder: $e');
      rethrow;
    }
  }
}
