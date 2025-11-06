enum TriggerType { location, time, wifi }

// Backend enums from Java
enum TaskProfile { HOME, WORK, SCHOOL }
enum TaskStatus { PENDING, COMPLETED, CANCELLED }
enum StateChange {
  enter,      // for location
  exit,       // for location
  connect,    // for wifi
  disconnect  // for wifi
}


/// Polymorphic Trigger base class. Backend uses a 'type' discriminator
/// with names like "TIME" and "LOCATION". We mirror that here.
abstract class Trigger {
  final int? id;
  final bool triggered;
  final bool onEnter;
  String get type;

  Trigger({this.id, this.triggered = false, this.onEnter = false});

  Map<String, dynamic> toJson();

  static Trigger fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('Trigger data cannot be null');
    final type = json['type'] as String?;
    if (type == null) throw ArgumentError('Trigger type cannot be null');

    switch (type) {
      case 'TIME':
        return TimeTrigger.fromJson(json);
      case 'LOCATION':
        return LocationTrigger.fromJson(json);
      default:
        throw ArgumentError('Unknown trigger type: $type');
    }
  }
}

class TimeTrigger extends Trigger {
  final DateTime time;

  TimeTrigger({int? id, bool triggered = false, bool onEnter = false, required this.time}) : super(id: id, triggered: triggered, onEnter: onEnter);

  @override
  String get type => 'TIME';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'triggered': triggered,
    'onEnter': onEnter,
    'time': time.toUtc().toIso8601String(),
  };

  static TimeTrigger fromJson(Map<String, dynamic> json) => TimeTrigger(
    id: json['id'] is int ? json['id'] as int : (json['id'] is num ? (json['id'] as num).toInt() : null),
    triggered: json['triggered'] as bool? ?? false,
    onEnter: json['onEnter'] as bool? ?? false,
    time: DateTime.parse(json['time'] as String).toLocal(),
  );
}

class LocationTrigger extends Trigger {
  final double latitude;
  final double longitude;
  final double radius;

  LocationTrigger({int? id, bool triggered = false, bool onEnter = false, required this.latitude, required this.longitude, required this.radius}) : super(id: id, triggered: triggered, onEnter: onEnter);

  @override
  String get type => 'LOCATION';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'triggered': triggered,
    'onEnter': onEnter,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
  };

  static LocationTrigger fromJson(Map<String, dynamic> json) => LocationTrigger(
    id: json['id'] as int,
    triggered: json['triggered'] as bool? ?? false,
    onEnter: json['onEnter'] as bool? ?? false,
    latitude:  (json['latitude'] as num).toDouble() ,
    longitude:  (json['longitude'] as num).toDouble() ,
    radius: (json['radius'] as num).toDouble(),
  );
}

class Task {
  final int? id;
  final String title;
  final String? description;

  // Backend fields
  final TaskStatus status;
  final TaskProfile profile;
  final Trigger trigger; // polymorphic trigger

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.PENDING,
    required this.profile,
    required this.trigger,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'status': status.name,
    'profile': profile.name,
    'trigger': trigger.toJson(),
    // keep legacy fields for backward compatibility
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    status: json['status'] != null ? TaskStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => TaskStatus.PENDING) : TaskStatus.PENDING,
    profile: TaskProfile.values.firstWhere((e) => e.name == json['profile'], orElse: () => TaskProfile.HOME) ,
    trigger: Trigger.fromJson(json['trigger'] as Map<String, dynamic>?),
  );

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskProfile? profile,
    Trigger? trigger,

  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    profile: profile ?? this.profile,
    trigger: trigger ?? this.trigger,

  );
}