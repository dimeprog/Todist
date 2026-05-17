import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/models/streak_model.dart';
import 'package:todist/modules/profile/data/streak_repo.dart';

import '../../../core/logger.dart';

final streakHistoryProvider =
    AsyncNotifierProvider.family<StreakHistoryNotifier, List<StreakLog>, String>(
  StreakHistoryNotifier.new,
);

class StreakHistoryNotifier
    extends FamilyAsyncNotifier<List<StreakLog>, String> {
  late StreakRepository _repository;
  @override
  FutureOr<List<StreakLog>> build(arg) {
    _repository = ref.watch(streakRepositoryProvider);
    return load();
  }

  FutureOr<List<StreakLog>> load() async {
    try {
      final result = await _repository.getStreakHistory(days: 30);
      return result.fold((l) => Future.error(l.message), (r) => r.data);
    } catch (e) {
      log.e(e);
      return Future.error('Something went wrong,try again');
    }
  }
}
