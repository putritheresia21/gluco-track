import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient client = Supabase.instance.client;

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
  Future<AuthResponse?> register({required String email, required String password, required String username}) async{
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (response.session != null && response.user != null) {
        await client.from('profiles').insert({
          'id': response.user!.id,
          'username': username,
        });
      }
      return response;
    } on PostgrestException catch (e){
        print("Auth error: ${e.message}");
    } on AuthException catch (e){
      print("Auth error: ${e.message}");
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