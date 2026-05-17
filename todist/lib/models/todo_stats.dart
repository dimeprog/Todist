// 'total': todos.length,
//       'active': todos.where((t) => !t.isCompleted).length,
//       'completed': todos.where((t) => t.isCompleted).length,
//       'pending': todos.where((t) => t.syncStatus == SyncStatus.pending).length,
//       'failed':
class TodoStats {
  final int total;
  final int pending;
  final int completed;
  final int failed;
  final int active;
  final int deleted;
  final int reminders;

  TodoStats({
    this.total = 0,
    this.pending = 0,
    this.completed = 0,
    this.failed = 0,
    this.active = 0,
    this.deleted = 0,
    this.reminders = 0,
  });

  TodoStats copyWith({
    int? total,
    int? pending,
    int? completed,
    int? failed,
    int? active,
    int? deleted,
    int? reminders,
  }) {
    return TodoStats(
      total: total ?? this.total,
      pending: pending ?? this.pending,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      reminders: reminders ?? this.reminders,
    );
  }

  bool get isEmpty =>
      total == 0 &&
      pending == 0 &&
      completed == 0 &&
      failed == 0 &&
      active == 0 
      && deleted == 0
      && reminders == 0;

  Map<String, int> toMap() {
    return {
      'total': total,
      'active': active,
      'completed': completed,
      'pending': pending,
      'failed': failed,
      'deleted': deleted,
      'reminders': reminders
    };
  }
}
