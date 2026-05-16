import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todist/models/todo_model.dart';

part 'todo_state.freezed.dart';

@freezed
abstract class TodoState with _$TodoState {
   factory TodoState.idle() = IdleTodoState;
   factory TodoState.add(TodoModel todo) = AddTodo;
   factory TodoState.remove(TodoModel todo) = RemoveTodo;
   factory TodoState.update(TodoModel todo) = UpdateTodo;
   factory TodoState.delete(TodoModel todo) = DeleteTodo;
   factory TodoState.retry(TodoModel todo) = RetryTodo;
   factory TodoState.toggle(TodoModel todo) = ToggleTodo;
   factory TodoState.failed(TodoModel todo) = Failed;



}