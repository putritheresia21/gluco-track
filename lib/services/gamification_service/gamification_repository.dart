import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';

class GamificationRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  String? get _userId => _client.auth.currentUser?.id;

  // ============ USER GAMIFICATION ============
  
  /// Get or create gamification record for current user
  Future<Map<String, dynamic>> getUserGamification() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final response = await _client
        .from('user_gamification')
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();
    
    if (response == null) {
      // Create new record
      final newRecord = {
        'user_id': _userId!,
        'total_points': 0,
        'current_badge': 'bronze',
        'last_reset_date': DateTime.now().toIso8601String(),
      };
      
      await _client.from('user_gamification').insert(newRecord);
      return newRecord;
    }
    
    return response;
  }
  
  /// Update total points and auto-update badge
  Future<void> updatePoints(int totalPoints) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _client
        .from('user_gamification')
        .update({'total_points': totalPoints})
        .eq('user_id', _userId!);
  }
  
  /// Update last reset date
  Future<void> updateLastReset(DateTime date) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _client
        .from('user_gamification')
        .update({'last_reset_date': date.toIso8601String()})
        .eq('user_id', _userId!);
  }

  // ============ USER TASKS ============
  
  /// Get all tasks for current user
  Future<List<Map<String, dynamic>>> getUserTasks() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final response = await _client
        .from('user_tasks')
        .select()
        .eq('user_id', _userId!);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Create or update a task
  Future<Map<String, dynamic>> upsertTask({
    required TaskType taskType,
    required String title,
    required String description,
    required int currentCount,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final taskData = {
      'user_id': _userId!,
      'task_type': taskType.name,
      'title': title,
      'description': description,
      'current_count': currentCount,
    };
    
    final response = await _client
        .from('user_tasks')
        .upsert(taskData)
        .select()
        .single();
    
    return response;
  }
  
  /// Update task progress count
  Future<void> updateTaskCount(String taskType, int count) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _client
        .from('user_tasks')
        .update({'current_count': count})
        .eq('user_id', _userId!)
        .eq('task_type', taskType);
  }
  
  /// Delete all tasks for current user (for monthly reset)
  Future<void> deleteUserTasks() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _client
        .from('user_tasks')
        .delete()
        .eq('user_id', _userId!);
  }

  // ============ USER SUBTASKS ============
  
  /// Get subtasks for a specific task
  Future<List<Map<String, dynamic>>> getSubtasks(String userTaskId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final response = await _client
        .from('user_subtasks')
        .select()
        .eq('user_task_id', userTaskId)
        .order('subtask_id');
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Create subtasks for a task
  Future<void> createSubtasks({
    required String userTaskId,
    required List<SubTask> subTasks,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final subtaskData = subTasks.map((st) => {
      'user_task_id': userTaskId,
      'user_id': _userId!,
      'subtask_id': st.id,
      'required_count': st.requiredCount,
      'points': st.points,
      'claimed': st.claimed,
      'claimed_at': st.claimed ? DateTime.now().toIso8601String() : null,
    }).toList();
    
    await _client.from('user_subtasks').insert(subtaskData);
  }
  
  /// Claim a subtask
  Future<void> claimSubtask(String userTaskId, int subtaskId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _client
        .from('user_subtasks')
        .update({
          'claimed': true,
          'claimed_at': DateTime.now().toIso8601String(),
        })
        .eq('user_task_id', userTaskId)
        .eq('subtask_id', subtaskId);
  }
  
  /// Get all subtasks for current user (across all tasks)
  Future<List<Map<String, dynamic>>> getAllUserSubtasks() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final response = await _client
        .from('user_subtasks')
        .select('*, user_tasks!inner(*)')
        .eq('user_id', _userId!);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // ============ HELPER METHODS ============
  
  /// Check if monthly reset is needed
  Future<bool> needsMonthlyReset() async {
    final gamification = await getUserGamification();
    final lastResetStr = gamification['last_reset_date'] as String?;
    
    if (lastResetStr == null) return true;
    
    final lastReset = DateTime.parse(lastResetStr);
    final now = DateTime.now();
    
    return now.year != lastReset.year || now.month != lastReset.month;
  }
  
  /// Reset all gamification data for monthly cycle
  Future<void> resetMonthlyData() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    // Delete all tasks (cascade delete will handle subtasks)
    await deleteUserTasks();
    
    // Update last reset date
    await updateLastReset(DateTime.now());
  }
  
  /// Get current badge based on points
  Future<BadgeLevel> getCurrentBadge() async {
    final gamification = await getUserGamification();
    final badgeStr = gamification['current_badge'] as String;
    
    return BadgeLevel.values.firstWhere(
      (b) => b.name == badgeStr,
      orElse: () => BadgeLevel.bronze,
    );
  }
  
  /// Get total points
  Future<int> getTotalPoints() async {
    final gamification = await getUserGamification();
    return gamification['total_points'] as int;
  }
}
