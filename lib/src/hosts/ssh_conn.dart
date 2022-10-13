import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/hosts/ssh_host.dart';
import 'package:terminal_studio/src/core/record/ssh_host_record.dart';

class SSHConnector extends HostConnector<SSHHost> {
  final SSHHostRecord record;

  SSHConnector(this.record);

  @override
  Future<void> connect() async {
    status.value = HostConnectorStatus.connecting;
    statusText.value = 'Connecting...';

    final socket = await AsyncValue.guard(
      () => SSHSocket.connect(
        record.host,
        record.port,
      ),
    );

    if (socket.hasError) {
      final error = socket.error!;
      status.value = HostConnectorStatus.disconnected;
      statusText.value = 'Failed to connect: $error';
      return;
    }

    statusText.value = 'Authenticating...';

    final client = SSHClient(
      socket.value!,
      username: record.username!,
      onPasswordRequest: () => record.password,
    );

    final authenticated = await AsyncValue.guard(() => client.authenticated);

    if (authenticated.hasError) {
      final error = authenticated.error!;
      status.value = HostConnectorStatus.disconnected;
      statusText.value = 'Failed to authenticate: $error';
      return;
    }

    client.done.then((_) => _onDone(), onError: _onError);

    state = SSHHost(client);
    status.value = HostConnectorStatus.connected;
    statusText.value = 'Connected';
  }

  @override
  Future<void> disconnect() async {
    state?.client.close();
    state = null;
    status.value = HostConnectorStatus.disconnected;
    statusText.value = 'Disconnected';
  }

  void _onDone() {
    state = null;
    status.value = HostConnectorStatus.disconnected;
    statusText.value = 'Disconnected';
  }

  void _onError(Object error) {
    state = null;
    status.value = HostConnectorStatus.aborted;
    statusText.value = 'Aborted: $error';
  }
}
