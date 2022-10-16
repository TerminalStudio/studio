import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/hosts/local_host.dart';

class LocalConnector extends HostConnector<LocalHost> {
  LocalConnector();

  @override
  Future<LocalHost> createHost() async {
    return LocalHost();
  }
}
