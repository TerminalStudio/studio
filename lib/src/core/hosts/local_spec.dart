import 'package:studio/src/core/conn.dart';
import 'package:studio/src/core/hosts/local_conn.dart';

class LocalHostSpec implements HostSpec {
  @override
  final name = 'Local';

  @override
  HostConnector createConnector() => LocalConnector();
}
