import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  Future<void> createWindow() async {
    final executable = Platform.resolvedExecutable;
    await Process.start(executable, [], mode: ProcessStartMode.detached);
  }

  Future<void> setTitle(String title) async {
    await windowManager.setTitle(title);
  }
}

final windowServiceProvider = Provider<WindowService>(
  name: 'WindowService',
  (ref) => WindowService(),
);
