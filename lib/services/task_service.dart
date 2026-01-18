import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:smartreminders/models/observer.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/task_history.dart';
import 'package:smartreminders/services/api_service.dart';

class TaskService implements TaskObservable {

  TaskService.internal() : _api = ApiClient(), _observers = [];
  static final TaskService _instance = TaskService.internal();
  factory TaskService() => _instance;

  final ApiClient _api;
  final List<TaskObserver> _observers;
  final _controller = BehaviorSubject<List<Task>>();

  Stream<List<Task>> get taskStream => _controller.stream;

  Future<void> createTask(Task task) async {
    try {
      final resp = await _api.post('/api/task', task.toJson());
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Create task failed: ${resp.statusCode} ${resp.body}');
      }
      notifyObservers();
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
      notifyObservers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final resp = await _api.delete('/api/task/$taskId');
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Delete task failed: ${resp.statusCode} ${resp.body}');
      }
      notifyObservers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadTasks({ TaskProfile? profile}) async {
    try {
      final resp = await _api.get('/api/task');
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        _controller.add(<Task>[]);
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

      if(profile != null){
        final filtered = tasks.where((task) => task.profile == profile).toList();
        _controller.add(filtered);
        return;
      }

      _controller.add(tasks);
    } catch (e) {
      // On error, stream empty list rather than streaming an exception
      _controller.add(<Task>[]);
    }
  }

  Future<void> completeTask(Task task) async {
    final updated = task.copyWith(status: TaskStatus.COMPLETED);
    await updateTask(updated);
  }

  // Future<void> snoozeTask(Task task, DateTime snoozeUntil) async {
  //   // backend may handle snooze differently; here we attach snooze info in triggerConfig
  //   final newConfig = Map<String, dynamic>.from(task.triggerConfig);
  //   newConfig['snoozeUntil'] = snoozeUntil.toIso8601String();
  //   final updated = task.copyWith(triggerConfig: newConfig);
  //   await updateTask(updated);
  //   await _addTaskHistory(task.id, task.title, HistoryAction.snoozed);
  // }

  Stream<List<TaskHistory>> getTaskHistory() async* {
    try {
      final resp = await _api.get('/api/task/history');
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        yield <TaskHistory>[];
        return;
      }

      final decoded = json.decode(resp.body);
      List<dynamic> list = [];
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List<dynamic>;
      }

      final history = list.map((e) {
        // TODO : fix timestamp
        var task = TaskHistory(taskId: e["id"], taskTitle: e["title"], action: HistoryAction.completed, timestamp: DateTime.now());
        return task;
      }).toList();


      yield history;
    } catch (e) {
      yield <TaskHistory>[];
    }
  }

  @override
  void registerObserver(TaskObserver observer) {
    _observers.add(observer);
  }

  @override
  void removeObserver(TaskObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notifyObservers() {
    for (var observer in _observers) {
      observer.update();
    }
  }
}
