import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio/src/ui/shortcut/intents.dart';

class GlobalShortcuts extends StatelessWidget {
  const GlobalShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(shortcuts: _effectShortcuts, child: child);
  }
}

const _shortcuts = {
  SingleActivator(LogicalKeyboardKey.keyN, control: true): NewWindowIntent(),
};

const _macShortcuts = {
  SingleActivator(LogicalKeyboardKey.keyN, meta: true): NewWindowIntent(),
};

Map<ShortcutActivator, Intent> get _effectShortcuts {
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return _macShortcuts;
  }

  return _shortcuts;
}
