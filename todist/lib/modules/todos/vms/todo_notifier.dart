import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/modules/todos/data/todo_repo.dart';
import 'package:todist/modules/todos/vms/todo_state.dart';


////////////////

final todoActionsProvider = NotifierProvider<TodoActionsNotifier, TodoState>(
  TodoActionsNotifier.new,
);

class TodoActionsNotifier extends Notifier<TodoState> {
  late TodoRepository _repository;
  @override
  build() {
    _repository = ref.watch(todoRepositoryProvider);
    return IdleTodoState();
  }

  Future<void> createTodo(TodoModel todo) async {
    // state = AsyncData([todo, ...state.requireValue]);
    try {
      state = AddTodo(todo);
      await _repository.create(todo);
    } catch (e) {
      state = RemoveTodo(todo);
    }
  }

  Future<void> toggleTodo(TodoModel todo) async {
    // Optimistic update
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );
    // _replaceInState(updated);
    state = ToggleTodo(updated);

    try {
      await _repository.toggle(todo);
    } catch (e) {
      state = Failed(todo);
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    final updated = todo.copyWith(
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    // _replaceInState(updated);

    state = UpdateTodo(updated);

    try {
      await _repository.update(todo);
    } catch (e) {
      state = Failed(todo);
    }
  }

  Future<void> updateTitle(TodoModel todo, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    final updated = todo.copyWith(
      title: newTitle.trim(),
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    // _replaceInState(updated);

    state = UpdateTodo(updated);

    try {
      await _repository.updateTitle(todo, newTitle.trim());
    } catch (e) {
      state = Failed(todo);
    }
  }

  Future<void> deleteTodo(TodoModel todo) async {
    // Optimistic removal
    state = RemoveTodo(todo);
    try {
      await _repository.delete(todo);
    } catch (e) {
      state = Failed(todo);
    }
  }

  Future<void> retryFailed(TodoModel todo) async {
    final retrying = todo.copyWith(syncStatus: SyncStatus.pending);
    // _replaceInState(retrying);
    state = RetryTodo(retrying);

    try {
      await _repository.retryFailed(todo);
    } catch (e) {
      state = Failed(todo);
    }
  }
}
