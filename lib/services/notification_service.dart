import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartreminders/models/task.dart';
import 'dart:io' show Platform;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



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
    tz.initializeTimeZones();
    
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

  Future<void> scheduleTaskAtDueTime(Task task) async {
    if (kIsWeb) return;
    if (task.trigger is! TimeTrigger) return;

    final due = (task.trigger as TimeTrigger).time;
    debugPrint('Got here 1');

    bool isExactAlarmPermitted = true;
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
      isExactAlarmPermitted = await androidPlugin?.canScheduleExactNotifications() ?? false;
    }

    // Do not schedule in the past
    if (due.isBefore(DateTime.now().toLocal())) return;

    debugPrint('Got here 2');

    // on emulator tz.local is 2 hours behind
    final scheduled = tz.TZDateTime.from(due, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
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

    try {
      // Try exact alarm (best accuracy)
      debugPrint('Got here 3');
      debugPrint('$scheduled');
      await _notifications.zonedSchedule(
        task.id.hashCode,
        '📌 ${task.title}',
        task.description ?? 'Your reminder is ready',
        scheduled,
        details,
        payload: task.id.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Got here 4');
    } on PlatformException catch (e) {
      debugPrint('Got here 5');
      if (e.code == 'exact_alarms_not_permitted') {
        // Fallback when exact alarms are not allowed
        debugPrint('Exact alarms not permitted, scheduling inexact alarm');
        await _notifications.zonedSchedule(
          task.id.hashCode,
          '📌 ${task.title}',
          task.description ?? 'Your reminder is ready',
          scheduled,
          details,
          payload: task.id.toString(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        debugPrint('Got here 6');
      } else {
        rethrow;
      }
    }
  }


}
