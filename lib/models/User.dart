enum Gender {
  male,
  female;

  static Gender fromString(String genderStr) {
    return genderStr.toLowerCase() == 'female' ? Gender.female : Gender.male;
  }

  String toShortString() {
    return this == Gender.female ? 'female' : 'male';
  }
}


class UserProfile {
  final String uid;
  final String username;
  final String email;
  final Gender gender;
  final DateTime birthDate;
  final int age;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'gender': gender.toShortString(),
      'birthDate': birthDate.toIso8601String(),
      'age': age,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map){
    return UserProfile(
      uid:uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      gender: Gender.fromString(map['gender'] ?? 'male'),
      birthDate: DateTime.parse(map['birthDate']),
      age: map['age'] ?? 0,
    );
  }
}

