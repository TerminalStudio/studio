import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/host.dart';

abstract class HostSpec {
  String get name;

  HostConnector createConnector();
}

enum HostConnectorStatus {
  initialized,
  connecting,
  connected,
  disconnected,
  aborted,
}

abstract class HostConnector<T extends Host>
    extends StateNotifier<HostConnectorStatus> {
  HostConnector() : super(HostConnectorStatus.initialized);

  T? _host;

  T? get host => _host;

  @protected
  Future<T> createHost();

  Future<void> connect() async {
    if (state == HostConnectorStatus.connected ||
        state == HostConnectorStatus.connecting) {
      return;
    }

    state = HostConnectorStatus.connecting;

    try {
      _host = await createHost();
      _host!.done.then((_) => _onDone(), onError: _onError);

      state = HostConnectorStatus.connected;
    } catch (e) {
      state = HostConnectorStatus.disconnected;
    }
  }

  Future<void> disconnect() async {
    await _host?.disconnect();
    _host = null;
    state = HostConnectorStatus.disconnected;
  }

  void _onDone() {
    _host = null;
    state = HostConnectorStatus.disconnected;
  }

  void _onError(Object error) {
    _host = null;
    state = HostConnectorStatus.aborted;
  }
}
