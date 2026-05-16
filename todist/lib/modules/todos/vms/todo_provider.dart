import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/logger.dart' show log;
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/modules/todos/data/todo_repo.dart';

import 'todo_notifier.dart';

final todoProvider =
    AsyncNotifierProviderFamily<TodoNotifier, TodoModel, String>(
      TodoNotifier.new,
    );

class TodoNotifier extends FamilyAsyncNotifier<TodoModel, String> {
  late TodoRepository _repository;
  @override
  Future<TodoModel> build(arg) async {
    _repository = ref.watch(todoRepositoryProvider);
    onAction();
    return load();
  }

  Future<TodoModel> load() async {
    try {
      final todo =  _repository.getByLocalId(arg);
      if (todo != null) {
        return todo;
      } else {
        return Future.error("Todo not found");
      }
    } catch (e) {
      log.e(e);
      return Future.error('Something went wrong,try again');
    }
  }

  void _replaceInState(TodoModel updatedTodo) {
    if(updatedTodo.localId == arg){}
    state = AsyncData(updatedTodo);
  }

 void onAction() {
    ref.listen(todoActionsProvider, (p, n) {
      n.maybeWhen(
        orElse: () {},
        toggle: (todo) => _replaceInState(todo) , 
        update: (todo) => _replaceInState(todo),
        retry: (todo) => _replaceInState(todo),
        failed: (todo) => _replaceInState(todo),
      );
    });
  }
}
