import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/modules/todos/data/todo_repo.dart';

// final todoListProvider =
//     AsyncNotifierProvider<TodoListNotifier, List<TodoModel>>(
//       TodoListNotifier.new,
//     );

// class TodoListNotifier extends AsyncNotifier<List<TodoModel>> {
//   late TodoRepository _repository;

//   StreamSubscription? _subscription;

//   @override
//   FutureOr<List<TodoModel>> build() {
//     _repository = ref.watch(todoRepositoryProvider);
//     _watchLocalChanges();
//     authChange();
//     return _loadFromLocal();
//   }

//   List<TodoModel> _loadFromLocal() {
//     return _repository.getAll();
//   }

//   void _watchLocalChanges() {
//     _subscription = _repository.watchAll().listen((_) {
//       // Reload whenever local storage changes
//       state = AsyncData(_loadFromLocal());
//     });
//   }

//   void authChange() {
//     Supabase.instance.client.auth.onAuthStateChange.listen((e) {
//       if (e.event == AuthChangeEvent.signedOut) {
//         _repository.clear();
//         ref.invalidateSelf();
//       }

//     });
//   }

//   // ── Actions ────────────────────────────────────────────────

//   Future<void> createTodo(String title) async {
//     if (title.trim().isEmpty) return;

//     // Optimistic update
//     final tempTodo = TodoModel(
//       title: title.trim(),
//       syncStatus: SyncStatus.pending,
//       // userId: _client.auth.currentUser!.id
//     );

//     state = AsyncData([tempTodo, ...state.requireValue]);

//     try {
//       await _repository.create(title.trim());

//       // // Replace temp with actual
//       // state = AsyncData([
//       //   created,
//       //   ...state.requireValue.where((t) => t.localId != tempTodo.localId),
//       // ]);
//     } catch (e) {
//       // Rollback on error
//       state = AsyncData(
//         state.requireValue.where((t) => t.localId != tempTodo.localId).toList(),
//       );
//       rethrow;
//     }
//   }

//   Future<void> toggleTodo(TodoModel todo) async {
//     // Optimistic update
//     final updated = todo.copyWith(
//       isCompleted: !todo.isCompleted,
//       syncStatus: SyncStatus.pending,
//       updatedAt: DateTime.now(),
//     );

//     _replaceInState(updated);

//     try {
//       await _repository.toggle(todo);
//     } catch (e) {
//       // Rollback
//       _replaceInState(todo);
//       rethrow;
//     }
//   }

//   Future<void> updateTitle(TodoModel todo, String newTitle) async {
//     if (newTitle.trim().isEmpty) return;

//     final updated = todo.copyWith(
//       title: newTitle.trim(),
//       syncStatus: SyncStatus.pending,
//       updatedAt: DateTime.now(),
//     );

//     _replaceInState(updated);

//     try {
//       await _repository.updateTitle(todo, newTitle.trim());
//     } catch (e) {
//       _replaceInState(todo);
//       rethrow;
//     }
//   }

//   Future<void> deleteTodo(TodoModel todo) async {
//     // Optimistic removal
//     state = AsyncData(
//       state.requireValue.where((t) => t.localId != todo.localId).toList(),
//     );

//     try {
//       await _repository.delete(todo);
//     } catch (e) {
//       // Rollback — add it back
//       state = AsyncData([todo, ...state.requireValue]);
//       rethrow;
//     }
//   }

//   Future<void> retryFailed(TodoModel todo) async {
//     final retrying = todo.copyWith(syncStatus: SyncStatus.pending);
//     _replaceInState(retrying);

//     try {
//       await _repository.retryFailed(todo);
//     } catch (e) {
//       _replaceInState(todo);
//       rethrow;
//     }
//   }

//   // ── Helpers ────────────────────────────────────────────────

//   void _replaceInState(TodoModel updated) {
//     state = AsyncData(
//       state.requireValue.map((t) {
//         return t.localId == updated.localId ? updated : t;
//       }).toList(),
//     );
//   }

//   // @override
//   void dispose() {
//     _subscription?.cancel();
//     // super.dispose();
//   }
// }

// // ── Filtered views ─────────────────────────────────────────

// enum TodoFilter { all, active, completed }

// final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// final filteredTodosProvider = Provider<AsyncValue<List<TodoModel>>>((ref) {
//   final todosAsync = ref.watch(todoListProvider);
//   final filter = ref.watch(todoFilterProvider);

//   return todosAsync.whenData((todos) {
//     switch (filter) {
//       case TodoFilter.active:
//         return todos.where((t) => !t.isCompleted).toList();
//       case TodoFilter.completed:
//         return todos.where((t) => t.isCompleted).toList();
//       case TodoFilter.all:
//         return todos;
//     }
//   });
// });

// // ── Stats ──────────────────────────────────────────────────

// final todoStatsProvider = Provider<Map<String, int>>((ref) {
//   final todosAsync = ref.watch(todoListProvider);

//   return todosAsync.when(
//     data: (todos) => {
//       'total': todos.length,
//       'active': todos.where((t) => !t.isCompleted).length,
//       'completed': todos.where((t) => t.isCompleted).length,
//       'pending': todos.where((t) => t.syncStatus == SyncStatus.pending).length,
//       'failed': todos.where((t) => t.syncStatus == SyncStatus.failed).length,
//     },
//     loading: () => {},
//     error: (_, __) => {},
//   );
// });

final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<TodoModel>>(
      TodoListNotifier.new,
    );

class TodoListNotifier extends AsyncNotifier<List<TodoModel>> {
  late TodoRepository _repository;
  StreamSubscription? _subscription;

  @override
  FutureOr<List<TodoModel>> build() {
    _repository = ref.watch(todoRepositoryProvider);
    _watchLocalChanges();
    onAuthChange();
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

  // ── Actions ────────────────────────────────────────────────

  // Future<void> createTodo(String title) async {
  //   if (title.trim().isEmpty) return;

  //   // Optimistic update
  //   final tempTodo = TodoModel(
  //     title: title.trim(),
  //     syncStatus: SyncStatus.pending,
  //   );

  //   state = AsyncData([tempTodo, ...state.requireValue]);

  //   try {
  //     await _repository.create(title.trim());

  //     // // Replace temp with actual
  //     // state = AsyncData([
  //     //   created,
  //     //   ...state.requireValue.where((t) => t.localId != tempTodo.localId),
  //     // ]);
  //   } catch (e) {
  //     // Rollback on error
  //     state = AsyncData(
  //       state.requireValue.where((t) => t.localId != tempTodo.localId).toList(),
  //     );
  //     rethrow;
  //   }
  // }
  Future<void> createTodo(TodoModel todo) async {
    state = AsyncData([todo, ...state.requireValue]);

    try {
      await _repository.create(todo);
    } catch (e) {
      // Rollback on error
      state = AsyncData(
        state.requireValue.where((t) => t.localId != todo.localId).toList(),
      );
      rethrow;
    }
  }

  Future<void> toggleTodo(TodoModel todo) async {
    // Optimistic update
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    _replaceInState(updated);

    try {
      await _repository.toggle(todo);
    } catch (e) {
      // Rollback
      _replaceInState(todo);
      rethrow;
    }
  }

  Future<void> updateTitle(TodoModel todo, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    final updated = todo.copyWith(
      title: newTitle.trim(),
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    _replaceInState(updated);

    try {
      await _repository.updateTitle(todo, newTitle.trim());
    } catch (e) {
      _replaceInState(todo);
      rethrow;
    }
  }

  Future<void> deleteTodo(TodoModel todo) async {
    // Optimistic removal
    state = AsyncData(
      state.requireValue.where((t) => t.localId != todo.localId).toList(),
    );

    try {
      await _repository.delete(todo);
    } catch (e) {
      // Rollback — add it back
      state = AsyncData([todo, ...state.requireValue]);
      rethrow;
    }
  }

  Future<void> retryFailed(TodoModel todo) async {
    final retrying = todo.copyWith(syncStatus: SyncStatus.pending);
    _replaceInState(retrying);

    try {
      await _repository.retryFailed(todo);
    } catch (e) {
      _replaceInState(todo);
      rethrow;
    }
  }

  // ── Helpers ────────────────────────────────────────────────

  void _replaceInState(TodoModel updated) {
    state = AsyncData(
      state.requireValue.map((t) {
        return t.localId == updated.localId ? updated : t;
      }).toList(),
    );
  }

  // @override
  void dispose() {
    _subscription?.cancel();
    // super.dispose();
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
