import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/task_history.dart';

class TaskService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(Task task) async {
    // await _firestore.collection('tasks').doc(task.id).set(task.toJson());
    throw UnimplementedError();
  }

  Future<void> updateTask(Task task) async {
    // await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    throw UnimplementedError();
  }

  Future<void> deleteTask(String taskId) async {
    // await _firestore.collection('tasks').doc(taskId).delete();
    throw UnimplementedError();
  }

  Stream<List<Task>> getActiveTasks(String userId, {TaskCategory? category}) {
    // Query query = _firestore.collection('tasks')
    //     .where('userId', isEqualTo: userId)
    //     .where('isCompleted', isEqualTo: false)
    //     .orderBy('createdAt', descending: true);
    //
    // if (category != null && category != TaskCategory.all) {
    //   query = query.where('category', isEqualTo: category.name);
    // }
    //
    // return query.snapshots().map((snapshot) =>
    //     snapshot.docs.map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>)).toList());
    return Stream.fromIterable(List.empty());
    throw UnimplementedError();
  }

  Future<void> completeTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: now,
      isSnoozed: false,
      updatedAt: now,
    );
    await updateTask(updatedTask);
    await _addTaskHistory(task.id, task.userId, task.title, HistoryAction.completed);
  }

  Future<void> snoozeTask(Task task, DateTime snoozeUntil) async {
    final updatedTask = task.copyWith(
      isSnoozed: true,
      snoozeUntil: snoozeUntil,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
    await _addTaskHistory(task.id, task.userId, task.title, HistoryAction.snoozed);
  }

  Future<void> _addTaskHistory(String taskId, String userId, String taskTitle, HistoryAction action) async {
    // final history = TaskHistory(
    //   id: _firestore.collection('task_history').doc().id,
    //   taskId: taskId,
    //   userId: userId,
    //   taskTitle: taskTitle,
    //   action: action,
    //   timestamp: DateTime.now(),
    // );
    // await _firestore.collection('task_history').doc(history.id).set(history.toJson());
  }

  Stream<List<TaskHistory>> getTaskHistory(String userId) {
    // return _firestore.collection('task_history')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('timestamp', descending: true)
    //     .snapshots()
    //     .map((snapshot) =>
    //         snapshot.docs.map((doc) => TaskHistory.fromJson(doc.data())).toList());
    throw UnimplementedError();
  }
}
