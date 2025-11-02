import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/task_history.dart';
import 'package:smartreminders/services/api_service.dart';

class TaskService {
  final apiClient = ApiClient();

  Future<void> createTask(Task task) async {
    // Firestore integration disabled for local build - no-op implementation.
    var testTask = {
      "title": "Test 10",
      "description":"This is a location test from flutter app",
      "status":"PENDING",
      "profile":"HOME",
      "trigger":{
        "type":"LOCATION",
        "longitude":21.2255,
        "latitude": 45.7200,
        "radius": 50.0,
        "onEnter":true
      }
    };
    await apiClient.post('/api/task', testTask);
    return Future.value();
  }

  Future<void> updateTask(Task task) async {
    // Firestore integration disabled for local build - no-op implementation.
    return Future.value();
  }

  Future<void> deleteTask(String taskId) async {
    // Firestore integration disabled for local build - no-op implementation.
    return Future.value();
  }

  Stream<List<Task>> getActiveTasks(String userId, {TaskCategory? category}) {
    // return empty stream by default
    return Stream.value(apiClient.get("/api/task") as List<Task>);
  }

  Future<void> completeTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: now,
      isSnoozed: false,
    );
    await updateTask(updatedTask);
    await _addTaskHistory(task.id, task.title, HistoryAction.completed);
  }

  Future<void> snoozeTask(Task task, DateTime snoozeUntil) async {
    final updatedTask = task.copyWith(
      isSnoozed: true,
      snoozeUntil: snoozeUntil,
    );
    await updateTask(updatedTask);
    await _addTaskHistory(task.id, task.title, HistoryAction.snoozed);
  }

  Future<void> _addTaskHistory(String taskId, String taskTitle, HistoryAction action) async {
    // Firestore integration disabled - no-op for history.
    return Future.value();
  }

  Stream<List<TaskHistory>> getTaskHistory(String userId) {
    return Stream.value(<TaskHistory>[]);
  }
}
