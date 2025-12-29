import 'package:flutter/material.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_repository.dart';

enum TaskType {
  manualGlucose,
  iotGlucose,
  socialPost,
}

enum BadgeLevel {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class SubTask {
  final int id;
  final int requiredCount;
  final int points;
  bool claimed;

  SubTask({
    required this.id,
    required this.requiredCount,
    required this.points,
    this.claimed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'requiredCount': requiredCount,
        'points': points,
        'claimed': claimed,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'],
        requiredCount: json['requiredCount'],
        points: json['points'],
        claimed: json['claimed'] ?? false,
      );
      
  factory SubTask.fromDatabase(Map<String, dynamic> data) => SubTask(
        id: data['subtask_id'],
        requiredCount: data['required_count'],
        points: data['points'],
        claimed: data['claimed'] ?? false,
      );
}

class MainTask {
  final TaskType type;
  final String title;
  final String description;
  final List<SubTask> subTasks;
  int currentCount;
  String? databaseId; // ID from Supabase

  MainTask({
    required this.type,
    required this.title,
    required this.description,
    required this.subTasks,
    this.currentCount = 0,
    this.databaseId,
  });

  int get totalPoints =>
      subTasks.fold(0, (sum, task) => sum + (task.claimed ? task.points : 0));
  int get maxPoints => 200;
  int get completedSubTasks => subTasks.where((t) => t.claimed).length;
  int get totalSubTasks => subTasks.length;
  double get progress => completedSubTasks / totalSubTasks;

  List<SubTask> get claimableSubTasks {
    return subTasks.where((subTask) {
      return !subTask.claimed && currentCount >= subTask.requiredCount;
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'title': title,
        'description': description,
        'subTasks': subTasks.map((t) => t.toJson()).toList(),
        'currentCount': currentCount,
      };

  factory MainTask.fromJson(Map<String, dynamic> json) => MainTask(
        type: TaskType.values[json['type']],
        title: json['title'],
        description: json['description'],
        subTasks:
            (json['subTasks'] as List).map((t) => SubTask.fromJson(t)).toList(),
        currentCount: json['currentCount'] ?? 0,
      );
      
  factory MainTask.fromDatabase(Map<String, dynamic> data, List<SubTask> subtasks) {
    final typeStr = data['task_type'] as String;
    final type = TaskType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => TaskType.manualGlucose,
    );
    
    return MainTask(
      type: type,
      title: data['title'],
      description: data['description'] ?? '',
      currentCount: data['current_count'] ?? 0,
      subTasks: subtasks,
      databaseId: data['id'],
    );
  }
}

class GamificationService {
  static GamificationService? _instance;
  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }

  GamificationService._();

  final GamificationRepository _repository = GamificationRepository();
  List<MainTask> _tasks = [];
  int _totalPoints = 0;
  BadgeLevel _currentBadge = BadgeLevel.bronze;

  Future<void> initialize({BuildContext? context}) async {
    await _checkMonthlyReset(context);
    await _loadData(context);
  }

  Future<void> _checkMonthlyReset(BuildContext? context) async {
    try {
      final needsReset = await _repository.needsMonthlyReset();
      if (needsReset) {
        await _resetMonthlyProgress(context);
      }
    } catch (e) {
      print('Error checking monthly reset: $e');
    }
  }

  Future<void> _resetMonthlyProgress(BuildContext? context) async {
    try {
      await _repository.resetMonthlyData();
      _tasks = await _createDefaultTasks(context);
      await _saveTasks();
    } catch (e) {
      print('Error resetting monthly progress: $e');
    }
  }

  Future<void> _loadData(BuildContext? context) async {
    try {
      print('🔄 Loading gamification data from database...');
      
      // Load total points and badge
      _totalPoints = await _repository.getTotalPoints();
      _currentBadge = await _repository.getCurrentBadge();
      print('💰 Loaded points: $_totalPoints, Badge: ${_currentBadge.name}');

      // Load tasks
      final tasksData = await _repository.getUserTasks();
      print('📋 Found ${tasksData.length} tasks in database');
      
      if (tasksData.isEmpty) {
        // First time - create default tasks
        print('🆕 Creating default tasks...');
        _tasks = await _createDefaultTasks(context);
        await _saveTasks();
      } else {
        // Load tasks from database
        _tasks = [];
        for (final taskData in tasksData) {
          final subtasksData = await _repository.getSubtasks(taskData['id']);
          final subtasks = subtasksData
              .map((st) => SubTask.fromDatabase(st))
              .toList();
          
          final task = MainTask.fromDatabase(taskData, subtasks);
          _tasks.add(task);
          
          final claimedCount = subtasks.where((st) => st.claimed).length;
          print('✅ Task ${task.type.name}: ${task.currentCount} progress, $claimedCount claimed');
        }
        
        // Update task titles/descriptions if language changed
        if (context != null) {
          await _updateTaskLocalization(context);
        }
      }
      
      print('✅ Gamification data loaded successfully');
    } catch (e) {
      print('❌ Error loading gamification data: $e');
      print('Stack trace: ${StackTrace.current}');
      // Fallback to empty state
      _tasks = [];
      _totalPoints = 0;
      _currentBadge = BadgeLevel.bronze;
      // Don't rethrow - allow app to continue with empty state
    }
  }

  Future<void> _updateTaskLocalization(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    bool needsUpdate = false;
    
    for (var task in _tasks) {
      String newTitle;
      String newDesc;
      
      switch (task.type) {
        case TaskType.manualGlucose:
          newTitle = l10n.manualGlucoseTaskTitle;
          newDesc = l10n.manualGlucoseTaskDesc;
          break;
        case TaskType.iotGlucose:
          newTitle = l10n.iotGlucoseTaskTitle;
          newDesc = l10n.iotGlucoseTaskDesc;
          break;
        case TaskType.socialPost:
          newTitle = l10n.socialPostTaskTitle;
          newDesc = l10n.socialPostTaskDesc;
          break;
      }
      
      if (task.title != newTitle || task.description != newDesc) {
        // Update in database
        await _repository.upsertTask(
          taskType: task.type,
          title: newTitle,
          description: newDesc,
          currentCount: task.currentCount,
        );
        
        // Update local object
        task = MainTask(
          type: task.type,
          title: newTitle,
          description: newDesc,
          subTasks: task.subTasks,
          currentCount: task.currentCount,
          databaseId: task.databaseId,
        );
        
        final index = _tasks.indexOf(task);
        _tasks[index] = task;
        needsUpdate = true;
      }
    }
  }

  Future<List<MainTask>> _createDefaultTasks(BuildContext? context) async {
    final l10n = context != null ? AppLocalizations.of(context)! : null;
    
    final tasks = [
      MainTask(
        type: TaskType.manualGlucose,
        title: l10n?.manualGlucoseTaskTitle ?? 'Manual Glucose Recording',
        description: l10n?.manualGlucoseTaskDesc ?? 'Record your blood sugar using the manual input form',
        subTasks: _createSubTasks(),
      ),
      MainTask(
        type: TaskType.iotGlucose,
        title: l10n?.iotGlucoseTaskTitle ?? 'IoT Glucose Monitoring',
        description: l10n?.iotGlucoseTaskDesc ?? 'Track glucose using IoT device',
        subTasks: _createSubTasks(),
      ),
      MainTask(
        type: TaskType.socialPost,
        title: l10n?.socialPostTaskTitle ?? 'Post on Social Feeds',
        description: l10n?.socialPostTaskDesc ?? 'Share your experience on social feeds',
        subTasks: _createSubTasks(),
      ),
    ];
    
    return tasks;
  }

  List<SubTask> _createSubTasks() {
    return [
      SubTask(id: 1, requiredCount: 5, points: 25),
      SubTask(id: 2, requiredCount: 10, points: 50),
      SubTask(id: 3, requiredCount: 15, points: 75),
      SubTask(id: 4, requiredCount: 20, points: 50),
    ];
  }

  Future<void> _saveTasks() async {
    try {
      for (final task in _tasks) {
        final taskData = await _repository.upsertTask(
          taskType: task.type,
          title: task.title,
          description: task.description,
          currentCount: task.currentCount,
        );
        
        task.databaseId = taskData['id'];
        
        // Create subtasks if not exist
        final existingSubtasks = await _repository.getSubtasks(task.databaseId!);
        if (existingSubtasks.isEmpty) {
          await _repository.createSubtasks(
            userTaskId: task.databaseId!,
            subTasks: task.subTasks,
          );
        }
      }
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  Future<void> incrementTaskProgress(TaskType type) async {
    try {
      final task = _tasks.firstWhere((t) => t.type == type);
      final oldCount = task.currentCount;
      task.currentCount++;
      final newCount = task.currentCount;
      
      print('📈 Incrementing ${type.name}: $oldCount → $newCount');
      
      // Update database
      await _repository.updateTaskCount(type.name, newCount);
      print('✅ Database updated for ${type.name}: $newCount');
      
      // Verify the update succeeded
      final tasks = await _repository.getUserTasks();
      final updated = tasks.firstWhere((t) => t['task_type'] == type.name);
      final verifiedCount = updated['current_count'] as int;
      
      if (verifiedCount == newCount) {
        print('✅ Progress verified in database: $verifiedCount');
      } else {
        print('⚠️ Progress mismatch! Expected: $newCount, Got: $verifiedCount');
        task.currentCount = verifiedCount; // Use database value
      }
    } catch (e) {
      print('❌ Error incrementing task progress: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow; // Don't silent the error
    }
  }

  Future<void> claimReward(TaskType type, SubTask subTask) async {
    try {
      final task = _tasks.firstWhere((t) => t.type == type);
      
      if (task.databaseId == null) {
        throw Exception('Task not saved to database yet');
      }
      
      // Mark as claimed locally first
      subTask.claimed = true;
      
      // Update database - claim subtask
      print('📝 Claiming subtask ${subTask.id} for task ${task.databaseId}');
      await _repository.claimSubtask(task.databaseId!, subTask.id);
      
      // Update total points
      final newTotalPoints = _totalPoints + subTask.points;
      print('💰 Updating points: $_totalPoints → $newTotalPoints');
      await _repository.updatePoints(newTotalPoints);
      
      // Verify the update succeeded
      final verifiedPoints = await _repository.getTotalPoints();
      print('✅ Points verified in database: $verifiedPoints');
      
      if (verifiedPoints == newTotalPoints) {
        _totalPoints = newTotalPoints;
        print('✅ Claim successful! New total: $_totalPoints');
      } else {
        print('⚠️ Points mismatch! Expected: $newTotalPoints, Got: $verifiedPoints');
        throw Exception('Points verification failed');
      }
      
      // Badge will be auto-updated by trigger
      _currentBadge = await _repository.getCurrentBadge();
    } catch (e) {
      print('❌ Error claiming reward: $e');
      // Revert local state if database update failed
      subTask.claimed = false;
      rethrow; // Re-throw so UI can show error
    }
  }

  // Getters
  List<MainTask> getTasks() => _tasks;
  int getTotalPoints() => _totalPoints;
  BadgeLevel getCurrentBadge() => _currentBadge;

  int getTaskProgress(TaskType type) {
    try {
      return _tasks.firstWhere((t) => t.type == type).currentCount;
    } catch (e) {
      return 0;
    }
  }
}
