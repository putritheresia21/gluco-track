import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:glucotrack_app/utils/NavigationHelper.dart';
import 'package:glucotrack_app/pages/NavbarItem/GlucoseChartPage.dart' show GlucoseChart;
import 'package:glucotrack_app/pages/ReportsPage.dart';
import 'package:glucotrack_app/pages/NotificationListPage.dart';

// Background message handler (TOP-LEVEL function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging & Local Notifications
  Future<void> initialize() async {
    try {
      // Initialize timezone for scheduling
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      print('🔔 FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _saveTokenToServer(_fcmToken!);
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveTokenToServer);

      // Setup message handlers
      _setupMessageHandlers();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print('✅ Notification Service initialized');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Notification permission provisional');
    } else {
      print('❌ Notification permission denied');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'glucotrack_urgent_v3', // Force NEW Channel (V3)
      'GlucoTrack Urgent',
      description: 'Urgent notifications for GlucoTrack',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // When user taps notification (app opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notification tapped (background): ${message.data}');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a notification (app was terminated)
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App opened from notification (terminated): ${message.data}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    print('🔔 Attempting to show local notification...');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'glucotrack_urgent_v3', // Match V3
      'GlucoTrack Urgent',
      channelDescription: 'Urgent notifications for GlucoTrack',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      visibility: NotificationVisibility.public,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'GlucoTrack',
        message.notification?.body ?? 'New notification',
        details,
        payload: message.data.toString(),
      );
      print('✅ Local notification request sent to OS');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Local notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      _navigateFromPayload(response.payload!);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final postId = data['post_id']?.toString();
    final commentId = data['comment_id']?.toString();
    
    print('🔔 Handling notification tap - Type: $type, PostId: $postId');
    
    // Delayed navigation to ensure app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      _navigateByType(type, postId: postId, commentId: commentId);
    });
  }

  void _navigateFromPayload(String payload) {
    // Parse payload format: "type:value|post_id:value"
    final Map<String, String> data = {};
    for (var part in payload.split('|')) {
      final kv = part.split(':');
      if (kv.length == 2) {
        data[kv[0]] = kv[1];
      }
    }
    
    final type = data['type'] ?? '';
    final postId = data['post_id'];
    
    _navigateByType(type, postId: postId);
  }

  void _navigateByType(String type, {String? postId, String? commentId}) {
    // Import navigation helper at runtime
    switch (type.toLowerCase()) {
      case 'like':
      case 'comment':
        // Navigate to post detail
        if (postId != null) {
          _navigateToPost(postId);
        }
        break;
      case 'follow':
        // Navigate to profile - will be handled by the app
        print('Navigate to follower profile');
        break;
      case 'reminder':
      case 'glucose_reminder':
        // Navigate to glucose chart/input page
        _navigateToGlucoseInput();
        break;
      case 'report':
        // Navigate to reports page
        _navigateToReports();
        break;
      default:
        // Navigate to notification list
        _navigateToNotifications();
    }
  }

  void _navigateToPost(String postId) {
    print('📍 Navigating to post: $postId');
    // Navigate to social feed - the post will be highlighted
    // For now, just go to social feed
    // TODO: Implement deep linking to specific post
  }

  void _navigateToGlucoseInput() {
    print('📍 Navigating to glucose chart');
    navigateTo(const GlucoseChart());
  }

  void _navigateToReports() {
    print('📍 Navigating to reports');
    navigateTo(const ReportsPage());
  }

  void _navigateToNotifications() {
    print('📍 Navigating to notifications');
    navigateTo(const NotificationListPage());
  }

  /// Public method to ensure token is saved (call this after login)
  Future<void> ensureTokenSaved() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToServer(token);
    }
  }

  /// Save FCM token to Supabase
  Future<void> _saveTokenToServer(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ Cannot save FCM token: User not logged in');
        return;
      }

      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);

      print('✅ FCM token saved to server for user $userId');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Schedule glucose reminder
  Future<void> scheduleGlucoseReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'glucotrack_reminders',
        'Glucose Reminders',
        channelDescription: 'Reminders to measure blood glucose',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Glucose reminder scheduled for $scheduledTime');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  /// Cancel reminder
  Future<void> cancelReminder(int id) async {
    await _localNotifications.cancel(id);
    print('✅ Reminder $id canceled');
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
    print('✅ All reminders canceled');
  }

  /// Show a custom local notification (for reports, etc.)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    const androidDetails = AndroidNotificationDetails(
      'glucotrack_general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
    );
    print('📣 Local notification shown: $title');
  }
  
}
