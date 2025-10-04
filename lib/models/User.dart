enum Gender {
  male,
  female;

  static Gender fromString(String? genderStr) {
    if (genderStr == null) return Gender.male;
    return genderStr.toLowerCase() == 'female' ? Gender.female : Gender.male;
  }

  String toShortString() {
    return this == Gender.female ? 'female' : 'male';
  }
}


class UserProfile {
  final String id;
  final String username;
  final String email;
  final Gender gender;
  final DateTime birthDate;
  final int age;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'gender': gender.toShortString(),
      'birth_date': birthDate.toIso8601String(),
      'age': age,
    };
  }

  factory UserProfile.fromMap(String id, Map<String, dynamic> map){
    return UserProfile(
      id:map['id'] ?? id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      gender: Gender.fromString(map['gender']),
      birthDate: DateTime.parse(map['birth_date'] ?? ''),
      age: map['age'] ?? 0,
    );
  }
}

