import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/plugin.dart';

class StarterPlugin extends Plugin {
  final _uptime = ValueNotifier<String?>(null);

  Future<void> _updateUptime() async {
    final result = await AsyncValue.guard(() => host.execute('uptime'));

    result.when(
      data: (data) => _uptime.value = data.stdout,
      loading: () => _uptime.value = 'Loading...',
      error: (error, stackTrace) => _uptime.value = 'Error: $error',
    );
  }

  Future<void> _startUpdate() async {
    while (connected) {
      await _updateUptime();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void didMounted() {
    title.value = 'Uptime';
    super.didMounted();
  }

  @override
  void didConnected() {
    _startUpdate();
    super.didConnected();
  }

  @override
  void didDisconnected() {
    _uptime.value = 'Disconnected';
    super.didDisconnected();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: 0,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.server),
            title: const Text('Uptime'),
            body: Center(
              child: ValueListenableBuilder<String?>(
                valueListenable: _uptime,
                builder: (context, value, child) {
                  return Text(value ?? 'Waiting...');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
