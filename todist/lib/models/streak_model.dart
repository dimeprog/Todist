// lib/models/streak_model.dart
import 'package:equatable/equatable.dart';

class StreakModel extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakDate;
  final DateTime streakUpdatedAt;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStreakDate,
    required this.streakUpdatedAt,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastStreakDate: json['last_streak_date'] != null
          ? DateTime.parse(json['last_streak_date'])
          : null,
      streakUpdatedAt: DateTime.parse(json['streak_updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_streak_date': lastStreakDate?.toIso8601String(),
      'streak_updated_at': streakUpdatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    lastStreakDate,
    streakUpdatedAt,
  ];
}

// Streak Log Model (for history)
class StreakLog extends Equatable {
  final String id;
  final String userId;
  final DateTime streakDate;
  final int tasksCompleted;
  final int streakValue;
  final DateTime createdAt;

  const StreakLog({
    required this.id,
    required this.userId,
    required this.streakDate,
    required this.tasksCompleted,
    required this.streakValue,
    required this.createdAt,
  });

  factory StreakLog.fromJson(Map<String, dynamic> json) {
    return StreakLog(
      id: json['id'],
      userId: json['user_id'],
      streakDate: DateTime.parse(json['streak_date']),
      tasksCompleted: json['tasks_completed'] ?? 0,
      streakValue: json['streak_value'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    streakDate,
    tasksCompleted,
    streakValue,
    createdAt,
  ];
}
