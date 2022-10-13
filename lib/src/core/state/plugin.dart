import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/conn.dart';
import 'package:studio/src/core/plugin.dart';
import 'package:studio/src/core/state/host.dart';

final pluginManagerProvider = Provider.family<PluginManager, HostSpec>(
  name: 'pluginManagerProvider',
  (ref, spec) {
    final manager = PluginManager(spec);

    ref.listen(
      hostProvider(spec),
      (last, current) {
        if (last == null && current != null) {
          manager.didConnected(current);
        }

        if (last != null && current == null) {
          manager.didDisconnected();
        }
      },
      fireImmediately: true,
    );

    return manager;
  },
);
