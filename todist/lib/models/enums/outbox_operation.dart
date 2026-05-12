import 'package:hive/hive.dart';

part 'outbox_operation.g.dart';

@HiveType(typeId: 2)
enum OutboxOperation {
  @HiveField(0)
  upsert,
  @HiveField(1)
  delete,
}
