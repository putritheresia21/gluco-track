import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/User.dart';

class UserService {
  final SupabaseClient sb = Supabase.instance.client;
  
  String? get currentUserId => sb.auth.currentUser?.id;

  // ============ PROFILE CRUD ============
  
  Future<bool> checkUserProfileExists(String uid) async {
    try {
      final response = await sb
          .from('profiles')  
          .select('id')
          .eq('id', uid)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('❌ Error checking profile: $e');
      return false;
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final response = await sb
          .from('profiles')  
          .select('id, username, email, gender, birth_date, age, avatar_url')
          .eq('id', uid)
          .maybeSingle();
      
      if (response == null) {
        print('⚠️ Profile not found for uid: $uid');
        return null;
      }
      
      return UserProfile.fromMap(uid, response);
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await sb
          .from('profiles')  
          .upsert(profile.toMap());
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? email,
    Gender? gender,
    DateTime? birthDate,
    int? age,
    String? avatarUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      
      if (username != null) payload['username'] = username;
      if (email != null) payload['email'] = email;
      if (gender != null) payload['gender'] = gender.toShortString();
      if (birthDate != null) payload['birth_date'] = birthDate.toIso8601String();
      if (age != null) payload['age'] = age;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;

      if (payload.length <= 1) {
        print('⚠️ No fields to update');
        return;
      }

      await sb
          .from('profiles')  
          .update(payload)
          .eq('id', uid);
      
    } catch (e) {
      rethrow;
    }
  }
  
  Future<UserProfile> ensureProfileForCurrentUser() async {
    final user = sb.auth.currentUser;
    if (user == null) {
      throw Exception('No current user/session');
    }

    final exists = await checkUserProfileExists(user.id);
    
    if (!exists) {
      print('Profile not found, creating default profile...');
      
      final defaultUsername = (user.email ?? 'user').split('@').first;
      final profile = UserProfile(
        id: user.id,
        username: defaultUsername,
        email: user.email ?? '',
        gender: Gender.male,
        birthDate: DateTime(2000, 1, 1),
        age: 0,
      );
      
      await saveUserProfile(profile);
      print('Default profile created');
      return profile;
    } else {
      final p = await getUserProfile(user.id);
      if (p == null) {
        throw Exception('Profile row not readable (check RLS policies)');
      }
      return p;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) {
      print('No current user logged in');
      return null;
    }
    
    return await getUserProfile(userId);
  }

  Future<bool> deleteUserProfile(String uid) async {
    try {
      await sb
          .from('profiles')  
          .delete()
          .eq('id', uid);
      
      print('Profile deleted: $uid');
      return true;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }

  // ============ AVATAR METHODS ============

  /// Upload avatar dan update profile
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = sb.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final userId = user.id;
      
      // Delete old avatar first
      await _deleteOldAvatar(userId);

      // Generate unique filename
      final ext = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = 'avatars/$fileName';

      print('🔼 Uploading avatar to $path');

      // Upload to storage
      await sb.storage.from('avatars').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = sb.storage.from('avatars').getPublicUrl(path);

      print('✅ Avatar uploaded: $publicUrl');

      // Update profiles table
      await updateUserProfile(uid: userId, avatarUrl: publicUrl);

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete avatar from storage and profile
  Future<void> deleteAvatar() async {
    try {
      final user = sb.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final userId = user.id;

      // Delete from storage
      await _deleteOldAvatar(userId);

      // Update profile to null
      await updateUserProfile(uid: userId, avatarUrl: '');

      print('✅ Avatar deleted');
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Get current user's avatar URL
  Future<String?> getCurrentAvatarUrl() async {
    try {
      final user = sb.auth.currentUser;
      if (user == null) return null;

      final profile = await sb
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .single();

      return profile['avatar_url'] as String?;
    } catch (e) {
      print('❌ Error getting avatar URL: $e');
      return null;
    }
  }

  /// Helper: Delete old avatar from storage
  Future<void> _deleteOldAvatar(String userId) async {
    try {
      // Get current avatar URL
      final profile = await sb
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) return;

      final avatarUrl = profile['avatar_url'] as String?;

      if (avatarUrl == null || avatarUrl.isEmpty) {
        print('⚠️ No old avatar to delete');
        return;
      }

      // Extract filename from URL
      final uri = Uri.parse(avatarUrl);
      final segments = uri.pathSegments;
      
      // Find 'avatars' segment and get the filename after it
      final avatarIndex = segments.indexOf('avatars');
      if (avatarIndex != -1 && avatarIndex < segments.length - 1) {
        final fileName = segments[avatarIndex + 1];
        final path = 'avatars/$fileName';

        print('🗑️ Deleting old avatar at $path');

        await sb.storage.from('avatars').remove([path]);
        
        print('✅ Old avatar deleted');
      }
    } catch (e) {
      print('⚠️ Error deleting old avatar: $e');
      // Don't throw, just log - old avatar might not exist
    }
  }

  /// Validate image file
  bool validateAvatarFile(File file) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxSize) {
      print('❌ File too large: ${fileSize / 1024 / 1024}MB');
      return false;
    }

    // Check extension
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      print('❌ Invalid file type: $ext');
      return false;
    }

    return true;
  }
}