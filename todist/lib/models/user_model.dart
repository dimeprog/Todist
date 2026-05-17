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
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakDate;
  final int totalCompletions;
  final DateTime? streakUpdatedAt;

  const UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStreakDate,
    this.totalCompletions = 0,
    this.streakUpdatedAt,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.tryParse(json['created_at']),
      updatedAt: DateTime.tryParse(json['updated_at']),
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastStreakDate: json['last_streak_date'] != null
          ? DateTime.tryParse(json['last_streak_date'])
          : null,
      totalCompletions: json['total_completions'] ?? 0,
      streakUpdatedAt: json['streak_updated_at'] != null
          ? DateTime.tryParse(json['streak_updated_at'])
          : null,
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
      currentStreak: json.userMetadata?['current_streak'] as int? ?? 0,
      longestStreak: json.userMetadata?['longest_streak'] as int? ?? 0,
      lastStreakDate:
          (json.userMetadata?['last_streak_date'] as String?) == null
          ? null
          : DateTime.tryParse(json.userMetadata?['last_streak_date'] as String),
      totalCompletions: json.userMetadata?['total_completions'] as int? ?? 0,
      streakUpdatedAt: (json.userMetadata?['streak_updated_at'] as String?) == null
          ? null
          : DateTime.tryParse(json.userMetadata?['streak_updated_at'] as String),
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
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_streak_date': lastStreakDate?.toIso8601String(),
      'total_completions': totalCompletions,
      'streak_updated_at': streakUpdatedAt?.toIso8601String(),
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
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStreakDate,
    int? totalCompletions,
    DateTime? streakUpdatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      streakUpdatedAt: streakUpdatedAt ?? this.streakUpdatedAt,
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
    currentStreak,
    longestStreak,
    lastStreakDate,
    totalCompletions,
    streakUpdatedAt
  ];
}
