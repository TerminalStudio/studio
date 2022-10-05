import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/conn.dart';
import 'package:studio/src/core/host.dart';

final connectorProvider = Provider.family(
  name: 'connectorProvider',
  (ref, HostSpec config) {
    final connector = config.createConnector();
    connector.connect();
    return connector;
  },
);

final hostProvider =
    StateNotifierProvider.family<HostConnector, Host?, HostSpec>(
  name: 'hostProvider',
  (ref, spec) => ref.watch(connectorProvider(spec)),
);
