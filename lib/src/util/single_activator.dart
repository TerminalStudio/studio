import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:terminal_studio/src/util/target_platform.dart';

extension SingleActivatorExtension on SingleActivator {
  String get platformLabel {
    return defaultTargetPlatform.isApple ? appleLabel : windowsLabel;
  }

  String get windowsLabel {
    final StringBuffer buffer = StringBuffer();

    if (control) {
      buffer.write('Ctrl+');
    }
    if (meta) {
      buffer.write('Meta+');
    }
    if (shift) {
      buffer.write('Shift+');
    }
    if (alt) {
      buffer.write('Alt+');
    }
    buffer.write(trigger.keyLabel);

    return buffer.toString();
  }

  String get appleLabel {
    final StringBuffer buffer = StringBuffer();

    if (control) {
      buffer.write('⌃');
    }
    if (alt) {
      buffer.write('⌥');
    }
    if (shift) {
      buffer.write('⇧');
    }
    if (meta) {
      buffer.write('⌘');
    }
    buffer.write(trigger.keyLabel);

    return buffer.toString();
  }
}
