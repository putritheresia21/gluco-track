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

  Map<String, dynamic> toMap(){
    return{
      'userId': userId,
      'timestamp': timeStamp.toIso8601String(),
      'glucoseLevel': glucoseLevel,
      'condition': condition.name,
    };
  }

  factory Glucoserecord.fromMap(String id, Map<String, dynamic> map){
    return Glucoserecord(
      id: id,
      userId: map['userId'] ?? '',
      timeStamp: DateTime.parse(map['timestamp']),
      glucoseLevel: map['glucoseLevel']?.toDouble() ?? 0.0,
      condition: GlucoseCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => GlucoseCondition.beforeMeal,
      )
    );
  }
}

enum GlucoseCondition{
  beforeMeal,
  afterMeal,
}