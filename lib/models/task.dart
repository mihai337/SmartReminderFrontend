import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { home, work, school, all }
enum TriggerType { location, time, wifi }
enum StateChange { enter, exit, connect, disconnect }

// Backend enums from Java
enum TaskProfile { HOME, WORK, SCHOOL }
enum TaskStatus { PENDING, COMPLETED, CANCELLED }

/// Polymorphic Trigger base class. Backend uses a 'type' discriminator
/// with names like "TIME" and "LOCATION". We mirror that here.
abstract class Trigger {
  final int? id;
  final bool triggered;
  final bool onEnter;

  Trigger({this.id, this.triggered = false, this.onEnter = false});

  String get typeName;

  Map<String, dynamic> toJson();

  static Trigger? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final type = json['type'] as String?;
    if (type == null) return null;
    switch (type) {
      case 'TIME':
        return TimeTrigger.fromJson(json);
      case 'LOCATION':
        return LocationTrigger.fromJson(json);
      default:
        return null;
    }
  }
}

class TimeTrigger extends Trigger {
  final DateTime? dateTime;

  TimeTrigger({int? id, bool triggered = false, bool onEnter = false, this.dateTime}) : super(id: id, triggered: triggered, onEnter: onEnter);

  @override
  String get typeName => 'TIME';

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    'id': id,
    'triggered': triggered,
    'onEnter': onEnter,
    'dateTime': dateTime?.toIso8601String(),
  };

  static TimeTrigger fromJson(Map<String, dynamic> json) => TimeTrigger(
    id: json['id'] is int ? json['id'] as int : (json['id'] is num ? (json['id'] as num).toInt() : null),
    triggered: json['triggered'] as bool? ?? false,
    onEnter: json['onEnter'] as bool? ?? false,
    dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime'] as String) : null,
  );
}

class LocationTrigger extends Trigger {
  final double? latitude;
  final double? longitude;
  final double? radius;

  LocationTrigger({int? id, bool triggered = false, bool onEnter = false, this.latitude, this.longitude, this.radius}) : super(id: id, triggered: triggered, onEnter: onEnter);

  @override
  String get typeName => 'LOCATION';

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    'id': id,
    'triggered': triggered,
    'onEnter': onEnter,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
  };

  static LocationTrigger fromJson(Map<String, dynamic> json) => LocationTrigger(
    id: json['id'] is int ? json['id'] as int : (json['id'] is num ? (json['id'] as num).toInt() : null),
    triggered: json['triggered'] as bool? ?? false,
    onEnter: json['onEnter'] as bool? ?? false,
    latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    radius: json['radius'] != null ? (json['radius'] as num).toDouble() : null,
  );
}

class Task {
  final String id;
  final String title;
  final String? description;

  // Backend fields
  final TaskStatus status;
  final TaskProfile? profile;
  final Trigger? trigger; // polymorphic trigger

  // UI / app fields (kept for backward compatibility)
  final TaskCategory category;
  final TriggerType triggerType;
  final Map<String, dynamic> triggerConfig;
  final StateChange? stateChange;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.PENDING,
    this.profile,
    this.trigger,
    this.category = TaskCategory.home,
    this.triggerType = TriggerType.time,
    this.triggerConfig = const {},
    this.stateChange,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.name,
    'profile': profile?.name,
    'trigger': trigger?.toJson(),
    // keep legacy fields for backward compatibility
    'category': category.name,
    'triggerType': triggerType.name,
    'triggerConfig': triggerConfig,
    'stateChange': stateChange?.name,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    status: json['status'] != null ? TaskStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => TaskStatus.PENDING) : TaskStatus.PENDING,
    profile: json['profile'] != null ? TaskProfile.values.firstWhere((e) => e.name == json['profile'], orElse: () => TaskProfile.HOME) : null,
    trigger: Trigger.fromJson(json['trigger'] as Map<String, dynamic>?),
    category: json['category'] != null ? TaskCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => TaskCategory.home) : TaskCategory.home,
    triggerType: json['triggerType'] != null ? TriggerType.values.firstWhere((e) => e.name == json['triggerType'], orElse: () => TriggerType.time) : TriggerType.time,
    triggerConfig: json['triggerConfig'] is Map<String, dynamic> ? json['triggerConfig'] as Map<String, dynamic> : <String, dynamic>{},
    stateChange: json['stateChange'] != null ? StateChange.values.firstWhere((e) => e.name == json['stateChange']) : null,
  );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskProfile? profile,
    Trigger? trigger,
    TaskCategory? category,
    TriggerType? triggerType,
    Map<String, dynamic>? triggerConfig,
    StateChange? stateChange,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    profile: profile ?? this.profile,
    trigger: trigger ?? this.trigger,
    category: category ?? this.category,
    triggerType: triggerType ?? this.triggerType,
    triggerConfig: triggerConfig ?? this.triggerConfig,
    stateChange: stateChange ?? this.stateChange,
  );
}