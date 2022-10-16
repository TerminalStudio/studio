import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/hosts/ssh_host.dart';
import 'package:terminal_studio/src/core/record/ssh_host_record.dart';

class SSHConnector extends HostConnector<SSHHost> {
  final SSHHostRecord record;

  SSHConnector(this.record);

  @override
  Future<SSHHost> createHost() async {
    final socket = await AsyncValue.guard(
      () => SSHSocket.connect(
        record.host,
        record.port,
      ),
    );

    if (socket.hasError) {
      final error = socket.error!;
      throw 'Failed to connect: $error';
    }

    final client = SSHClient(
      socket.value!,
      username: record.username!,
      onPasswordRequest: () => record.password,
    );

    final authenticated = await AsyncValue.guard(() => client.authenticated);

    if (authenticated.hasError) {
      final error = authenticated.error!;
      throw 'Failed to authenticate: $error';
    }

    return SSHHost(client);
  }
}
