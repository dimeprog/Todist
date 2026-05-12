import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/models/todo_model.dart';

import '../../../../core/logger.dart';

class RemoteTodoSource {
  final SupabaseClient _client;
  static const _table = 'todos';

  RemoteTodoSource(this._client);

  // ── Write ──────────────────────────────────────────────────

  /// Upsert by local_id — idempotent, safe to retry
  Future<TodoModel> upsert(TodoModel todo) async {
    final response = await _client
        .from(_table)
        .upsert(
          {...todo.toRemoteJson(), 'user_id': _client.auth.currentUser!.id},
          onConflict: 'local_id', // Postgres upsert key
        )
        .select()
        .single();
    log.d('/// write to remote \n${todo.toRemoteJson()}');
    return TodoModel.fromRemoteJson(response);
  }

  Future<void> delete(String localId) async {
    await _client
        .from(_table)
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('local_id', localId)
        .eq('user_id', _client.auth.currentUser!.id);
    log.d('/// delete from remote $localId');
  }

  // ── Read / Delta sync ──────────────────────────────────────

  /// Fetch only rows updated after [since] — delta sync
  Future<List<TodoModel>> fetchDelta(DateTime? since) async {
    var query = _client
        .from(_table)
        .select()
        .eq('user_id', _client.auth.currentUser!.id);

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final rows = await query.order('updated_at', ascending: false);
    log.d('/// fetch from remote \n${rows.map((e) => e)}');
    return rows.map(TodoModel.fromRemoteJson).toList();
  }

  // ── Realtime ───────────────────────────────────────────────

  RealtimeChannel subscribeToChanges({
    required void Function(TodoModel todo) onUpsert,
    required void Function(String localId) onDelete,
  }) {
    final userId = _client.auth.currentUser!.id;

    return _client
        .channel('todos:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final todo = TodoModel.fromRemoteJson(payload.newRecord);
            log.d('/// on realtime insert \n${todo.toRemoteJson()}');
            onUpsert(todo);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final todo = TodoModel.fromRemoteJson(payload.newRecord);
            if (todo.isDeleted) {
              log.d('/// on realtime update \n${todo.toRemoteJson()}');
              onDelete(todo.localId);
            } else {
              onUpsert(todo);
            }
          },
        )
        .subscribe();
  }
}
