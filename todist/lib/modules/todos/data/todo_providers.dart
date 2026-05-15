import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/notification_service.dart';
import 'package:todist/modules/todos/data/sources/local_todo_source.dart';
import 'package:todist/modules/todos/data/sources/remote_source.dart';
import 'package:todist/modules/todos/data/sources/sync_engine.dart';
import 'package:todist/modules/todos/data/todo_repo.dart';

// ── Infrastructure ─────────────────────────────────────────

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final localStoreProvider = Provider<LocalTodoStore>((ref) {
  final store = LocalTodoStore();
  // Init is called separately in main.dart before runApp
  return store;
});

final remoteSourceProvider = Provider<RemoteTodoSource>((ref) {
  final client = ref.watch(supabaseProvider);
  return RemoteTodoSource(client);
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final local = ref.watch(localStoreProvider);
  final remote = ref.watch(remoteSourceProvider);

  final sync = SyncEngine(local: local, remote: remote);

  // Start sync engine automatically
  // sync.start();

  // Cleanup on dispose
  ref.onDispose(() => sync.dispose());

  ref.watch(supabaseProvider).auth.onAuthStateChange.listen((e) {
    if (e.event == AuthChangeEvent.signedIn ||
        e.event == AuthChangeEvent.initialSession) {
      sync.start();
    }
    if (e.event == AuthChangeEvent.signedOut) {
      sync.reset();
    }
  });

  return sync;
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final local = ref.watch(localStoreProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return TodoRepository(
    local: local,
    syncEngine: syncEngine,
    notificationService: notificationController,
  );
});
