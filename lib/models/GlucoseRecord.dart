class Glucoserecord {
  final String id;
  final String userId;
  final double glucoseLevel;
  final DateTime timeStamp;
  final GlucoseCondition condition;

  Glucoserecord({
    required this.id,
    required this.userId,
    required this.glucoseLevel,
    required this.timeStamp,
    required this.condition,
  });

  factory Glucoserecord.empty() {
    return Glucoserecord(
      id: '',
      userId: '',
      glucoseLevel: 0.0,
      timeStamp: DateTime.now(),
      condition: GlucoseCondition.beforeMeal,
    );
  }

  
  Map<String, dynamic> toMap(){
    return{
      'userId': userId,
      'timestamp': timeStamp.toIso8601String(),
      'glucoseLevel': glucoseLevel,
      'condition': condition.name,
    };
  }

  factory Glucoserecord.fromMap(String id, Map<String, dynamic> map){
    final timestampStr = map['timestamp'];
    final conditionStr = map['condition'];
    return Glucoserecord(
      id: id,
      userId: map['userId'] ?? '',
      glucoseLevel: (map['glucoseLevel'] ?? 0.0).toDouble(),
      timeStamp: timestampStr != null ? DateTime.parse(timestampStr) : DateTime.now(),
      condition: GlucoseCondition.values.firstWhere(
        (e) => e.name == conditionStr,
        orElse: () => GlucoseCondition.beforeMeal,
      )
    );
  }
}

enum GlucoseCondition{
  beforeMeal,
  afterMeal,
}

bool isSameDay(DateTime a, DateTime b){
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
