import 'package:hive/hive.dart';
import 'package:todist/models/enums/outbox_operation.dart';


part 'outbox_entry.g.dart';


@HiveType(typeId: 3)
class OutboxEntry extends HiveObject {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final OutboxOperation operation;

  @HiveField(2)
  final Map<String, dynamic> payload;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retryCount;

  @HiveField(5)
  final DateTime? lastAttempt;

  @HiveField(6)
  final String? lastError;

  OutboxEntry({
    required this.localId,
    required this.operation,
    required this.payload,
    DateTime? createdAt,
    this.retryCount = 0,
    this.lastAttempt,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now();

  static const int maxRetries = 5;

  bool get isExhausted => retryCount >= maxRetries;

  /// Exponential backoff: 2^retryCount seconds (2s, 4s, 8s, 16s, 32s)
  bool get isBackoffActive {
    if (retryCount == 0 || lastAttempt == null) return false;
    final delay = Duration(seconds: 1 << retryCount);
    return DateTime.now().isBefore(lastAttempt!.add(delay));
  }

  OutboxEntry copyWith({
    int? retryCount,
    DateTime? lastAttempt,
    String? lastError,
  }) {
    return OutboxEntry(
      localId: localId,
      operation: operation,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      lastError: lastError ?? this.lastError,
    );
  }
}
