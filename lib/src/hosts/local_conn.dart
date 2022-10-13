import 'package:studio/src/core/conn.dart';
import 'package:studio/src/hosts/local_host.dart';

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
