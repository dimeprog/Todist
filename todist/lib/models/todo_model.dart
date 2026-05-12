import 'package:hive/hive.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';



@HiveType(typeId: 1)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final String? remoteId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final SyncStatus syncStatus;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final int retryCount;

  @HiveField(8)
  final bool isDeleted;

  @HiveField(9)
  final String userId;

  TodoModel({
    String? localId,
    this.userId,
    this.remoteId,
    required this.title,
    this.isCompleted = false,
    this.syncStatus = SyncStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,

    this.retryCount = 0,
    this.isDeleted = false,
  }) : localId = localId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  TodoModel copyWith({
    String? localId,
    String? remoteId,
    String? title,
    bool? isCompleted,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? retryCount,
    bool? isDeleted,
    String? userId,
  }) {
    return TodoModel(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      isDeleted: isDeleted ?? this.isDeleted,
      userId:  userId?? this.userId,
    );
  }

  Map<String, dynamic> toRemoteJson() => {
    'local_id': localId,
    'title': title,
    "user_id": userId,
    'is_completed': isCompleted,
    'is_deleted': isDeleted,
    'updated_at': updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
  };

  factory TodoModel.fromRemoteJson(Map<String, dynamic> json) => TodoModel(
    localId: json['local_id'] as String,
    remoteId: json['id'] as String?,
    title: json['title'] as String,
    userId: json['user_id'] as String,
    isCompleted: json['is_completed'] as bool? ?? false,
    syncStatus: SyncStatus.synced,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    isDeleted: json['is_deleted'] as bool? ?? false,
  );
}
