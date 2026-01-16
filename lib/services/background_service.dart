import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workmanager/workmanager.dart';
import 'package:smartreminders/services/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize notification service
      await NotificationService().initialize();
      
      // Check for triggered tasks based on location, time, or WiFi
      // This would typically query Firestore for active tasks and check their conditions
      print('Background task executed: $task');
      
      return Future.value(true);
    } catch (e) {
      print('Error in background task: $e');
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      print('Background service not supported on web');
      return;
    }
    try {
      // `isInDebugMode` is deprecated. Use Workmanager's debug handlers if needed.
      await Workmanager().initialize(callbackDispatcher);
    } catch (e) {
      print('Failed to initialize background service: $e');
    }
  }

  static Future<void> registerPeriodicTask({int frequencyMinutes = 15}) async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerPeriodicTask(
        'task_checker',
        'checkTaskTriggers',
        frequency: Duration(minutes: frequencyMinutes),
        constraints: Constraints(
          // TODO: check is network is required
          networkType: NetworkType.notRequired,
        ),
      );
    } catch (e) {
      print('Failed to register periodic task: $e');
    }
  }

  static Future<void> cancelAllTasks() async {
    if (kIsWeb) return;
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      print('Failed to cancel tasks: $e');
    }
  }
}
