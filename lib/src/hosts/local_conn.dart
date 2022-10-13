import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/hosts/local_host.dart';

class LocalConnector extends HostConnector<LocalHost> {
  LocalConnector();
  @override
  Future<void> connect() async {
    state = LocalHost();
    status.value = HostConnectorStatus.connected;
    statusText.value = 'Connected';
  }

  @override
  Future<void> disconnect() async {
    state = null;
    status.value = HostConnectorStatus.disconnected;
    statusText.value = 'Disconnected';
  }
}
