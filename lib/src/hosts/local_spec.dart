import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/hosts/local_conn.dart';

class LocalHostSpec implements HostSpec {
  @override
  final name = 'Local';

  @override
  HostConnector createConnector() => LocalConnector();
}
