// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_host_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SSHHostRecordAdapter extends TypeAdapter<SSHHostRecord> {
  @override
  final int typeId = 0;

  @override
  SSHHostRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SSHHostRecord(
      uuid: fields[0] as String?,
      name: fields[1] as String,
      host: fields[2] as String,
      port: fields[3] as int,
      username: fields[4] as String?,
      password: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SSHHostRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SSHHostRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
