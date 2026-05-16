// lib/modules/profile/data/profile_repository.dart
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/failure.dart';
import 'package:todist/core/response_data.dart';
import 'package:todist/core/typedefs.dart';
import 'package:todist/models/user_model.dart';

abstract class ProfileRepository {
  FutureResponse<UserModel> getProfile(String userId);
  FutureResponse<UserModel> getCurrentUserProfile();
  FutureResponse<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? fcmToken,
  });
  RealtimeChannel subscribeToProfile(String userId);
  FutureResponse<UserModel> uploadAvatar(String filePath);
  FutureResponse<bool> deleteAvatar();
  FutureResponse<void> updateFcmToken(String fcmToken);
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get profile by user ID
  @override
  FutureResponse<UserModel> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return Left(Failure('User not found'));
      }
      return Right(ResponseData(data: UserModel.fromJson(response)));
    } catch (e) {
      return Left(Failure('Failed to get profile'));
    }
  }

  // Get current user's profile
  @override
  FutureResponse<UserModel> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure("Unable to get current user"));
      return await getProfile(userId);
    } catch (e) {
      return Left(Failure('Failed to get current user profile'));
    }
  }

  // Update profile
  @override
  FutureResponse<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? fcmToken,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure('User not authenticated'));

      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (fcmToken != null) updates['fcm_token'] = fcmToken;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      // return UserModel.fromJson(response);
      return Right(ResponseData(data: UserModel.fromJson(response)));
    } catch (e) {
      // throw Exception('Failed to update profile: $e');
      return Left(Failure('Failed to update profile'));
    }
  }

  // Update FCM token
  @override
  FutureResponse<void> updateFcmToken(String fcmToken) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure('User not authenticated'));

      await _supabase
          .from('users')
          .update({
            'fcm_token': fcmToken,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return Right(ResponseData(data: null));
    } catch (e) {
      // throw Exception('Failed to update FCM token: $e');
      return Left(Failure('Failed to update FCM token'));
    }
  }

  // Upload avatar image
  @override
  FutureResponse<UserModel> uploadAvatar(String filePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure('User not authenticated'));

      final fileName =
          'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('avatars').upload(fileName, File(filePath));

      // Get public URL
      final avatarUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update profile with new avatar URL
      return await updateProfile(avatarUrl: avatarUrl);
    } catch (e) {
      // throw Exception('Failed to upload avatar: $e');
      return Left(Failure('Failed to upload avatar'));
    }
  }

  // Delete avatar
  @override
  FutureResponse<bool> deleteAvatar() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure('User not authenticated'));

      // Get current profile to find avatar URL
      final profile = await updateProfile(avatarUrl: null);

      return profile.fold(
        (l) {
          return Left(Failure('Failed to get current user profile'));
        },
        (r) {
          return Right(ResponseData(data: true));
        },
      );
    } catch (e) {
      // throw Exception('Failed to delete avatar: $e');
      return Left(Failure('Failed to delete avatar: $e'));
    }
  }

  // Check if profile exists, create if not
  FutureResponse<UserModel> getMyProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Left(Failure('User not authenticated'));

      return getProfile(userId);
    } catch (e) {
      // throw Exception('Failed to get or create profile: $e');
      return Left(Failure('Failed to get or create profile'));
    }
  }

  // Subscribe to profile changes (realtime)
  @override
  RealtimeChannel subscribeToProfile(String userId) {
    return _supabase
        .channel('profile_channel')
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
            // Handle realtime updates
          },
        )
        .subscribe();

    // .map((event) {
    //   // Transform event to UserModel
    //   return UserModel.fromJson(event as Map<String, dynamic>);
    // });
  }
}
