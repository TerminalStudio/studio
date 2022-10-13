import 'package:hive_flutter/hive_flutter.dart';
import 'package:studio/src/core/conn.dart';
import 'package:studio/src/hosts/ssh_conn.dart';
import 'package:studio/src/util/uuid.dart';

part 'ssh_host_record.g.dart';

@HiveType(typeId: 0)
class SSHHostRecord extends HiveObject implements HostSpec {
  @HiveField(0)
  String uuid;

  @override
  @HiveField(1)
  String name;

  @HiveField(2)
  String host;

  @HiveField(3)
  int port;

  @HiveField(4)
  String? username;

  @HiveField(5)
  String? password;

  SSHHostRecord({
    String? uuid,
    required this.name,
    required this.host,
    required this.port,
    this.username,
    this.password,
  }) : uuid = uuid ?? uuidV4();

  SSHHostRecord.uninitialized()
      : this(
          name: '',
          host: '',
          port: 22,
        );

  @override
  HostConnector createConnector() => SSHConnector(this);
}
