import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/modules/todos/data/todo_repo.dart';

import '../../../utils/aysnclist_mixin.dart';
import 'todo_notifier.dart';

// ── Main List ───────────────────────────────────────────────

final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<TodoModel>>(
      TodoListNotifier.new,
    );

class TodoListNotifier extends AsyncNotifier<List<TodoModel>>
    with AysncListMixin<TodoModel> {
  late TodoRepository _repository;
  StreamSubscription? _subscription;

  @override
  FutureOr<List<TodoModel>> build() {
    _repository = ref.watch(todoRepositoryProvider);
    _watchLocalChanges();
    onAuthChange();
    onAction();
    return _loadFromLocal();
  }

  List<TodoModel> _loadFromLocal() {
    return _repository.getAll();
  }

  void _watchLocalChanges() {
    _subscription = _repository.watchAll().listen((_) {
      // Reload whenever local storage changes
      state = AsyncData(_loadFromLocal());
    });
  }

  void onAuthChange() {
    Supabase.instance.client.auth.onAuthStateChange.listen((e) {
      if (e.event == AuthChangeEvent.signedOut) {
        _repository.clear();
        ref.invalidateSelf();
      }
    });
  }


  void onAction() {
    ref.listen(todoActionsProvider, (p, n) {
      n.maybeWhen(
        orElse: () {},
        add: (todo) => addTop(todo),
        toggle: (todo) =>
            findAndReplace(model: todo, test: (t) => t.localId == todo.localId),
        update: (todo) => findAndUpdate(
          where: (t) => t.localId == todo.localId,
          update: (t) => todo,
        ),
        // updateTitle: (todo, title) => updateTitle(todo, title),
        delete: (todo) =>
            findAndDelete(todo.localId, (t) => t.localId == todo.localId),
        retry: (todo) =>
            findAndReplace(model: todo, test: (t) => t.localId == todo.localId),
        failed: (todo) =>
            findAndReplace(model: todo, test: (t) => t.localId == todo.localId),
      );
    });
  }
}

// ── Filtered views ─────────────────────────────────────────

enum TodoFilter { active, completed }

final todoFilterProvider = StateProvider<TodoFilter>(
  (ref) => TodoFilter.active,
);

final filteredTodosProvider = Provider<AsyncValue<List<TodoModel>>>((ref) {
  final todosAsync = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return todosAsync.whenData((todos) {
    switch (filter) {
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
    }
  });
});

// ── Stats ──────────────────────────────────────────────────

final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todosAsync = ref.watch(todoListProvider);

  return todosAsync.when(
    data: (todos) => {
      'total': todos.length,
      'active': todos.where((t) => !t.isCompleted).length,
      'completed': todos.where((t) => t.isCompleted).length,
      'pending': todos.where((t) => t.syncStatus == SyncStatus.pending).length,
      'failed': todos.where((t) => t.syncStatus == SyncStatus.failed).length,
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
