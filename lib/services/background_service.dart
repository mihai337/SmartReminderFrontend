import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:geolocator/geolocator.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:smartreminders/services/notification_service.dart';

import '../models/task.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationService().initialize();

      try {
        // TODO: Store Firebase config securely
        FirebaseOptions options = const FirebaseOptions(
            apiKey: "AIzaSyBSqwhR1UbNxDVJr9uDfjW7bTjDT6xmP5o",
            appId: "1:482369567349:web:3d99d42764e0504f2b963c",
            messagingSenderId: "482369567349",
            projectId: "482369567349"
        );
        await Firebase.initializeApp(options: options);
      } catch (e) {
        debugPrint('Firebase initialization error: $e');
      }

      final taskService = TaskService();

      switch (task) {
        case 'update_location_by_distance_filter':
            var tasks = await taskService.taskStream.first;

            final position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0, // meters
            ));

            for (final task in tasks) {
              if (task.trigger is! LocationTrigger) continue;

              final trigger = task.trigger as LocationTrigger;

              final distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                trigger.latitude,
                trigger.longitude,
              );

              final insideRadius = distance <= trigger.radius;

              if (insideRadius) {
                await NotificationService().showTaskNotification(task);
              }
            }
          break;
        default:
          debugPrint('No handler for task: $task');
      }
      
      return Future.value(true);
    } catch (e) {
      debugPrint('Error in background task: $e');
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Background service not supported on web');
      return;
    }
    try {
      // `isInDebugMode` is deprecated. Use Workmanager's debug handlers if needed.
      await Workmanager().initialize(callbackDispatcher);
    } catch (e) {
      debugPrint('Failed to initialize background service: $e');
    }
  }

  static Future<void> registerPeriodicTask(String taskUniqueName, {int frequencyMinutes = 15}) async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerPeriodicTask(
        taskUniqueName,
        taskUniqueName,
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

  static Future<void> registerOneOffTask(String taskUniqueName, {Duration? initialDelay}) async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerOneOffTask(
        taskUniqueName,
        taskUniqueName,
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );
    } catch (e) {
      debugPrint('Failed to register one-off task: $e');
    }
  }

  static Future<void> cancelTask(String taskUniqueName) async {
    if (kIsWeb) return;
    try {
      await Workmanager().cancelByUniqueName(taskUniqueName);
    } catch (e) {
      debugPrint('Failed to cancel task $taskUniqueName: $e');
    }
  }

  static Future<void> cancelAllTasks() async {
    if (kIsWeb) return;
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel tasks: $e');
    }
  }
}
