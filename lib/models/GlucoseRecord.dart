enum GlucoseCondition { beforeMeal, afterMeal }

class Glucoserecord {
  final String id;
  final String userId;
  final double glucoseLevel;
  final DateTime timeStamp;
  final GlucoseCondition condition;
  final bool isFromIoT;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Glucoserecord({
    required this.id,
    required this.userId,
    required this.glucoseLevel,
    required this.timeStamp,
    required this.condition,
    this.isFromIoT = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'glucose_level': glucoseLevel,
      'timestamp': timeStamp.toIso8601String(),
      'condition': condition == GlucoseCondition.beforeMeal ? 'beforeMeal' : 'afterMeal',
      'is_from_iot': isFromIoT,
    };
  }

  factory Glucoserecord.fromMap(Map<String, dynamic> map) {
    return Glucoserecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      glucoseLevel: (map['glucose_level'] as num).toDouble(),
      timeStamp: DateTime.parse(map['timestamp'] as String),
      condition: map['condition'] == 'beforeMeal' 
          ? GlucoseCondition.beforeMeal 
          : GlucoseCondition.afterMeal,
      isFromIoT: map['is_from_iot'] as bool? ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }

  Glucoserecord copyWith({
    String? id,
    String? userId,
    double? glucoseLevel,
    DateTime? timeStamp,
    GlucoseCondition? condition,
    bool? isFromIoT,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Glucoserecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      glucoseLevel: glucoseLevel ?? this.glucoseLevel,
      timeStamp: timeStamp ?? this.timeStamp,
      condition: condition ?? this.condition,
      isFromIoT: isFromIoT ?? this.isFromIoT,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}