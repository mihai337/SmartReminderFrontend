import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    photoUrl: json['photoUrl'] as String?,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
