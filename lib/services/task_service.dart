import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/task_history.dart';
import 'package:smartreminders/services/api_service.dart';

class TaskService {
  /// Use ApiClient (defined in api_service.dart) which performs HTTP requests
  TaskService() : _api = ApiClient();

  final ApiClient _api;

  Future<void> createTask(Task task) async {

    // var testTask = {
    //   "title": "Test 10",
    //   "description":"This is a location test from flutter app",
    //   "status":"PENDING",
    //   "profile":"HOME",
    //   "trigger":{
    //     "type":"LOCATION",
    //     "longitude":21.2255,
    //     "latitude": 45.7200,
    //     "radius": 50.0,
    //     "onEnter":true
    //   }
    // };

    if(task.trigger is TimeTrigger){
      debugPrint((task.trigger as TimeTrigger).time.toString());
    }

    try {
      final resp = await _api.post('/api/task', task.toJson());
      //printToConsole(task.toJson().toString());
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Create task failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final id = task.id;
      final resp = await _api.put('/api/task/$id', task.toJson());
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Update task failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final resp = await _api.delete('/api/task/$taskId');
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Delete task failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Task>> getActiveTasks(String userId, { TaskProfile? profile}) async* {
    try {
      final resp = await _api.get('/api/task');
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        yield <Task>[];
        return;
      }

      final decoded = json.decode(resp.body);
      List<dynamic> list = [];
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List<dynamic>;
      }

      final tasks = list.map((e) {
        final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
        return Task.fromJson(map);
      }).toList();

      yield tasks;
    } catch (e) {
      // On error, yield empty list rather than streaming an exception
      yield <Task>[];
    }
  }

  Future<void> completeTask(Task task) async {
    // mark completed and send update to backend
    // final updated = task.copyWith(status: TaskStatus.COMPLETED);
    // await updateTask(updated);
    // await _addTaskHistory(task.id, task.title, HistoryAction.completed);
  }

  // Future<void> snoozeTask(Task task, DateTime snoozeUntil) async {
  //   // backend may handle snooze differently; here we attach snooze info in triggerConfig
  //   final newConfig = Map<String, dynamic>.from(task.triggerConfig);
  //   newConfig['snoozeUntil'] = snoozeUntil.toIso8601String();
  //   final updated = task.copyWith(triggerConfig: newConfig);
  //   await updateTask(updated);
  //   await _addTaskHistory(task.id, task.title, HistoryAction.snoozed);
  // }

  Future<void> _addTaskHistory(String taskId, String taskTitle, HistoryAction action) async {
    // no-op: keep local history disabled
    return Future.value();
  }

  Stream<List<TaskHistory>> getTaskHistory(String userId) {
    return Stream.value(<TaskHistory>[]);
  }
}
