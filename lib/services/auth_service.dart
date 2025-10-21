import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getMyProfile() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final rows = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .limit(1);

  return rows.isNotEmpty ? rows.first : null;
}


  //login user
  Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        password: password,
        email: email,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //register user

  Future<AuthResponse?> register({
  required String email,
  required String password,
  required String username,
}) async {
  try {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    return response;

  //   final user = response.user;
  //   if (user == null) return response;

  //   final payload = {
  //     'id': user.id,
  //     'email': email,
  //     'username': username.isEmpty ? '' : username,
  //     'updated_at': DateTime.now().toUtc().toIso8601String(),
  //   };

  //   try {
  //     await client.from('profiles').insert(payload);
  //   } on PostgrestException catch (e) {
  //     if (e.code == '23505') {
  //       await client
  //           .from('profiles')
  //           .update({
  //             'email': email,
  //             'username': username.isEmpty ? '' : username,
  //             'updated_at': DateTime.now().toUtc().toIso8601String(),
  //           })
  //           .eq('id', user.id);
  //     } else {
  //       rethrow;
  //     }
  //   }

  //   return response;
  // } on PostgrestException catch (e) {
  //   print('PostgREST ${e.code}: ${e.message}');
  //   return null;
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
    return null;
  } catch (e) {
    print('Unknown error: $e');
    return null;
  }
}

  //reset password via email
  Future<void> resetPassword(String email) async{
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e){
      throw Exception(e.message);
    }
  }

  //logout user
  Future<void> logout() async{
    await client.auth.signOut();
  }
}