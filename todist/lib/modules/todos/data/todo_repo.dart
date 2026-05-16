import 'package:todist/core/notification_service.dart';
import 'package:todist/models/enums/outbox_operation.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/outbox_entry.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/sources/sync_engine.dart';

import '../../../core/logger.dart';
import 'sources/local_todo_source.dart';

class TodoRepository {
  final LocalTodoStore _local;
  final SyncEngine _syncEngine;
  final NotificationsController _notificationService;

  TodoRepository({
    required LocalTodoStore local,
    required SyncEngine syncEngine,
    required NotificationsController notificationService,
  }) : _local = local,
       _syncEngine = syncEngine,
       _notificationService = notificationService;

  // ── Read ───────────────────────────────────────────────────

  List<TodoModel> getAll() => _local.getAll();

  Stream<dynamic> watchAll() => _local.watchTodos();

  // ── Write ──────────────────────────────────────────────────

  Future<TodoModel> create(TodoModel todo) async {
    // final todo = TodoModel(title: title, syncStatus: SyncStatus.pending);

    // 1. Write to local immediately
    try {
      await _local.save(todo);
      // 2. Schedule local notification
      await _notificationService.scheduleLocalNotification(
        id: todo.hashCode,
        body: todo.description ?? "",
        title: todo.title,
        scheduledTime:
            todo.reminderAt ?? todo.createdAt.add(Duration(hours: 24)),
      );

      // 3. Enqueue to outbox (always — dequeued on success)
      await _local.enqueue(
        OutboxEntry(
          localId: todo.localId,
          operation: OutboxOperation.upsert,
          payload: todo.toRemoteJson(),
        ),
      );

      // 4. Attempt remote sync — outbox handles failure
      await _syncEngine.syncAfterWrite(todo);
      return todo;
    } catch (e) {
      log.e(e);
      rethrow;
    }
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

  Future<TodoModel> update(TodoModel todo) async {
    final updated = todo.copyWith(
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

  Future<void> clear() async {
    await _local.clear();
  }

  /// get todo by local id
  TodoModel? getByLocalId(String localId) => _local.getByLocalId(localId);
}
