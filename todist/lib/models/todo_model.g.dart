// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 1;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      localId: fields[0] as String?,
      userId: fields[9] as String?,
      remoteId: fields[1] as String?,
      title: fields[2] as String,
      isCompleted: fields[3] as bool,
      syncStatus: fields[4] as SyncStatus,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      retryCount: fields[7] as int,
      isDeleted: fields[8] as bool,
      reminderAt: fields[12] as DateTime?,
      reminderSent: fields[14] as bool?,
      pushToken: fields[13] as String?,
      dueDate: fields[11] as DateTime?,
      description: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.syncStatus)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.dueDate)
      ..writeByte(12)
      ..write(obj.reminderAt)
      ..writeByte(13)
      ..write(obj.pushToken)
      ..writeByte(14)
      ..write(obj.reminderSent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
