import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get notifications for current user with pagination
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select('*, actor:profiles!actor_id(username, avatar_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Create notification (for likes, comments, etc.)
  Future<String?> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? actorId,
    String? postId,
    String? commentId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Don't send notification to self
      if (actorId == userId) {
        print('Skipping notification: Actor is same as User (Self-notification)');
        return null; // Change this to allow self-notif for testing if needed
      }

      final notification = {
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'actor_id': actorId,
        'post_id': postId,
        'comment_id': commentId,
        'data': data,
      };

      final response = await _supabase
          .from('notifications')
          .insert(notification)
          .select('id')
          .single();

      final notificationId = response['id'] as String;
      
      // Send push notification if user has FCM token
      await _sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        data: {
          'notification_id': notificationId,
          'type': type,
          'post_id': postId ?? '',
          'comment_id': commentId ?? '',
        },
      );

      return notificationId;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  /// Send push notification via FCM
  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get user's FCM token
      final userProfile = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', userId)
          .single();

      final fcmToken = userProfile['fcm_token'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) {
        print('No FCM token for user $userId');
        return;
      }

      // Call Edge Function to send notification
      // TODO: Create Edge Function setelah ini
      print('📤 Would send push to token: $fcmToken');
      print('   Title: $title');
      print('   Body: $body');
      
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  /// Get notification settings for current user
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // If no settings exist, create default settings
      if (response == null) {
        await _supabase.from('notification_settings').insert({
          'user_id': userId,
        });
        return await getSettings();
      }

      return response;
    } catch (e) {
      print('Error getting notification settings: $e');
      return null;
    }
  }

  /// Update notification settings
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notification_settings')
          .upsert({
            'user_id': userId,
            ...settings,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
