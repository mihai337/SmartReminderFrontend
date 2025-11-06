import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartreminders/models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) {
      print('Notifications not fully supported on web');
      return;
    }
    
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _notifications.initialize(settings, onDidReceiveNotificationResponse: _onNotificationTap);
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      print('Failed to request notification permissions: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showTaskNotification(Task task) async {
    if (kIsWeb) {
      print('Showing notification: ${task.title}');
      return;
    }
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction('complete', 'Complete'),
          AndroidNotificationAction('snooze', 'Snooze'),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.show(
        task.id.hashCode,
        '📌 ${task.title}',
        task.description ?? 'Your reminder is ready',
        details,
        payload: task.id.toString(),
      );
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    try {
      await _notifications.cancel(id);
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Failed to cancel all notifications: $e');
    }
  }
}
