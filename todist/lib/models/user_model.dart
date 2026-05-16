// lib/models/profile_model.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends Equatable {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String),
      updatedAt: DateTime.tryParse(json['updated_at'] as String),
    );
  }
  factory UserModel.fromSupaBase(User json) {
    return UserModel(
      id: json.id,
      email: json.email,
      fullName: json.userMetadata?['full_name'] as String?,
      avatarUrl: json.userMetadata?['avatar_url'] as String?,
      fcmToken: json.userMetadata?['fcm_token'] as String?,
      createdAt: (json.userMetadata?['created_at'] as String?) == null
          ? null
          : DateTime.tryParse(json.userMetadata?['created_at'] as String),
      updatedAt: (json.userMetadata?['updated_at'] as String?) == null
          ? null
          : DateTime.tryParse(json.userMetadata?['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'fcm_token': fcmToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    avatarUrl,
    fcmToken,
    createdAt,
    updatedAt,
  ];
}
