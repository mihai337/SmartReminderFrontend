import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryAction { completed, snoozed, triggered }

class TaskHistory {
  final String id;
  final String taskId;
  final String userId;
  final String taskTitle;
  final HistoryAction action;
  final DateTime timestamp;

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.taskTitle,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'userId': userId,
    'taskTitle': taskTitle,
    'action': action.name,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory TaskHistory.fromJson(Map<String, dynamic> json) => TaskHistory(
    id: json['id'] as String,
    taskId: json['taskId'] as String,
    userId: json['userId'] as String,
    taskTitle: json['taskTitle'] as String,
    action: HistoryAction.values.firstWhere((e) => e.name == json['action']),
    timestamp: (json['timestamp'] as Timestamp).toDate(),
  );

  TaskHistory copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? taskTitle,
    HistoryAction? action,
    DateTime? timestamp,
  }) => TaskHistory(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    userId: userId ?? this.userId,
    taskTitle: taskTitle ?? this.taskTitle,
    action: action ?? this.action,
    timestamp: timestamp ?? this.timestamp,
  );
}
