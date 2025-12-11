import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
}

class MainTask {
  final TaskType type;
  final String title;
  final String description;
  final List<SubTask> subTasks;
  int currentCount;

  MainTask({
    required this.type,
    required this.title,
    required this.description,
    required this.subTasks,
    this.currentCount = 0,
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
}

class GamificationService {
  static const String _keyTasks = 'gamification_tasks';
  static const String _keyTotalPoints = 'gamification_total_points';
  static const String _keyLastReset = 'gamification_last_reset';

  static GamificationService? _instance;
  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }

  GamificationService._();

  late SharedPreferences _prefs;
  List<MainTask> _tasks = [];
  int _totalPoints = 0;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkMonthlyReset();
    await _loadData();
  }

  Future<void> _checkMonthlyReset() async {
    final lastResetStr = _prefs.getString(_keyLastReset);
    final now = DateTime.now();

    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      if (now.year != lastReset.year || now.month != lastReset.month) {
        await _resetMonthlyProgress();
      }
    }

    await _prefs.setString(_keyLastReset, now.toIso8601String());
  }

  Future<void> _resetMonthlyProgress() async {
    _tasks = _createDefaultTasks();
    await _saveTasks();
  }

  Future<void> _loadData() async {
    _totalPoints = _prefs.getInt(_keyTotalPoints) ?? 0;

    final tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((t) => MainTask.fromJson(t)).toList();

      // Set currentCount berdasarkan subtask tertinggi yang sudah diclaim
      bool needsSave = false;
      for (var task in _tasks) {
        if (task.currentCount == 0 && task.subTasks.any((st) => st.claimed)) {
          // Cari requiredCount tertinggi dari subtask yang sudah diclaim
          final claimedSubTasks =
              task.subTasks.where((st) => st.claimed).toList();
          if (claimedSubTasks.isNotEmpty) {
            task.currentCount = claimedSubTasks
                .map((st) => st.requiredCount)
                .reduce((a, b) => a > b ? a : b);
            needsSave = true;
          }
        }
      }

      if (needsSave) {
        await _saveTasks();
      }
    } else {
      _tasks = _createDefaultTasks();
      await _saveTasks();
    }
  }

  List<MainTask> _createDefaultTasks() {
    return [
      MainTask(
        type: TaskType.manualGlucose,
        title: 'Pencatatan Gula Darah Manual',
        description:
            'Catat kadar gula darah Anda secara manual menggunakan glucometer',
        subTasks: [
          SubTask(id: 1, requiredCount: 1, points: 20),
          SubTask(id: 2, requiredCount: 3, points: 30),
          SubTask(id: 3, requiredCount: 5, points: 50),
          SubTask(id: 4, requiredCount: 7, points: 50),
          SubTask(id: 5, requiredCount: 10, points: 50),
        ],
      ),
      MainTask(
        type: TaskType.iotGlucose,
        title: 'Pencatatan Gula Darah dengan IoT',
        description: 'Catat kadar gula darah Anda menggunakan perangkat IoT',
        subTasks: [
          SubTask(id: 1, requiredCount: 1, points: 20),
          SubTask(id: 2, requiredCount: 3, points: 30),
          SubTask(id: 3, requiredCount: 5, points: 50),
          SubTask(id: 4, requiredCount: 7, points: 50),
          SubTask(id: 5, requiredCount: 10, points: 50),
        ],
      ),
      MainTask(
        type: TaskType.socialPost,
        title: 'Posting di Social Feeds',
        description: 'Bagikan pengalaman Anda di social feeds',
        subTasks: [
          SubTask(id: 1, requiredCount: 1, points: 20),
          SubTask(id: 2, requiredCount: 3, points: 30),
          SubTask(id: 3, requiredCount: 5, points: 50),
          SubTask(id: 4, requiredCount: 7, points: 50),
          SubTask(id: 5, requiredCount: 10, points: 50),
        ],
      ),
    ];
  }

  Future<void> _saveTasks() async {
    final encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyTasks, encoded);
  }

  Future<void> _saveTotalPoints() async {
    await _prefs.setInt(_keyTotalPoints, _totalPoints);
  }

  List<MainTask> getTasks() => _tasks;
  int getTotalPoints() => _totalPoints;

  BadgeLevel getCurrentBadge() {
    if (_totalPoints <= 300) return BadgeLevel.bronze;
    if (_totalPoints <= 600) return BadgeLevel.silver;
    if (_totalPoints <= 900) return BadgeLevel.gold;
    if (_totalPoints <= 1500) return BadgeLevel.platinum;
    return BadgeLevel.diamond;
  }

  Future<void> incrementTask(TaskType type) async {
    final task = _tasks.firstWhere((t) => t.type == type);

    if (task.currentCount < 10) {
      task.currentCount++;
      await _saveTasks();
    }
  }

  Future<bool> claimSubTask(TaskType type, int subTaskId) async {
    final task = _tasks.firstWhere((t) => t.type == type);
    final subTask = task.subTasks.firstWhere((st) => st.id == subTaskId);

    if (subTask.claimed || task.currentCount < subTask.requiredCount) {
      return false;
    }

    subTask.claimed = true;
    _totalPoints += subTask.points;

    await _saveTasks();
    await _saveTotalPoints();

    return true;
  }

  int getNextBadgePoints() {
    final currentPoints = _totalPoints;
    if (currentPoints <= 300) return 300 - currentPoints;
    if (currentPoints <= 600) return 600 - currentPoints;
    if (currentPoints <= 900) return 900 - currentPoints;
    if (currentPoints <= 1500) return 1500 - currentPoints;
    return 0;
  }
}
