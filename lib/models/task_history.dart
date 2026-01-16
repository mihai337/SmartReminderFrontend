import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryAction { completed, snoozed, triggered }

class TaskHistory {
  final int taskId;
  final String taskTitle;
  final HistoryAction action;
  final DateTime timestamp;

  TaskHistory({
    required this.taskId,
    required this.taskTitle,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'taskTitle': taskTitle,
    'action': action.name,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory TaskHistory.fromJson(Map<String, dynamic> json) => TaskHistory(
    taskId: json['taskId'] as int,
    taskTitle: json['taskTitle'] as String,
    action: HistoryAction.values.firstWhere((e) => e.name == json['action']),
    timestamp: (json['timestamp'] as Timestamp).toDate(),
  );

  TaskHistory copyWith({
    int? taskId,
    String? taskTitle,
    HistoryAction? action,
    DateTime? timestamp,
  }) => TaskHistory(
    taskId: taskId ?? this.taskId,
    taskTitle: taskTitle ?? this.taskTitle,
    action: action ?? this.action,
    timestamp: timestamp ?? this.timestamp,
  );
}
