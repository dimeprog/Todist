// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutboxOperationAdapter extends TypeAdapter<OutboxOperation> {
  @override
  final int typeId = 2;

  @override
  OutboxOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OutboxOperation.upsert;
      case 1:
        return OutboxOperation.delete;
      default:
        return OutboxOperation.upsert;
    }
  }

  @override
  void write(BinaryWriter writer, OutboxOperation obj) {
    switch (obj) {
      case OutboxOperation.upsert:
        writer.writeByte(0);
        break;
      case OutboxOperation.delete:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
