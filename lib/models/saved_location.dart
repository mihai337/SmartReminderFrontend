import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLocation {
  final String id;
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedLocation({
    required this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radiusMeters: (json['radiusMeters'] as num).toDouble(),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );

  SavedLocation copyWith({
    String? id,
    String? userId,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavedLocation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
