// lib/modules/streak/data/streak_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/failure.dart';
import 'package:todist/core/typedefs.dart';
import 'package:todist/models/streak_model.dart';

import '../../../core/logger.dart';
import '../../../core/response_data.dart';

abstract class StreakRepository {
  /// Get current user's streak
  FutureResponse<StreakModel> getCurrentStreak();

  /// Get streak history (last 7/30 days for calendar view)
  FutureResponse<List<StreakLog>> getStreakHistory({
    int days = 30,
    String? userId,
  });

  /// Watch for updates to current user's streak
  RealtimeChannel watchStreak(Function(StreakModel) onStreakUpdate);

  /// Get other user streak
  FutureResponse<StreakModel> getStreak(String userId);
}

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepositoryImpl();
});

class StreakRepositoryImpl implements StreakRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  FutureResponse<StreakModel> getCurrentStreak() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) Left(Failure('User not authenticated'));

      final response = await _supabase
          .from('users')
          .select(
            'current_streak, longest_streak, last_streak_date, streak_updated_at',
          )
          .eq('id', userId!)
          .maybeSingle();

      if (response == null) {
        return Left(Failure('No streak found'));
      }

      return Right(ResponseData(data: StreakModel.fromJson(response)));
    } catch (e) {
      return Left(Failure('Failed to get current user streak'));
    }
  }

  @override
  FutureResponse<StreakModel> getStreak(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select(
            'current_streak, longest_streak, last_streak_date, streak_updated_at',
          )
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return Left(Failure('No streak found'));
      }

      return Right(ResponseData(data: StreakModel.fromJson(response)));
    } catch (e) {
      return Left(Failure('Failed to get current user streak'));
    }
  }

  // Get streak history (last 7/30 days for calendar view)
  @override
  FutureResponse<List<StreakLog>> getStreakHistory({
    int days = 30,
    String? userId,
  }) async {
    final id = userId ?? _supabase.auth.currentUser?.id;
    if (userId == null) Left(Failure('User not authenticated'));

    final startDate = DateTime.now().subtract(Duration(days: days));

    final response = await _supabase
        .from('streak_logs')
        .select()
        .eq('user_id', id!)
        .gte('streak_date', startDate.toIso8601String().split('T')[0])
        .order('streak_date', ascending: false);

    return Right(
      ResponseData(
        data: response.map((json) => StreakLog.fromJson(json)).toList(),
      ),
    );
  }

  // Subscribe to real-time streak updates
  @override
  RealtimeChannel watchStreak(Function(StreakModel) onStreakUpdate) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Stream.error('User not authenticated');

    return _supabase
        .channel('streak_channel_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final updatedStreak = StreakModel.fromJson(payload.newRecord);
              onStreakUpdate(updatedStreak);
            }  catch (e) {
             log.e(e);
            }
          },
        )
        .subscribe();
  }
}
