import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod/src/async_notifier.dart';


// ignore: invalid_use_of_internal_member
mixin AsyncMixin<T> on AsyncNotifierBase<T> {
  void onNetworkStateChanged() {
    InternetConnection().onStatusChange.listen((status) {
      // log.d('NETWORK STATE: ${status.toString()}');
      if (status == InternetStatus.connected && state.hasError) {
        ref.invalidateSelf(); // Refresh provider if network is back
      }
    });
  }
}

// ignore: invalid_use_of_internal_member
mixin AsyncListMixin<T> on AsyncNotifierBase<List<T>> {
  void onNetworkStateChanged() {
    InternetConnection().onStatusChange.listen((status) {
      // log.d('NETWORK STATE: ${status.toString()}');
      if (status == InternetStatus.connected && state.hasError) {
        ref.invalidateSelf(); // Refresh provider if network is back
      }
    });
  }

  /// update the list by finding and replacing  used mostly during updating
  void findAndReplace({
    required T model,
    bool Function(T)? test,
    bool addIfNotFound = false,
  }) {
    final values = state.requireValue;
    final index = values.indexWhere(
      test ?? (s) => (s as dynamic).id == (model as dynamic).id,
    );
    if (index != -1) {
      values[index] = model;
      state = AsyncData(values);
    } else {
      if (addIfNotFound) {
        values.add(model);
        state = AsyncData(values);
      }
    }
  }

  /// update list by adding to top new created item
  void addTop(T model, {bool Function(T)? test, int index = 0}) {
    final values = state.requireValue;
    if (test == null) {
      values.insert(index, model);
      state = AsyncData(values);
    } else {
      if (values.any(test)) {
        values.insert(index, model);
        state = AsyncData(values);
      }
    }
  }

  void findAndDelete(String id, [bool Function(T)? test]) {
    final values = state.requireValue;
    values.removeWhere(test ?? (s) => (s as dynamic).id == id);
    state = AsyncData(values);
  }

  void findAndUpdate({
    required bool Function(T item) where,
    required T Function(T item) update,
  }) {
    final list = state.requireValue;
    final newList = list.map((item) {
      if (where(item)) {
        return update(item);
      } else {
        return item;
      }
    }).toList();
    state = AsyncData(newList);
  }

  void updateAll({required T Function(T item) update}) {
    final list = state.requireValue;
    final newList = list.map(update).toList();
    state = AsyncData(newList);
  }

  void clear() {
    state = AsyncData([]);
  }

  void findUpdateAndMaybeRemove({
    required bool Function(T item) where,
    required T Function(T item) update,
    required bool Function(T updatedItem) shouldRemove,
  }) {
    final list = state.requireValue;
    final newList = <T>[];

    for (final item in list) {
      if (where(item)) {
        final updatedItem = update(item);
        if (!shouldRemove(updatedItem)) {
          newList.add(updatedItem);
        }
        // If shouldRemove is true, we don't add it (effectively removing it)
      } else {
        newList.add(item);
      }
    }

    state = AsyncData(newList);
  }
}
