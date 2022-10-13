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

abstract class HostConnector<T extends Host> extends StateNotifier<T?> {
  HostConnector() : super(null);

  final status = ValueNotifier(HostConnectorStatus.disconnected);

  final statusText = ValueNotifier<String?>(null);

  Future<void> connect();

  Future<void> disconnect();
}
