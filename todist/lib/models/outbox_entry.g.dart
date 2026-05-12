// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutboxEntryAdapter extends TypeAdapter<OutboxEntry> {
  @override
  final int typeId = 3;

  @override
  OutboxEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutboxEntry(
      localId: fields[0] as String,
      operation: fields[1] as OutboxOperation,
      payload: (fields[2] as Map).cast<String, dynamic>(),
      createdAt: fields[3] as DateTime?,
      retryCount: fields[4] as int,
      lastAttempt: fields[5] as DateTime?,
      lastError: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OutboxEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.operation)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.lastAttempt)
      ..writeByte(6)
      ..write(obj.lastError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
