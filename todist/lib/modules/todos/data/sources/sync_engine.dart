import 'dart:async';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/app_local_prefs.dart';
import 'package:todist/models/enums/outbox_operation.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/outbox_entry.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/modules/todos/data/sources/local_todo_source.dart';
import 'package:todist/modules/todos/data/sources/remote_source.dart';
import '../../../../core/logger.dart';

class SyncEngine {
  final LocalTodoStore _local;
  final RemoteTodoSource _remote;

  bool _isFlushing = false;
  bool _isOnline = false;
  DateTime? _lastSyncedAt;

  StreamSubscription<InternetStatus>? _connectivitySub;
  RealtimeChannel? _realtimeChannel;

  SyncEngine({required LocalTodoStore local, required RemoteTodoSource remote})
    : _local = local,
      _remote = remote;

  // ── Lifecycle ──────────────────────────────────────────────

  Future<void> start() async {
    _setLastSync();
    _watchConnectivity();
    _subscribeRealtime();
    await _deltaSync(); // pull any changes missed while offline
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _realtimeChannel?.unsubscribe();
  }

  // ── Public API ─────────────────────────────────────────────

  /// Call this after every local write. Tries remote immediately;
  /// if it fails or we're offline, the outbox entry will be flushed later.
  Future<void> syncAfterWrite(TodoModel todo) async {
    log.d('isOnline => $_isOnline');
    if (!_isOnline) return; // outbox already enqueued by repository
    await _flushEntry(
      OutboxEntry(
        localId: todo.localId,
        operation: OutboxOperation.upsert,
        payload: todo.toRemoteJson(),
      ),
    );
  }

  void _setLastSync([DateTime? time]) {
    AppLocalPrefs.latSyncAt = time?.toIso8601String();
    print(time);
    _lastSyncedAt = AppLocalPrefs.latSyncAt != null
        ? DateTime.tryParse(AppLocalPrefs.latSyncAt!)
        : null;
  }

  // ── Connectivity ───────────────────────────────────────────

  Future<void> _watchConnectivity() async {
    final results = await InternetConnection().hasInternetAccess;

    _isOnline = results;

    _connectivitySub = InternetConnection().onStatusChange.listen((
      results,
    ) async {
      log.d('Internet is status change => ${results.name}');
      final wasOnline = _isOnline;
      _isOnline = results == InternetStatus.connected;

      if (!wasOnline && _isOnline) {
        await flush();
        await _deltaSync();
      }
    });
  }

  // ── Outbox flush ───────────────────────────────────────────

  Future<void> flush() async {
    if (_isFlushing) return;
    _isFlushing = true;

    try {
      final pending = _local.getPendingOutbox();

      for (final entry in pending) {
        if (entry.isBackoffActive) continue;
        await _flushEntry(entry);
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _flushEntry(OutboxEntry entry) async {
    try {
      if (entry.operation == OutboxOperation.upsert) {
        final todo = _local.getByLocalId(entry.localId);
        if (todo == null) {
          await _local.dequeue(entry.localId);
          return;
        }

        final synced = await _remote.upsert(todo);

        // Update local record with remoteId and mark synced
        await _local.save(synced.copyWith(syncStatus: SyncStatus.synced));
        await _local.dequeue(entry.localId);
      } else if (entry.operation == OutboxOperation.delete) {
        await _remote.delete(entry.localId);
        await _local.delete(entry.localId);
        await _local.dequeue(entry.localId);
      }
    } catch (e) {
      final updated = entry.copyWith(
        retryCount: entry.retryCount + 1,
        lastAttempt: DateTime.now(),
        lastError: e.toString(),
      );

      if (updated.isExhausted) {
        // Mark the local todo as failed so UI can show an error badge
        final todo = _local.getByLocalId(entry.localId);
        if (todo != null) {
          await _local.save(todo.copyWith(syncStatus: SyncStatus.failed));
        }
        await _local.dequeue(entry.localId); // remove from queue
      } else {
        await _local.updateOutboxEntry(updated);
      }
    }
  }

  // ── Delta sync (pull) ──────────────────────────────────────

  Future<void> _deltaSync() async {
    // if (!_isOnline) return;
    log.d("lastSyncAt -> ${_lastSyncedAt?.toIso8601String()} ");

    try {
      final remote = await _remote.fetchDelta(_lastSyncedAt);

      for (final remoteTodo in remote) {
        final local = _local.getByLocalId(remoteTodo.localId);

        if (remoteTodo.isDeleted) {
          if (local != null) await _local.delete(remoteTodo.localId);
          continue;
        }

        // Last-write-wins: remote wins unless we have a pending local change
        final hasPendingLocal =
            local != null && local.syncStatus == SyncStatus.pending;

        if (!hasPendingLocal) {
          await _local.save(remoteTodo);
        }
      }

      // _lastSyncedAt = DateTime.now();
      _setLastSync(DateTime.now());
    } catch (_) {
      // Silent — will retry on next reconnect
    }
  }

  // ── Realtime (push from Supabase) ──────────────────────────

  void _subscribeRealtime() {
    _realtimeChannel = _remote.subscribeToChanges(
      onUpsert: (remoteTodo) async {
        final local = _local.getByLocalId(remoteTodo.localId);

        // Don't clobber a pending local write with the server echo
        final isOwnEcho = local?.syncStatus == SyncStatus.pending;
        if (isOwnEcho) return;

        await _local.save(remoteTodo);
      },
      onDelete: (localId) async {
        await _local.delete(localId);
      },
    );
  }

  void reset() {
    _lastSyncedAt = null;
    // _isOnline = false;
  }
}
