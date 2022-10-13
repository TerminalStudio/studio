import 'package:hive_flutter/hive_flutter.dart';
import 'package:terminal_studio/src/util/uuid.dart';

part 'ssh_key_record.g.dart';

@HiveType(typeId: 1)
class SSHKeyRecord extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? comment;

  @HiveField(3)
  String? passphrase;

  @HiveField(4)
  String? privateKey;

  @HiveField(5)
  String? publicKey;

  SSHKeyRecord({
    String? uuid,
    required this.name,
    this.comment,
    this.passphrase,
    this.privateKey,
    this.publicKey,
  }) : uuid = uuid ?? uuidV4();
}
