import 'package:hive/hive.dart';
import 'package:todist/models/enums/outbox_operation.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/outbox_entry.dart';
import 'package:todist/models/todo_model.dart';

class LocalTodoStore {
  static const _todoBoxName = 'todos';
  static const _outboxBoxName = 'outbox';

  late Box<TodoModel> _todoBox;
  late Box<OutboxEntry> _outboxBox;

  Future<void> init() async {
    // Register adapters before opening boxes
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SyncStatusAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TodoModelAdapter());
    if (!Hive.isAdapterRegistered(2))Hive.registerAdapter(OutboxOperationAdapter());
    if (!Hive.isAdapterRegistered(3))Hive.registerAdapter(OutboxEntryAdapter());

    _todoBox = await Hive.openBox<TodoModel>(_todoBoxName);
    _outboxBox = await Hive.openBox<OutboxEntry>(_outboxBoxName);
  }

  // ── Todo CRUD ──────────────────────────────────────────────

  List<TodoModel> getAll() {
    return _todoBox.values.where((t) => !t.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TodoModel? getByLocalId(String localId) => _todoBox.get(localId);

  Future<void> save(TodoModel todo) async {
    await _todoBox.put(todo.localId, todo);
  }

  Future<void> saveAll(List<TodoModel> todos) async {
    final map = {for (final t in todos) t.localId: t};
    await _todoBox.putAll(map);
  }

  Future<void> delete(String localId) async {
    await _todoBox.delete(localId);
  }

  // ── Outbox ─────────────────────────────────────────────────

  List<OutboxEntry> getPendingOutbox() {
    return _outboxBox.values.where((e) => !e.isExhausted).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // FIFO
  }

  Future<void> enqueue(OutboxEntry entry) async {
    await _outboxBox.put(entry.localId, entry);
  }

  Future<void> dequeue(String localId) async {
    await _outboxBox.delete(localId);
  }

  Future<void> updateOutboxEntry(OutboxEntry entry) async {
    await _outboxBox.put(entry.localId, entry);
  }

  bool hasOutboxEntry(String localId) => _outboxBox.containsKey(localId);

  // ── Streams ────────────────────────────────────────────────

  Stream<BoxEvent> watchTodos() => _todoBox.watch();

  Stream<BoxEvent> watchOutbox() => _outboxBox.watch();

  Future<void> close() async {
    await _todoBox.close();
    await _outboxBox.close();
  }

  Future<void> clear() async {
    await _todoBox.clear();
    await _outboxBox.clear();
  }
}



