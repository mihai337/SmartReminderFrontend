import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { home, work, school, all }
enum TriggerType { location, time, wifi }
enum StateChange { enter, exit, connect, disconnect }

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskCategory category;
  final TriggerType triggerType;
  final Map<String, dynamic> triggerConfig;
  final StateChange? stateChange;
  final bool isCompleted;
  final bool isSnoozed;
  final DateTime? snoozeUntil;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.triggerType,
    required this.triggerConfig,
    this.stateChange,
    this.isCompleted = false,
    this.isSnoozed = false,
    this.snoozeUntil,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'category': category.name,
    'triggerType': triggerType.name,
    'triggerConfig': triggerConfig,
    'stateChange': stateChange?.name,
    'isCompleted': isCompleted,
    'isSnoozed': isSnoozed,
    'snoozeUntil': snoozeUntil != null ? Timestamp.fromDate(snoozeUntil!) : null,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    userId: json['userId'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    category: TaskCategory.values.firstWhere((e) => e.name == json['category']),
    triggerType: TriggerType.values.firstWhere((e) => e.name == json['triggerType']),
    triggerConfig: json['triggerConfig'] as Map<String, dynamic>,
    stateChange: json['stateChange'] != null ? StateChange.values.firstWhere((e) => e.name == json['stateChange']) : null,
    isCompleted: json['isCompleted'] as bool? ?? false,
    isSnoozed: json['isSnoozed'] as bool? ?? false,
    snoozeUntil: json['snoozeUntil'] != null ? (json['snoozeUntil'] as Timestamp).toDate() : null,
    completedAt: json['completedAt'] != null ? (json['completedAt'] as Timestamp).toDate() : null,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskCategory? category,
    TriggerType? triggerType,
    Map<String, dynamic>? triggerConfig,
    StateChange? stateChange,
    bool? isCompleted,
    bool? isSnoozed,
    DateTime? snoozeUntil,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    triggerType: triggerType ?? this.triggerType,
    triggerConfig: triggerConfig ?? this.triggerConfig,
    stateChange: stateChange ?? this.stateChange,
    isCompleted: isCompleted ?? this.isCompleted,
    isSnoozed: isSnoozed ?? this.isSnoozed,
    snoozeUntil: snoozeUntil ?? this.snoozeUntil,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
