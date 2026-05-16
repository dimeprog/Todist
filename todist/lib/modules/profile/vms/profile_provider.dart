import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/logger.dart';
import 'package:todist/models/user_model.dart';
import 'package:todist/modules/auth/view_model/auth_notifier.dart';
import 'package:todist/modules/profile/data/profile_repo.dart';
import 'package:todist/modules/profile/data/streak_repo.dart';

import '../../auth/view_model/auth_state.dart';
import 'states/profile_state.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserModel>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<UserModel> {
  late ProfileRepository _profileRepository;
  late StreakRepository _streakRepository;

  @override
  FutureOr<UserModel> build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _streakRepository = ref.watch(streakRepositoryProvider);
    onAuthChange();
    onStreakChange();
    onProfileAction();
    return load();
  }

  FutureOr<UserModel> load() async {
    try {
      final result = await _profileRepository.getCurrentUserProfile();
      return result.fold((l) => Future.error(l.message), (r) => r.data);
    } catch (e) {
      log.e(e);
      return Future.error('Something went wrong,try again');
    }
  }

  /// Update profile when auth state changes
  void onAuthChange() {
    ref.listen(authNotifierProvider, (p, n) {
      if (n is LoginSuccess || n is Registered || n is Authenticated) {
        ref.invalidateSelf();
      }
    });
  }

  /// Update current user streak
  void onStreakChange() {
    _streakRepository.watchStreak((streak) {
      state = state.whenData(
        (user) => user.copyWith(
          currentStreak: streak.currentStreak,
          longestStreak: streak.longestStreak,
          lastStreakDate: streak.lastStreakDate,
          streakUpdatedAt: streak.streakUpdatedAt,
        ),
      );
    });
  }

  /// Update profile when profile state changes
  void onProfileAction() {
    ref.listen(profileActionsProvider, (p, n) {
      n.maybeWhen(orElse: () {}, updated: (user) => state = AsyncData(user));
    });
  }
}

// --------------- profile actions  ----------------

final profileActionsProvider =
    NotifierProvider<ProfileActionsNotifier, ProfileState>(
      ProfileActionsNotifier.new,
    );

class ProfileActionsNotifier extends Notifier<ProfileState> {
  late ProfileRepository _profileRepository;
  late StreakRepository _streakRepository;
  @override
  build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _streakRepository = ref.watch(streakRepositoryProvider);
    return IdleProfileState();
  }

  void update({String? fullName, String? avatarUrl, String? fcmToken}) async {
    try {
      state = UpdatingProfile();
      final result = await _profileRepository.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        fcmToken: fcmToken,
      );
      result.fold(
        (l) => state = UpdateErrorProfile(l.message),
        (r) => state = UpdatedProfile(r.data),
      );
    } catch (e) {
      log.e(e);
      state = UpdateErrorProfile('Something went wrong,try again');
    }
  }
}
