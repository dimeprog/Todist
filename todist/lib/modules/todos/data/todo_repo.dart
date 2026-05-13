import 'package:todist/models/enums/outbox_operation.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/outbox_entry.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/sources/sync_engine.dart';

import 'sources/local_todo_source.dart';

class TodoRepository {
  final LocalTodoStore _local;
  final SyncEngine _syncEngine;

  TodoRepository({
    required LocalTodoStore local,
    required SyncEngine syncEngine,
  }) : _local = local,
       _syncEngine = syncEngine;

  // ── Read ───────────────────────────────────────────────────

  List<TodoModel> getAll() => _local.getAll();

  Stream<dynamic> watchAll() => _local.watchTodos();

  // ── Write ──────────────────────────────────────────────────

  Future<TodoModel> create(String title) async {
    final todo = TodoModel(title: title, syncStatus: SyncStatus.pending);

    // 1. Write to local immediately
    await _local.save(todo);

    // 2. Enqueue to outbox (always — dequeued on success)
    await _local.enqueue(
      OutboxEntry(
        localId: todo.localId,
        operation: OutboxOperation.upsert,
        payload: todo.toRemoteJson(),
      ),
    );

    // 3. Attempt remote sync — outbox handles failure
    await _syncEngine.syncAfterWrite(todo);

    return todo;
  }

  Future<TodoModel> toggle(TodoModel todo) async {
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    await _local.save(updated);
    await _enqueueOrReplace(updated);
    await _syncEngine.syncAfterWrite(updated);

    return updated;
  }

  Future<TodoModel> updateTitle(TodoModel todo, String newTitle) async {
    final updated = todo.copyWith(
      title: newTitle,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    await _local.save(updated);
    await _enqueueOrReplace(updated);
    await _syncEngine.syncAfterWrite(updated);

    return updated;
  }

  Future<void> delete(TodoModel todo) async {
    final deleted = todo.copyWith(
      isDeleted: true,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    // Soft delete locally — hard delete on remote
    await _local.save(deleted);
    await _local.enqueue(
      OutboxEntry(
        localId: todo.localId,
        operation: OutboxOperation.delete,
        payload: {'local_id': todo.localId},
      ),
    );

    await _syncEngine.syncAfterWrite(deleted);
  }

  Future<void> retryFailed(TodoModel todo) async {
    final retrying = todo.copyWith(
      syncStatus: SyncStatus.pending,
      retryCount: 0,
    );
    await _local.save(retrying);
    await _enqueueOrReplace(retrying);
    await _syncEngine.flush();
  }

  // ── Helpers ────────────────────────────────────────────────

  /// Replace existing outbox entry to avoid duplicates for the same record
  Future<void> _enqueueOrReplace(TodoModel todo) async {
    await _local.enqueue(
      OutboxEntry(
        localId: todo.localId,
        operation: OutboxOperation.upsert,
        payload: todo.toRemoteJson(),
      ),
    );
  }

  Future<void> clear()async{
    await _local.clear();
  }

}

