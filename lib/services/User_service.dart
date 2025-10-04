import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/User.dart';

class UserService {
  final SupabaseClient sb = Supabase.instance.client;
  String? get currentUserId => sb.auth.currentUser?.id;

  Future<bool> checkUserProfileExists(String uid) async {
    final response = await sb
        .from('users')
        .select('id')
        .eq('id', uid)
        .maybeSingle();
    return response != null;
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final response = await sb
        .from('users')
        .select('id, username, email, gender, birth_date, age')
        .eq('id', uid)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromMap(uid, response);
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    await sb
        .from('users')
        .upsert(profile.toMap());
  }

  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? email,
    Gender? gender,
    DateTime? birthDate,
    int? age,
  }) async {
    final payload = <String, dynamic>{};
    if (username != null) payload['username'] = username;
    if (email != null) payload['email'] = email;
    if (gender != null) payload['gender'] = gender.toShortString();
    if (birthDate != null) payload['birth_date'] = birthDate.toIso8601String();
    if (age != null) payload['age'] = age;

    if (payload.isEmpty) return;

    await sb.from('profiles')
      .update(payload)
      .eq('id', uid);
  }

 Future<UserProfile> ensureProfileForCurrentUser() async {
    final user = sb.auth.currentUser;
    if (user == null) {
      throw Exception('No current user/session');
    }

    final exists = await checkUserProfileExists(user.id);
    if (!exists) {
      final defaultUsername = (user.email ?? 'user').split('@').first;
      final profile = UserProfile(
        id: user.id,
        username: defaultUsername,
        email: user.email ?? '',
        gender: Gender.male,          // default
        birthDate: DateTime(2000,1,1),// default
        age: 0,                       // default
      );
      await saveUserProfile(profile);
      return profile;
    } else {
      final p = await getUserProfile(user.id);
      if (p == null) {
        throw Exception('Profile row not readable (RLS?)');
      }
      return p;
    }
  }
}