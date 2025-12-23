import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client = Supabase.instance.client;
  
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  bool get isLoggedIn => client.auth.currentUser != null;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Login gagal: ${e.message}');
    }
  }
  
  Future<AuthResponse?> register({
    required String email,
    required String password,
    required String username,
    required DateTime birthDate,
    required int age,
    required String gender,
  }) async {
    try {
      print('🔹 Starting registration...');
      print('📧 Email: $email');
      print('👤 Username: $username');
      print('🎂 Birth Date: $birthDate');
      print('🔢 Age: $age');
      print('⚧ Gender: $gender');
      
      // Kirim data sebagai metadata agar bisa dipakai trigger
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'gender': gender,
          'birth_date': birthDate.toIso8601String(),
          'age': age,
        },
      );
      
      print('✅ Auth signup successful');
      
      final user = response.user;
      
      if (user != null) {
        print('👤 User created with ID: ${user.id}');
        
        // Double-check: Manual insert jika trigger tidak berjalan
        try {
          final existing = await client
              .from('profiles')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          
          print('🔍 Checking existing profile: $existing');
          
          if (existing == null) {
            print('📝 Inserting profile...');
            final profileData = {
              'id': user.id,
              'username': username,
              'email': email,
              'gender': gender,
              'birth_date': birthDate.toIso8601String(),
              'age': age,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            };
            
            print('📦 Profile data: $profileData');
            
            await client.from('profiles').insert(profileData);
            print('✅ Profile inserted successfully');
          } else {
            print('ℹ️ Profile already exists (created by trigger)');
          }
        } catch (profileError) {
          print('❌ Profile error: $profileError');
          print('❌ Profile error type: ${profileError.runtimeType}');
          // Cleanup: sign out jika profile gagal
          await client.auth.signOut();
          rethrow;
        }
      } else {
        print('⚠️ User is null after signup');
      }
      
      print('🎉 Registration completed successfully');
      return response;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      print('❌ AuthException code: ${e.statusCode}');
      throw Exception('Register gagal: ${e.message}');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      print('❌ PostgrestException code: ${e.code}');
      print('❌ PostgrestException details: ${e.details}');
      if (e.code == '23505') {
        throw Exception('Email atau username sudah terdaftar');
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ General error: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Register error: $e');
    }
  }
  
  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Reset password gagal: ${e.message}');
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = currentUser;
    if (user == null) {
      print('⚠️ No current user');
      return null;
    }
    try {
      final rows = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .limit(1);
      if (rows.isEmpty) {
        print('⚠️ Profile not found for user: ${user.id}');
        return null;
      }
      return rows.first;
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }
}