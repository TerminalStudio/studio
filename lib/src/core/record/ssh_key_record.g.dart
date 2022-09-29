// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_key_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SSHKeyRecordAdapter extends TypeAdapter<SSHKeyRecord> {
  @override
  final int typeId = 1;

  @override
  SSHKeyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SSHKeyRecord(
      uuid: fields[0] as String?,
      name: fields[1] as String,
      comment: fields[2] as String?,
      passphrase: fields[3] as String?,
      privateKey: fields[4] as String?,
      publicKey: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SSHKeyRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.passphrase)
      ..writeByte(4)
      ..write(obj.privateKey)
      ..writeByte(5)
      ..write(obj.publicKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SSHKeyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
