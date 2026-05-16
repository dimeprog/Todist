import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/logger.dart';
import 'package:todist/models/user_model.dart';
import 'package:todist/modules/auth/view_model/auth_notifier.dart';
import 'package:todist/modules/profile/data/profile_repo.dart';

import '../../auth/view_model/auth_state.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserModel>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<UserModel> {
  late ProfileRepository _profileRepository;

  @override
  FutureOr<UserModel> build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    onAuthChange();
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

  void onAuthChange() {
    ref.listen(authNotifierProvider, (p, n) {
      if (n is LoginSuccess || n is Registered || n is Authenticated) {
        ref.invalidateSelf();
      }
    });
  }
}
