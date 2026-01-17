import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:glucotrack_app/services/ReminderRepository.dart';

import 'package:flutter_timezone/flutter_timezone.dart';

/// Service for scheduling and managing local glucose reminder notifications
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final ReminderRepository _repository = ReminderRepository();

  bool _isInitialized = false;

  /// Initialize notification service and timezone data
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();
    
    // Get device timezone
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      print('✅ Device timezone: $timeZoneName');
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('❌ Failed to get device timezone: $e');
      // Fallback to UTC or a default if needed, but tz.local is default
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      
      // Explicitly check/request exact alarm permission
      final bool? canSchedule = await androidPlugin.canScheduleExactNotifications();
      if (canSchedule == false) {
          await androidPlugin.requestExactAlarmsPermission();
      }
    }

    _isInitialized = true;
    print('✅ ReminderService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('📱 Reminder notification tapped');
    // TODO: Navigate to glucose measurement page
    // This will be implemented when integrating with navigation
  }

  /// Schedule a single reminder
  Future<void> scheduleReminder({
    required String reminderId,
    required DateTime time,
    required List<int> daysOfWeek,
    String title = 'Glucose Reminder',
    String body = 'Time to check your blood glucose level',
  }) async {
    await initialize();

    // Cancel any existing schedules for this reminder first
    await cancelReminder(reminderId);

    // Schedule for each selected day
    for (int day in daysOfWeek) {
      final notificationId = _generateNotificationId(reminderId, day);
      
      // Calculate next occurrence for this day
      final scheduledDate = _getNextOccurrence(time, day);
      
      try {
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        print('✅ Scheduled reminder for day $day at ${time.hour}:${time.minute}');
      } catch (e) {
        print('❌ Error scheduling reminder for day $day: $e');
        // Don't rethrow immediately so other days might succeed, but valid concern
        throw e; 
      }
    }
  }

  /// Get notification details configuration
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'glucose_reminder_v2',
        'Glucose Reminders',
        channelDescription: 'Scheduled reminders for glucose measurement',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        // Make it ring continuously like an alarm
        additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive, // iOS 15+
      ),
    );
  }

  /// Calculate next occurrence of reminder for given day and time
  tz.TZDateTime _getNextOccurrence(DateTime time, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If scheduled time is in the past, add 1 day until it's future
    // Or if it's not the right day of week
    while (scheduledDate.weekday % 7 != dayOfWeek || scheduledDate.isBefore(now)) {
      // If today is the day, but time passed, move to next week
      if (scheduledDate.weekday % 7 == dayOfWeek && scheduledDate.isBefore(now)) {
         scheduledDate = scheduledDate.add(const Duration(days: 7));
      } else {
         scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }
    
    return scheduledDate;
  }

  /// Generate unique notification ID from reminder ID and day
  int _generateNotificationId(String reminderId, int day) {
    // Use hash code + day to create unique int ID
    // This allows us to cancel specific day schedules later
    return (reminderId.hashCode % 1000000) * 10 + day;
  }

  /// Cancel all scheduled notifications for a reminder
  Future<void> cancelReminder(String reminderId) async {
    await initialize();

    // Cancel for all possible days (0-6)
    for (int day = 0; day < 7; day++) {
      final notificationId = _generateNotificationId(reminderId, day);
      await _notifications.cancel(notificationId);
    }

    print('✅ Cancelled reminder: $reminderId');
  }

  /// Reschedule all active reminders (call on app start)
  Future<void> rescheduleAllReminders() async {
    try {
      await initialize();

      // Get all active reminders from database
      final reminders = await _repository.getActiveReminders();

      print('🔄 Rescheduling ${reminders.length} active reminders...');

      // Schedule each active reminder
      for (var reminder in reminders) {
        await scheduleReminder(
          reminderId: reminder.id,
          time: reminder.reminderTime,
          daysOfWeek: reminder.daysOfWeek,
          title: reminder.label,
          body: 'Waktunya cek gula darah Anda',
        );
      }

      print('✅ All reminders rescheduled');
    } catch (e) {
      print('❌ Error rescheduling reminders: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllReminders() async {
    await initialize();
    await _notifications.cancelAll();
    print('✅ All reminders cancelled');
  }

  /// Show a test notification immediately
  Future<void> showTestNotification() async {
    print('🚀 Testing notification...');
    try {
      await initialize();
      
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.areNotificationsEnabled();
        print('🔍 Permissions enabled: $granted');
        if (granted == false) {
           throw Exception('Permission NOT granted. Please enable notifications in Settings.');
        }

        // Check channels
        final channels = await androidImplementation.getNotificationChannels();
        print('📺 Active Channels: ${channels?.length}');
        channels?.forEach((c) {
          print('   - ID: ${c.id}, Name: ${c.name}, Importance: ${c.importance}');
        });
      }

      await _notifications.show(
        88888,
        'Tes Notifikasi GlucoTrack',
        'Jika Anda melihat ini, berarti notifikasi berjalan lancar! 🎉',
        _notificationDetails(),
      );
      print('✅ Test notification command sent');
    } catch (e) {
      print('❌ Error showing test notification: $e');
      throw e;
    }
  }

  /// Get list of pending scheduled notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await initialize();
    return await _notifications.pendingNotificationRequests();
  }
}
